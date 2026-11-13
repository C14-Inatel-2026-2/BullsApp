"""Gera reports/relatorio.html a partir da saída do `flutter test`.

Lê:
  - reports/test-results.json  (flutter test --machine)
  - coverage/lcov.info         (flutter test --coverage)

Uso: python scripts/gerar_relatorio.py
Não precisa de nenhuma biblioteca além do Python.
"""

import html
import json
import os
from collections import defaultdict
from datetime import datetime

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENTRADA_TESTES = os.path.join(RAIZ, "reports", "test-results.json")
ENTRADA_COBERTURA = os.path.join(RAIZ, "coverage", "lcov.info")
SAIDA = os.path.join(RAIZ, "reports", "relatorio.html")


def ler_texto(caminho):
    """Lê o arquivo em UTF-8 ou UTF-16 (o PowerShell às vezes grava em UTF-16)."""
    with open(caminho, "rb") as f:
        dados = f.read()
    if dados.startswith((b"\xff\xfe", b"\xfe\xff")):
        return dados.decode("utf-16")
    return dados.decode("utf-8", errors="replace")


def caminho_relativo(caminho):
    caminho = caminho.replace("\\", "/")
    raiz = RAIZ.replace("\\", "/")
    if caminho.lower().startswith(raiz.lower()):
        caminho = caminho[len(raiz):].lstrip("/")
    return caminho


# ---------------------------------------------------------------- testes

def ler_testes():
    suites, grupos, testes = {}, {}, {}
    duracao_total = 0

    for linha in ler_texto(ENTRADA_TESTES).splitlines():
        linha = linha.strip()
        if not linha.startswith("{"):
            continue
        try:
            e = json.loads(linha)
        except json.JSONDecodeError:
            continue

        tipo = e.get("type")
        if tipo == "suite":
            suites[e["suite"]["id"]] = caminho_relativo(e["suite"]["path"])
        elif tipo == "group":
            grupos[e["group"]["id"]] = e["group"]["name"]
        elif tipo == "testStart":
            t = e["test"]
            testes[t["id"]] = {
                "nome": t["name"],
                "suite": t["suiteID"],
                "grupos": t["groupIDs"],
                "inicio": e["time"],
                "resultado": None,
                "pulado": False,
                "oculto": False,
                "tempo": 0,
                "erros": [],
                "prints": [],
            }
        elif tipo == "testDone" and e["testID"] in testes:
            t = testes[e["testID"]]
            t["resultado"] = e["result"]
            t["pulado"] = e["skipped"]
            t["oculto"] = e["hidden"]
            t["tempo"] = e["time"] - t["inicio"]
        elif tipo == "error" and e.get("testID") in testes:
            testes[e["testID"]]["erros"].append(
                e["error"] + "\n\n" + e.get("stackTrace", "")
            )
        elif tipo == "print" and e.get("testID") in testes:
            testes[e["testID"]]["prints"].append(e["message"])
        elif tipo == "done":
            duracao_total = e["time"]

    # Agrupa por arquivo de teste e tira o nome do grupo do nome do teste
    por_arquivo = defaultdict(list)
    for t in testes.values():
        if t["oculto"] or t["resultado"] is None:
            continue
        grupo = ""
        for gid in t["grupos"]:
            if grupos.get(gid):
                grupo = grupos[gid]
        nome = t["nome"]
        if grupo and nome.startswith(grupo + " "):
            nome = nome[len(grupo) + 1:]
        if t["pulado"]:
            status = "pulado"
        elif t["resultado"] == "success":
            status = "passou"
        else:
            status = "falhou"
        por_arquivo[suites.get(t["suite"], "?")].append(
            {**t, "nome": nome, "grupo": grupo, "status": status}
        )

    return dict(sorted(por_arquivo.items())), duracao_total


# ------------------------------------------------------------- cobertura

def ler_cobertura():
    if not os.path.exists(ENTRADA_COBERTURA):
        return []
    arquivos, atual = [], None
    for linha in ler_texto(ENTRADA_COBERTURA).splitlines():
        if linha.startswith("SF:"):
            atual = {"arquivo": caminho_relativo(linha[3:]), "linhas": {}}
        elif linha.startswith("DA:") and atual:
            num, hits = linha[3:].split(",")[:2]
            atual["linhas"][int(num)] = int(hits)
        elif linha == "end_of_record" and atual:
            total = len(atual["linhas"])
            cobertas = sum(1 for h in atual["linhas"].values() if h > 0)
            atual["total"] = total
            atual["cobertas"] = cobertas
            atual["pct"] = 100 * cobertas / total if total else 100
            arquivos.append(atual)
            atual = None
    return sorted(arquivos, key=lambda a: a["arquivo"])


# ------------------------------------------------------------------ HTML

def esc(texto):
    return html.escape(str(texto))


def cor_pct(pct):
    if pct >= 80:
        return "bom"
    if pct >= 50:
        return "medio"
    return "ruim"


def html_testes(por_arquivo):
    partes = []
    for arquivo, testes in por_arquivo.items():
        falhas = sum(1 for t in testes if t["status"] == "falhou")
        passou = sum(1 for t in testes if t["status"] == "passou")
        selo = (
            f'<span class="selo falhou">{falhas} falha(s)</span>'
            if falhas
            else '<span class="selo passou">tudo ok</span>'
        )
        itens = []
        for t in testes:
            icone = {"passou": "✓", "falhou": "✗", "pulado": "–"}[t["status"]]
            detalhes = ""
            if t["erros"]:
                detalhes += "".join(
                    f'<pre class="erro">{esc(err)}</pre>' for err in t["erros"]
                )
            if t["prints"]:
                detalhes += (
                    '<pre class="print">' + esc("\n".join(t["prints"])) + "</pre>"
                )
            grupo = f'<span class="grupo">{esc(t["grupo"])}</span>' if t["grupo"] else ""
            itens.append(
                f'<li class="teste {t["status"]}">'
                f'<div class="linha-teste"><span class="icone">{icone}</span>'
                f'{grupo}<span class="nome">{esc(t["nome"])}</span>'
                f'<span class="tempo">{t["tempo"]} ms</span></div>{detalhes}</li>'
            )
        aberto = " open" if falhas else ""
        partes.append(
            f'<details class="arquivo" data-falhas="{falhas}"{aberto}>'
            f'<summary><span class="caminho">{esc(arquivo)}</span>'
            f'<span class="contagem">{passou}/{len(testes)}</span>{selo}</summary>'
            f'<ul>{"".join(itens)}</ul></details>'
        )
    return "".join(partes)


def html_codigo(arquivo):
    caminho = os.path.join(RAIZ, arquivo["arquivo"])
    try:
        fonte = ler_texto(caminho).splitlines()
    except OSError:
        return '<p class="vazio">Código-fonte não encontrado.</p>'
    linhas = []
    for i, texto in enumerate(fonte, start=1):
        hits = arquivo["linhas"].get(i)
        classe = "" if hits is None else ("coberta" if hits > 0 else "descoberta")
        linhas.append(
            f'<tr class="{classe}"><td class="num">{i}</td>'
            f'<td class="cod">{esc(texto) or " "}</td></tr>'
        )
    return f'<table class="codigo">{"".join(linhas)}</table>'


def html_cobertura(arquivos):
    if not arquivos:
        return '<p class="vazio">Sem dados de cobertura.</p>'
    linhas = []
    for a in sorted(arquivos, key=lambda a: a["pct"]):
        pasta, _, nome = a["arquivo"].rpartition("/")
        linhas.append(
            f'<details class="cob"><summary>'
            f'<span class="caminho"><span class="pasta">{esc(pasta)}/</span>{esc(nome)}</span>'
            f'<span class="barra"><span class="preenchido {cor_pct(a["pct"])}" '
            f'style="width:{a["pct"]:.0f}%"></span></span>'
            f'<span class="pct {cor_pct(a["pct"])}">{a["pct"]:.0f}%</span>'
            f'<span class="contagem">{a["cobertas"]}/{a["total"]} linhas</span>'
            f"</summary>{html_codigo(a)}</details>"
        )
    return "".join(linhas)


def junit_xml(por_arquivo):
    """XML no formato JUnit, lido pelo passo `junit` do Jenkins."""
    suites = []
    for arquivo, testes in por_arquivo.items():
        casos = []
        for t in testes:
            nome = f'{t["grupo"]} {t["nome"]}'.strip()
            dentro = ""
            if t["status"] == "falhou":
                erro = "\n".join(t["erros"])
                dentro = f'<failure message="falhou">{esc(erro)}</failure>'
            elif t["status"] == "pulado":
                dentro = "<skipped/>"
            casos.append(
                f'<testcase classname="{esc(arquivo)}" name="{esc(nome)}" '
                f'time="{t["tempo"] / 1000:.3f}">{dentro}</testcase>'
            )
        falhas = sum(1 for t in testes if t["status"] == "falhou")
        pulados = sum(1 for t in testes if t["status"] == "pulado")
        suites.append(
            f'<testsuite name="{esc(arquivo)}" tests="{len(testes)}" '
            f'failures="{falhas}" skipped="{pulados}">{"".join(casos)}</testsuite>'
        )
    return '<?xml version="1.0" encoding="UTF-8"?>\n<testsuites>' + "".join(suites) + "</testsuites>"


def gerar():
    por_arquivo, duracao = ler_testes()
    cobertura = ler_cobertura()

    todos = [t for ts in por_arquivo.values() for t in ts]
    total = len(todos)
    passou = sum(1 for t in todos if t["status"] == "passou")
    falhou = sum(1 for t in todos if t["status"] == "falhou")
    pulado = sum(1 for t in todos if t["status"] == "pulado")
    linhas_total = sum(a["total"] for a in cobertura)
    linhas_cobertas = sum(a["cobertas"] for a in cobertura)
    pct_cob = 100 * linhas_cobertas / linhas_total if linhas_total else 0

    status_geral = "falhou" if falhou else "passou"
    titulo_geral = f"{falhou} teste(s) falharam" if falhou else "Todos os testes passaram"

    pagina = MODELO.format(
        data=datetime.now().strftime("%d/%m/%Y %H:%M"),
        status_geral=status_geral,
        titulo_geral=titulo_geral,
        total=total,
        passou=passou,
        falhou=falhou,
        pulado=pulado,
        arquivos=len(por_arquivo),
        duracao=f"{duracao / 1000:.1f}",
        pct_cob=f"{pct_cob:.0f}",
        cor_cob=cor_pct(pct_cob),
        linhas_cobertas=linhas_cobertas,
        linhas_total=linhas_total,
        testes=html_testes(por_arquivo),
        cobertura=html_cobertura(cobertura),
    )

    os.makedirs(os.path.dirname(SAIDA), exist_ok=True)
    with open(SAIDA, "w", encoding="utf-8") as f:
        f.write(pagina)
    with open(os.path.join(os.path.dirname(SAIDA), "test-results.xml"), "w", encoding="utf-8") as f:
        f.write(junit_xml(por_arquivo))

    resumo = f"{passou}/{total} testes passaram · {falhou} falha(s) · cobertura {pct_cob:.0f}%"
    # Usado pelo Jenkins no texto da mensagem do Discord
    with open(os.path.join(os.path.dirname(SAIDA), "resumo.txt"), "w", encoding="utf-8") as f:
        f.write(resumo)
    print(f"Relatório gerado: {caminho_relativo(SAIDA)}")
    print(f"  {resumo}")


MODELO = """<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Relatório de Testes · BullsApp</title>
<style>
:root {{
  --fundo: #f5f6f8; --cartao: #ffffff; --texto: #1d2330; --suave: #6b7385;
  --borda: #e3e6ec; --verde: #1f9d55; --verde-bg: #e6f6ec; --vermelho: #d64545;
  --vermelho-bg: #fdecec; --amarelo: #c98a00; --amarelo-bg: #fff6dd;
  --destaque: #c8102e; --codigo-bg: #fafbfc;
}}
@media (prefers-color-scheme: dark) {{
  :root {{
    --fundo: #12151c; --cartao: #1b1f29; --texto: #e6e9ef; --suave: #8f97a8;
    --borda: #2a303d; --verde: #4cc884; --verde-bg: #173324; --vermelho: #f06c6c;
    --vermelho-bg: #3a1c1f; --amarelo: #f0c04a; --amarelo-bg: #3a3018;
    --destaque: #ff4d6a; --codigo-bg: #161a22;
  }}
}}
* {{ box-sizing: border-box; }}
body {{ margin: 0; background: var(--fundo); color: var(--texto);
  font: 15px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }}
main {{ max-width: 1040px; margin: 0 auto; padding: 32px 16px 64px; }}
header {{ display: flex; justify-content: space-between; align-items: flex-end;
  flex-wrap: wrap; gap: 8px; margin-bottom: 20px; }}
h1 {{ margin: 0; font-size: 26px; }}
h1 span {{ color: var(--destaque); }}
h2 {{ font-size: 18px; margin: 40px 0 12px; }}
.data {{ color: var(--suave); font-size: 13px; }}
.faixa {{ padding: 14px 18px; border-radius: 10px; font-weight: 600; margin-bottom: 16px; }}
.faixa.passou {{ background: var(--verde-bg); color: var(--verde); }}
.faixa.falhou {{ background: var(--vermelho-bg); color: var(--vermelho); }}
.cartoes {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; }}
.cartao {{ background: var(--cartao); border: 1px solid var(--borda); border-radius: 10px; padding: 14px 16px; }}
.cartao .valor {{ font-size: 28px; font-weight: 700; line-height: 1.1; }}
.cartao .rotulo {{ color: var(--suave); font-size: 13px; }}
.cartao.passou .valor, .pct.bom {{ color: var(--verde); }}
.cartao.falhou .valor, .pct.ruim {{ color: var(--vermelho); }}
.pct.medio {{ color: var(--amarelo); }}
.filtros {{ display: flex; gap: 8px; margin-bottom: 12px; }}
.filtros button {{ border: 1px solid var(--borda); background: var(--cartao); color: var(--texto);
  border-radius: 999px; padding: 4px 14px; cursor: pointer; font: inherit; font-size: 13px; }}
.filtros button.ativo {{ background: var(--texto); color: var(--cartao); }}
details {{ background: var(--cartao); border: 1px solid var(--borda); border-radius: 10px; margin-bottom: 8px; overflow: hidden; }}
summary {{ display: flex; align-items: center; gap: 12px; padding: 10px 14px; cursor: pointer; list-style: none; }}
summary::-webkit-details-marker {{ display: none; }}
summary::before {{ content: "▸"; color: var(--suave); transition: transform .15s; }}
details[open] > summary::before {{ transform: rotate(90deg); }}
.caminho {{ flex: 1; font-family: ui-monospace, Consolas, monospace; font-size: 13px; word-break: break-all; }}
.pasta {{ color: var(--suave); }}
.contagem {{ color: var(--suave); font-size: 13px; white-space: nowrap; }}
.selo {{ font-size: 12px; font-weight: 600; padding: 2px 10px; border-radius: 999px; white-space: nowrap; }}
.selo.passou {{ background: var(--verde-bg); color: var(--verde); }}
.selo.falhou {{ background: var(--vermelho-bg); color: var(--vermelho); }}
ul {{ list-style: none; margin: 0; padding: 0; border-top: 1px solid var(--borda); }}
.teste {{ padding: 8px 14px 8px 38px; border-bottom: 1px solid var(--borda); }}
.teste:last-child {{ border-bottom: 0; }}
.linha-teste {{ display: flex; align-items: baseline; gap: 10px; }}
.icone {{ font-weight: 700; width: 14px; }}
.teste.passou .icone {{ color: var(--verde); }}
.teste.falhou {{ background: var(--vermelho-bg); }}
.teste.falhou .icone {{ color: var(--vermelho); }}
.teste.pulado .icone {{ color: var(--amarelo); }}
.grupo {{ font-size: 12px; color: var(--suave); background: var(--fundo); padding: 1px 8px; border-radius: 4px; white-space: nowrap; }}
.nome {{ flex: 1; }}
.tempo {{ color: var(--suave); font-size: 12px; white-space: nowrap; }}
pre {{ margin: 8px 0 0; padding: 10px; border-radius: 6px; overflow-x: auto; font-size: 12px; white-space: pre-wrap; }}
pre.erro {{ background: var(--cartao); color: var(--vermelho); border: 1px solid var(--vermelho); }}
pre.print {{ background: var(--fundo); color: var(--suave); }}
.barra {{ width: 160px; height: 8px; background: var(--fundo); border-radius: 999px; overflow: hidden; flex-shrink: 0; }}
.preenchido {{ display: block; height: 100%; }}
.preenchido.bom {{ background: var(--verde); }}
.preenchido.medio {{ background: var(--amarelo); }}
.preenchido.ruim {{ background: var(--vermelho); }}
.pct {{ width: 44px; text-align: right; font-weight: 700; }}
.legenda {{ color: var(--suave); font-size: 13px; margin: -4px 0 12px; }}
.legenda b {{ padding: 0 6px; border-radius: 3px; font-weight: 500; }}
.codigo {{ width: 100%; border-collapse: collapse; font-family: ui-monospace, Consolas, monospace;
  font-size: 12px; background: var(--codigo-bg); border-top: 1px solid var(--borda); }}
.codigo td {{ padding: 0 10px; white-space: pre; }}
.codigo .num {{ width: 1%; text-align: right; color: var(--suave); user-select: none; border-right: 1px solid var(--borda); }}
.coberta .cod, b.coberta {{ background: var(--verde-bg); }}
.descoberta .cod, b.descoberta {{ background: var(--vermelho-bg); }}
.cob {{ }}
.cob > table {{ display: block; overflow-x: auto; max-height: 520px; overflow-y: auto; }}
.vazio {{ color: var(--suave); }}
@media (max-width: 640px) {{
  .barra {{ width: 60px; }}
  .contagem {{ display: none; }}
  .linha-teste {{ flex-wrap: wrap; }}
}}
</style>
</head>
<body>
<main>
<header>
  <h1>Bulls<span>App</span> · Relatório de Testes</h1>
  <span class="data">Gerado em {data}</span>
</header>

<div class="faixa {status_geral}">{titulo_geral}</div>

<div class="cartoes">
  <div class="cartao"><div class="valor">{total}</div><div class="rotulo">testes em {arquivos} arquivos</div></div>
  <div class="cartao passou"><div class="valor">{passou}</div><div class="rotulo">passaram</div></div>
  <div class="cartao falhou"><div class="valor">{falhou}</div><div class="rotulo">falharam</div></div>
  <div class="cartao"><div class="valor">{pulado}</div><div class="rotulo">pulados</div></div>
  <div class="cartao"><div class="valor">{duracao}s</div><div class="rotulo">duração</div></div>
  <div class="cartao"><div class="valor pct {cor_cob}" style="width:auto;text-align:left">{pct_cob}%</div><div class="rotulo">cobertura ({linhas_cobertas}/{linhas_total} linhas)</div></div>
</div>

<h2>Testes por arquivo</h2>
<div class="filtros">
  <button class="ativo" data-filtro="todos">Todos</button>
  <button data-filtro="falhas">Só com falha</button>
  <button data-filtro="abrir">Abrir tudo</button>
  <button data-filtro="fechar">Fechar tudo</button>
</div>
<div id="testes">{testes}</div>

<h2>Cobertura por arquivo</h2>
<p class="legenda">Do menos coberto para o mais coberto. Clique num arquivo para ver o código:
  <b class="coberta">linha testada</b> <b class="descoberta">linha nunca executada</b></p>
{cobertura}
</main>
<script>
document.querySelectorAll(".filtros button").forEach(function (b) {{
  b.addEventListener("click", function () {{
    var f = b.dataset.filtro;
    var arquivos = document.querySelectorAll("#testes details");
    if (f === "abrir" || f === "fechar") {{
      arquivos.forEach(function (d) {{ if (d.style.display !== "none") d.open = f === "abrir"; }});
      return;
    }}
    document.querySelectorAll(".filtros button[data-filtro=todos], .filtros button[data-filtro=falhas]")
      .forEach(function (x) {{ x.classList.toggle("ativo", x === b); }});
    arquivos.forEach(function (d) {{
      d.style.display = f === "falhas" && d.dataset.falhas === "0" ? "none" : "";
    }});
  }});
}});
</script>
</body>
</html>
"""

if __name__ == "__main__":
    gerar()

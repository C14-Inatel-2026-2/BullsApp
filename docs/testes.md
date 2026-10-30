# Testes

Os testes usam `flutter_test` e `mocktail` e ficam na pasta `test/`, que segue a mesma estrutura do `lib/`:

- `test/core/`: protocolo de comandos do robô;
- `test/data/`: modelos, repositórios e serviços (BLE);
- `test/presentation/`: controllers, telas e widgets.

## Rodar os testes

```powershell
flutter test        # ou: make test
```

## Relatório de testes

Gera o arquivo `reports/relatorio.html`, que tem:

- um resumo com o total de testes, quantos passaram ou falharam e a cobertura geral;
- os testes agrupados por arquivo, com a mensagem de erro de cada falha;
- a cobertura de cada arquivo do `lib/`, com o código colorido: verde para linha testada e vermelho para linha nunca executada.

É preciso ter Python instalado. Rode:

```powershell
make report
start reports/relatorio.html
```

No Jenkins, os testes rodam no estágio "Executar Testes". Veja [CI/CD](ci-cd.md).

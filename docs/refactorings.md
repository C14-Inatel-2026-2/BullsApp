# Refactorings

| Smell | Refactoring | Por quê | PR |
|---|---|---|---|
| Duplicated Code: layout repetido nas telas Home, Modo e Teste | Extract Function (widget `MenuLayout`) | Mudar o menu num lugar só | [refactor/menu-layout](https://github.com/C14-Inatel-2026-2/BullsApp/compare/main...refactor/menu-layout) |
| Magic Literal: caminho do logo repetido em 4 telas | Replace Magic Literal (`AppAssets.logo`) | Trocar a imagem num lugar só | [refactor/menu-layout](https://github.com/C14-Inatel-2026-2/BullsApp/compare/main...refactor/menu-layout) |
| Duplicated Code: `catch` repetido e ordenação com `if`s encadeados na camada BLE | Consolidate Duplicate Conditional Fragments e Substitute Algorithm | Um só tratamento de erro e código mais curto | [#22](https://github.com/C14-Inatel-2026-2/BullsApp/pull/22) |
| Estágio do Jenkins com duas responsabilidades | Split Phase (formatação e análise estática separadas) | Saber qual verificação falhou | [#19](https://github.com/C14-Inatel-2026-2/BullsApp/pull/19) |
| Comments: comentários que repetiam o código | Remoção dos comentários redundantes | Comentário fica desatualizado | Sem PR (commit [`aaf1d4a`](https://github.com/C14-Inatel-2026-2/BullsApp/commit/aaf1d4a750cdc4015db6ac780f700a8dc6843251)) |
| Testes do `TestController` liberavam recursos só no fim (não roda se o teste falhar) | Limpeza com `addTearDown` | Testes isolados (FIRST) | [#35](https://github.com/C14-Inatel-2026-2/BullsApp/pull/35) |
| Teste do `dispose` passava mesmo sem o controller se inscrever | Verificar a inscrição antes do `dispose` | O teste só passa se o comportamento existir | [#35](https://github.com/C14-Inatel-2026-2/BullsApp/pull/35) |

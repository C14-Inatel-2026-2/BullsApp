# Dinâmica de desenvolvimento

- **Branches:** uma branch por funcionalidade e algumas com prefixos `feat/`, `fix/`, `test/`, `ci/` e `refactor/`, e merge na `main` só por pull request.
- **Commits:** padrão *Conventional Commits* (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `ci:`). Cerca de 95% dos commits da `main` seguem esse padrão.
- **Code review:** todo PR é revisado por outro membro antes do merge.
- **Bloqueios:**
  - o PR #4 (`feat/controllers`) quebrou a `main` e foi revertido no PR #5, depois reaplicado no PR #6;
  - o build de iOS não rodava no container Linux e foi removido (commit `c68912d`);
  - as strings de alguns comandos ainda dependem de confirmação com a equipe de firmware.
- **Lições aprendidas:**
  - padronizar os nomes das branches desde o início (houve `Frontend`, `Fronted-Sensor` e `TESTE-FRONTED-SENSOR`);
  - escrever os testes junto com a funcionalidade, e não depois;
  - dividir as tarefas de forma mais equilibrada entre os membros.

# BullsApp

Projeto Flutter para controle e conexão com dispositivos.

## Bibliotecas e ferramentas necessárias

Antes de rodar o projeto, instale as seguintes ferramentas e dependências:

### Ferramentas do sistema

- Flutter SDK
- Git
- Android Studio
- Android SDK / Android command-line tools
- Java JDK (necessário para compilar Android)
- VS Code ou outro editor

### Bibliotecas do projeto

Ao executar `flutter pub get`, o Flutter baixa automaticamente as dependências do projeto. As bibliotecas usadas no app são:

- `cupertino_icons`
- `google_fonts`
- `flutter_blue_plus`
- `iconsax`
- `provider`

Para desenvolvimento/testes também estão configuradas:

- `flutter_lints`
- `mocktail`

## Instalar o Flutter no Windows

1. Baixe o Flutter: https://docs.flutter.dev/get-started/install/windows
2. Extraia a pasta, por exemplo, em:

```text
C:\src\flutter
```

3. Adicione este caminho ao `Path` do Windows:

```text
C:\src\flutter\bin
```

4. Instale o Android Studio e o Android SDK.
5. Abra um novo terminal e verifique a instalação:

```powershell
flutter doctor
```

## Rodar o projeto

Na pasta do projeto:

```powershell
flutter pub get
flutter run
```

Ou usando o Makefile:

```powershell
make get
make run
```

## Comandos úteis

```powershell
flutter clean       # Limpa os arquivos gerados
flutter test        # Executa os testes
flutter analyze     # Analisa o código
flutter build apk   # Gera o APK Android
flutter build web   # Gera a versão Web
```

Com Makefile:

```powershell
make clean
make test
make build-apk
make build-web
```

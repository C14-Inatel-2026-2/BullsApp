## Camada BLE

A comunicação com o robô é dividida em camadas. Cada uma só conversa com a de baixo, e **apenas `ble_platform.dart` acessa `flutter_blue_plus`, `Platform` e `permission_handler`**.

```text
BleController  →  BleRepository  →  BleService  →  BlePlatform  →  flutter_blue_plus
```

| Arquivo | Responsabilidade |
| --- | --- |
| [`ble_controller.dart`](./lib/presentation/controllers/ble_controller.dart) | Estado da tela (`devices`, `isScanning`, `errorMessage`); scan, conexão e MACs já conhecidos. |
| [`ble_repository.dart`](./lib/data/repositories/ble_repository.dart) | Converte o scan em `BleDeviceModel`, mescla pareados, ordena e pede as permissões (Android/iOS). |
| [`ble_service.dart`](./lib/data/services/ble_service.dart) | Scan, conexão e operações GATT (ler, escrever, notificar). |
| [`ble_platform.dart`](./lib/data/services/ble_platform.dart) | Wrapper sem lógica das chamadas estáticas, para permitir mocks. |

**Erros:** `BleException` (Bluetooth desligado, falha ao conectar, característica sem suporte) e `BlePermissionException` (permissões negadas). Ambos chegam à UI em `BleController.errorMessage`.

**Testes:** cada camada recebe a de baixo por construtor (`BleService({platform})`, `BleRepository({service, platform})`, `BleController({repository})`). Use os mocks de [`test/mocks/mocks.dart`](./test/mocks/mocks.dart). `ble_service`, `ble_repository` e `ble_controller` têm 100% de cobertura; `ble_platform` fica fora (`// coverage:ignore-file`).

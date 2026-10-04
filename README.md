# OmniDesk Mobile

Aplicativo móvel do OmniDesk. Ele pareia com o OmniDesk instalado no seu computador e troca texto da área de transferência, fotos e arquivos entre os dois dispositivos pela rede local (Wi-Fi), sem passar por servidores externos.

> O OmniDesk Mobile é um app companheiro e só é útil com o OmniDesk instalado no computador.

## Funcionalidades

- Pareamento com o computador por QR Code.
- Descoberta de computadores na mesma rede local (Bonjour, `_omnidesk._tcp`).
- Envio e recebimento de texto da área de transferência.
- Envio e recebimento de fotos e arquivos.
- Histórico das transferências.
- Proteção contra eco: um texto recebido não é reenviado de volta ao remetente.

## Como funciona

- O app sobe um servidor HTTP local, na porta `24851` por padrão. Se ela estiver ocupada, usa uma porta livre.
- Os endpoints de clipboard e upload exigem o ID do dispositivo e o token gerados no pareamento. Apenas dispositivos pareados são aceitos.
- Os tokens e o ID ficam no armazenamento seguro do sistema (Keychain no iOS).
- O tráfego acontece só na rede local e usa HTTP sem criptografia. Use em redes em que você confia.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) com Dart `>=3.0.6 <4.0.0`.
- Para iOS: macOS, Xcode e CocoaPods. iOS 15.0 ou superior.
- Para Android: Android SDK.
- O OmniDesk instalado e em execução no computador, na mesma rede Wi-Fi do aparelho.

## Como compilar

```bash
git clone https://github.com/thyagoluciano/OmniDeskMobile.git
cd OmniDeskMobile
flutter pub get
flutter run
```

Para gerar o build de release:

```bash
flutter build ios --release      # iOS
flutter build apk --release      # Android
```

Para rodar os testes:

```bash
flutter test
```

## Permissões

| Permissão | Motivo |
|---|---|
| Câmera | Escanear o QR Code de pareamento. |
| Rede local | Descobrir e conectar aos computadores na mesma rede. |
| Fotos | Selecionar fotos para enviar e salvar fotos recebidas. |

## Publicação na App Store

Quem quiser publicar uma versão própria precisa usar a conta Apple Developer dela. Altere o Bundle ID (`com.omnidesk.omnideskMobile`) e o Team em `ios/Runner.xcodeproj`. Certificados, perfis de provisionamento e chaves da App Store Connect API não fazem parte do repositório e nunca devem ser commitados.

## Contribuindo

Issues e pull requests são bem-vindos. Antes de abrir um PR, rode `flutter analyze` e `flutter test`.

## Licença

Distribuído sob a licença [MIT](LICENSE). O nome e o ícone do OmniDesk pertencem ao autor e não são cobertos pela licença do código.

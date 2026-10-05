# OmniDesk Mobile

<p align="center">
  <img src="assets/icon/app_icon_android.svg" alt="OmniDesk Mobile Logo" width="100" height="100">
</p>

<p align="center">
  <strong>Sincronização P2P de Área de Transferência e Envio de Fotos/Arquivos na Rede Local</strong><br>
  <em>Mobile Companion App for Cross-Platform Local P2P Clipboard Sync & File Sharing</em>
</p>

<p align="center">
  <a href="https://github.com/thyagoluciano/OmniDeskMobile/actions/workflows/ci.yml"><img src="https://github.com/thyagoluciano/OmniDeskMobile/actions/workflows/ci.yml/badge.svg" alt="CI Status"></a>
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter" alt="Flutter"></a>
  <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart" alt="Dart"></a>
  <a href="#"><img src="https://img.shields.io/badge/Plataformas-iOS%20%7C%20Android-blue" alt="Plataformas"></a>
  <a href="https://github.com/thyagoluciano/OmniDesk"><img src="https://img.shields.io/badge/Desktop-OmniDesk-purple?logo=go" alt="Desktop Repo"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="Licença"></a>
  <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-bem--vindos-brightgreen.svg" alt="Contribuições"></a>
</p>

<p align="center">
  <strong>🇧🇷 Português</strong> &nbsp;•&nbsp;
  <a href="README.en.md">🇺🇸 English</a>
</p>

<p align="center">
  <a href="#-o-que-é-o-omnidesk-mobile">O que é</a> &nbsp;•&nbsp;
  <a href="#-o-ecossistema-omnidesk">Ecossistema</a> &nbsp;•&nbsp;
  <a href="#-recursos-principais">Recursos</a> &nbsp;•&nbsp;
  <a href="#-como-funciona-o-pareamento">Pareamento</a> &nbsp;•&nbsp;
  <a href="#-como-compilar-e-executar">Como Compilar</a> &nbsp;•&nbsp;
  <a href="#-permissões-do-sistema">Permissões</a> &nbsp;•&nbsp;
  <a href="#-comunidade-e-contribuição">Contribuição</a>
</p>

---

## 📱 O que é o OmniDesk Mobile?

O **OmniDesk Mobile** é o aplicativo móvel oficial do ecossistema [OmniDesk](https://github.com/thyagoluciano/OmniDesk). Desenvolvido em **Flutter** para **iOS e Android**, ele conecta seu smartphone diretamente aos seus computadores (Linux, macOS e Windows) através da sua rede Wi-Fi local.

> [!NOTE]
> O OmniDesk Mobile é o aplicativo companheiro do [OmniDesk Desktop](https://github.com/thyagoluciano/OmniDesk). Para usufruir de todas as funcionalidades, você deve ter o OmniDesk instalado e em execução no seu computador na mesma rede Wi-Fi.

Diferente de soluções proprietárias ou baseadas na nuvem, o OmniDesk Mobile opera de forma **100% P2P e local**:

- 🔒 **Zero Nuvem e Privacidade Total**: Nenhum texto, link, foto ou arquivo passa por servidores externos ou pela nuvem. Tudo permanece estritamente na sua rede local.
- ⚡ **Velocidade Máxima da Rede Wi-Fi**: Transferências diretas entre aparelho e computador sem estrangulamento de upload de internet.
- 🛡️ **Tokens Seguros**: Credenciais de pareamento e identificadores salvos no armazenamento protegido do hardware (iOS Keychain e Android EncryptedSharedPreferences).
- 🚫 **Zero Telemetria**: Sem rastreadores, analytics invasivos ou coletas de dados em segundo plano.

---

## 🌐 O Ecossistema OmniDesk

O OmniDesk foi concebido para unir seus dispositivos de forma simples e segura na rede local:

| Projeto | Plataformas | Tecnologias | Descrição |
| :--- | :--- | :--- | :--- |
| 🖥️ **[OmniDesk](https://github.com/thyagoluciano/OmniDesk)** | Linux, macOS, Windows | Go, Web Dashboard, Tray Nativo | Motor desktop: daemon de sincronização, KVM/input share, CLI e servidor P2P. |
| 📱 **OmniDesk Mobile** *(Este repositório)* | iOS, Android | Flutter, Dart, Criptografia Nativa | App móvel: pareamento via QR Code, compartilhamento de fotos, arquivos e clipboard. |

### Diagrama de Comunicação:

```
 ┌───────────────────────────────┐                  ┌───────────────────────────────┐
 │       OmniDesk Desktop        │                  │        OmniDesk Mobile        │
 │    (macOS / Linux / Win)      │                  │        (iOS / Android)        │
 │                               │                  │                               │
 │  • Daemon Go (Porta 24850)    │   Wi-Fi Local    │  • Servidor HTTP (Porta 24851)│
 │  • Painel Web (/ui/)          │◄────────────────►│  • Leitor de QR Code          │
 │  • Gerador de QR Code         │  Bonjour / mDNS  │  • Seletor de Fotos & Arquivos│
 │  • Sincronizador de Clipboard │   Sockets P2P    │  • Armazenamento Seguro       │
 └───────────────────────────────┘                  └───────────────────────────────┘
```

---

## ✨ Recursos Principais

- 📷 **Pareamento em 1 Segundo por QR Code**: Basta apontar a câmera do celular para o código gerado no monitor do computador para estabelecer a conexão de confiança.
- 🔍 **Descoberta Automática na Rede (Bonjour / mDNS)**: Localiza computadores vizinhos executando o OmniDesk (`_omnidesk._tcp`) sem você precisar digitar endereços IP manualmente.
- 📋 **Sincronização de Área de Transferência**: Envie textos copiados no smartphone para o computador e receba conteúdos do computador com notificação imediata.
- 🔁 **Proteção Anti-Echo**: Algoritmo inteligente que impede loops infinitos de cópia entre o computador e o smartphone.
- 📸 **Envio Direto de Fotos e Arquivos**: Selecione fotos da galeria ou documentos e envie diretamente para o computador (salvos na pasta `~/Downloads/OmniDesk`).
- 📥 **Recebimento de Arquivos**: Receba documentos e imagens enviados pelo computador direto no aparelho celular.
- 📜 **Histórico de Transferências**: Feed visual com o histórico dos itens enviados e recebidos na sessão.
- 🚀 **Servidor HTTP Local Leve**: Inicia dinamicamente na porta `24851` (ou na primeira porta livre disponível), autenticando requisições com tokens criptográficos.

---

## 📲 Como Funciona o Pareamento

Parear o celular com o computador é simples e rápido:

```
1. No Computador                  2. No Celular                    3. Conectado!
   ┌──────────────────────┐          ┌──────────────────────┐         ┌──────────────────────┐
   │ Painel Web OmniDesk  │          │ App OmniDesk Mobile  │         │  Sincronização Ativa │
   │                      │          │                      │         │                      │
   │  [ Parear Celular ]  │   ──►    │  [ Escanear QR ]     │   ──►   │  📋 Clipboard OK     │
   │      (QR Code)       │          │  (Aponte a câmera)   │         │  📁 Arquivos OK      │
   └──────────────────────┘          └──────────────────────┘         └──────────────────────┘
```

1. Certifique-se de que o computador e o smartphone estão conectados na **mesma rede Wi-Fi**.
2. No computador, abra o painel web em `http://127.0.0.1:24850/ui/` (ou clique no ícone da bandeja > **Abrir Painel**).
3. Clique no botão **Parear Celular (QR Code)**. Um código QR e um PIN serão exibidos na tela.
4. No seu celular, abra o **OmniDesk Mobile** e toque no botão de **Escanear QR Code**.
5. Aponte a câmera para a tela do computador.
6. Pronto! O app resgata a sessão, valida o token mútuo e conecta instantaneamente.

---

## 🛠️ Como Compilar e Executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) com Dart `>=3.0.6 <4.0.0` (canal `stable`).
- **Para iOS**: macOS com Xcode 15+ e CocoaPods (`sudo gem install cocoapods`). iOS 15.0 ou superior.
- **Para Android**: Android Studio com Android SDK (API 21 ou superior).
- O [OmniDesk Desktop](https://github.com/thyagoluciano/OmniDesk) rodando em uma máquina na mesma rede.

### Clonando e Executando

```bash
# 1. Clonar o repositório
git clone https://github.com/thyagoluciano/OmniDeskMobile.git
cd OmniDeskMobile

# 2. Instalar dependências do Flutter
flutter pub get

# 3. Executar em modo desenvolvimento
# No iOS Simulator ou iPhone conectado:
flutter run -d ios

# No emulador Android ou celular conectado:
flutter run -d android
```

### Qualidade de Código e Testes

Antes de submeter contribuições, certifique-se de que todos os linters e testes passam:

```bash
# Verificar formatação do código
dart format --output=none --set-exit-if-changed .

# Análise estática do linter oficial
flutter analyze

# Executar suíte de testes unitários e de widget
flutter test
```

### Compilação de Release

```bash
# Gerar pacote para Android (APK ou App Bundle):
flutter build apk --release
flutter build appbundle --release

# Gerar build para iOS:
flutter build ios --release
```

---

## 🔒 Permissões do Sistema

O OmniDesk Mobile solicita apenas as permissões estritamente necessárias para a comunicação local:

| Permissão | Finalidade | Plataforma |
| :--- | :--- | :--- |
| **Câmera** | Leitura rápida do QR Code de pareamento exibido na tela do computador. | iOS e Android |
| **Rede Local** | Descoberta e envio de dados P2P via mDNS/Bonjour (`_omnidesk._tcp`) e HTTP. | iOS e Android |
| **Fotos / Mídia** | Permitir ao usuário selecionar fotos da galeria para enviar ao computador. | iOS e Android |

---

## 🤝 Comunidade e Contribuição

Contribuições da comunidade são muito bem-vindas! Seja corrigindo um bug, aprimorando o visual ou sugerindo novas integrações:

- 📖 **[Guia de Contribuição](CONTRIBUTING.md)**: Passos para clonar, configurar ambiente, padrão de commits e checklist de Pull Request.
- 🤝 **[Código de Conduta](CODE_OF_CONDUCT.md)**: Nossas diretrizes de convivência e respeito mútuo.
- 🛡️ **[Política de Segurança](SECURITY.md)**: Como reportar falhas ou vulnerabilidades de forma responsável.
- 🖥️ **[Repositório OmniDesk Desktop](https://github.com/thyagoluciano/OmniDesk)**: O projeto principal do ecossistema.
- 💬 **[Discussões no GitHub](https://github.com/thyagoluciano/OmniDesk/discussions)**: Fórum oficial para dúvidas e sugestões.
- 🐛 **[Abrir uma Issue](https://github.com/thyagoluciano/OmniDeskMobile/issues)**: Relatar falhas ou solicitar funcionalidades para o app mobile.

---

## 📄 Licença

Distribuído sob a licença [MIT](LICENSE) &copy; 2026 Thyago Luciano.  
O nome e os logotipos do OmniDesk pertencem ao autor.

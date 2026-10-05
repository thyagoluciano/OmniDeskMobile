# Contributing to OmniDesk Mobile

Thank you for your interest in contributing to **OmniDesk Mobile**! :tada: :sparkles:

OmniDesk Mobile is the open-source mobile companion app for [OmniDesk](https://github.com/thyagoluciano/OmniDesk), built with Flutter and Dart. It enables instant, secure, local-network clipboard synchronization and photo/file transfers between mobile devices (iOS & Android) and desktop workstations (Linux, macOS & Windows).

We welcome contributions of all kinds: code, bug fixes, UI/UX polish, documentation improvements, translations, and architectural ideas.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Our Core Philosophy](#our-core-philosophy)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features & Enhancements](#suggesting-features--enhancements)
  - [Documentation & Translations](#documentation--translations)
  - [Code Contributions](#code-contributions)
- [Development Setup](#development-setup)
  - [Prerequisites](#prerequisites)
  - [Cloning & Running Locally](#cloning--running-locally)
  - [Running Static Analysis & Tests](#running-static-analysis--tests)
- [Project Architecture](#project-architecture)
- [Development Workflow & Standards](#development-workflow--standards)
  - [Branch Naming](#branch-naming)
  - [Conventional Commits](#conventional-commits)
  - [Code Style & Formatting](#code-style--formatting)
  - [Mobile Security & Privacy Guidelines](#mobile-security--privacy-guidelines)
- [Pull Request Process](#pull-request-process)
- [Community & Getting Help](#community--getting-help)

---

## Code of Conduct

All contributors and maintainers are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before participating in discussions or submitting pull requests.

---

## Our Core Philosophy

When proposing changes or writing code, keep OmniDesk's core tenets in mind:

1. **100% Local-First & Zero Cloud**: Data, clipboard contents, and files must never leave the local Wi-Fi / LAN network. No external telemetries, cloud analytics, or third-party servers.
2. **Privacy & Security by Default**: Tokens, secrets, and pairing credentials must only be stored in hardware-backed secure storage (Keychain on iOS / EncryptedSharedPreferences on Android).
3. **Cross-Platform Parity**: The mobile app must deliver a consistent, beautiful, and intuitive experience on both iOS and Android.
4. **Lightweight & Battery Efficient**: Mobile devices run on limited battery and system resources. Avoid continuous background polling and minimize unnecessary CPU wakeups.

---

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check existing [GitHub Issues](https://github.com/thyagoluciano/OmniDeskMobile/issues) to avoid duplicates.

If you encounter a new bug, please open an issue using the **[Bug Report Template](https://github.com/thyagoluciano/OmniDeskMobile/issues/new?template=bug_report.yml)**. Please include:
- A clear, concise title.
- Step-by-step reproduction steps.
- Expected vs. actual behavior.
- Device model, platform, and OS version (e.g., iPhone 15 Pro on iOS 17.5, Samsung Galaxy S23 on Android 14).
- Flutter version (`flutter --version`).
- Logs from `flutter run` or console output.

### Suggesting Features & Enhancements

We are eager to hear ideas for improving OmniDesk Mobile! To propose a new feature:
1. Open a feature request via the **[Feature Request Template](https://github.com/thyagoluciano/OmniDeskMobile/issues/new?template=feature_request.yml)**.
2. Explain the problem your feature solves and how it fits our local-first, zero-cloud architecture.

### Documentation & Translations

Help us make OmniDesk Mobile accessible to everyone:
- Improve documentation, inline docstrings, or tutorials.
- Enhance or add translations (Portuguese, English, Spanish).
- Create troubleshooting guides for specific mobile manufacturers (e.g., aggressive battery savers on Xiaomi/Huawei).

---

## Development Setup

### Prerequisites

- **Flutter SDK**: Dart `>=3.0.6 <4.0.0` (Stable channel recommended) — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Git**
- **Platform-Specific Toolchains**:
  - **For iOS**: macOS with Xcode, CocoaPods (`sudo gem install cocoapods`), and command-line tools.
  - **For Android**: Android Studio with Android SDK & command-line tools.
- A running instance of [OmniDesk Desktop](https://github.com/thyagoluciano/OmniDesk) on your local Wi-Fi for end-to-end testing.

### Cloning & Running Locally

1. **Fork** the repository on GitHub: `https://github.com/thyagoluciano/OmniDeskMobile`
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/OmniDeskMobile.git
   cd OmniDeskMobile
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/thyagoluciano/OmniDeskMobile.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```
5. **Run the application**:
   ```bash
   # In an iOS Simulator or connected iPhone
   flutter run -d ios

   # In an Android Emulator or connected Android phone
   flutter run -d android
   ```

### Running Static Analysis & Tests

Before opening a pull request, verify that the analyzer and test suite pass without issues:

```bash
# 1. Check code formatting
dart format --output=none --set-exit-if-changed .

# 2. Run static analysis (linter)
flutter analyze

# 3. Run all unit and widget tests
flutter test
```

---

## Project Architecture

A high-level overview of the repository structure:

```text
OmniDeskMobile/
├── lib/
│   ├── core/
│   │   ├── anti_echo/        # Clipboard echo loop prevention
│   │   ├── models/           # Shared domain models (Device, Peer)
│   │   ├── network/          # Local HTTP server (port 24851) & API client
│   │   └── storage/          # Secure hardware storage (Keychain / EncryptedPrefs)
│   ├── features/
│   │   ├── clipboard/        # Clipboard listening, reading and broadcasting
│   │   ├── pairing/          # QR scanner screen, pairing verification and payload models
│   │   └── transfers/        # Direct file, photo and payload transfers
│   ├── ui/
│   │   ├── screens/          # Main navigation tabs (Devices, Transfers, Home)
│   │   └── widgets/          # Reusable UI cards and feed components
│   └── main.dart             # Application initialization and provider bootstrapping
├── test/                     # Unit and widget test suites
├── assets/                   # Vector icons and app branding
├── store-assets/             # App Store and Google Play graphic assets
├── ios/                      # Native iOS project configuration & runner
└── android/                  # Native Android project configuration & Gradle scripts
```

---

## Development Workflow & Standards

### Branch Naming

Create a feature branch with a descriptive name prefixed by the change type:

- `feat/feature-name` (e.g., `feat/dark-mode-theme`)
- `fix/issue-description` (e.g., `fix/qr-scanner-camera-permission`)
- `docs/doc-update` (e.g., `docs/ios-pairing-guide`)
- `refactor/subsystem-name` (e.g., `refactor/transfer-service`)
- `test/test-name` (e.g., `test/clipboard-anti-echo`)
- `chore/task-name` (e.g., `chore/bump-dependencies`)

### Conventional Commits

We follow the **[Conventional Commits specification](https://www.conventionalcommits.org/)**. Each commit message must be structured as follows:

```text
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

#### Allowed Types:
- **`feat`**: A new user-facing feature or enhancement.
- **`fix`**: A bug fix.
- **`docs`**: Documentation changes only.
- **`style`**: Changes that do not affect code meaning (formatting, whitespace).
- **`refactor`**: Code changes that neither fix a bug nor add a feature.
- **`perf`**: A code change that improves performance or battery efficiency.
- **`test`**: Adding missing tests or correcting existing tests.
- **`chore`**: Build scripts, CI workflow changes, dependency upgrades.

#### Examples:
```text
feat(pairing): add vibration feedback upon successful QR scan
fix(transfers): handle photo picker cancellation gracefully
docs: update Android local network permission troubleshooting
test(storage): add mock test for secure token persistence
```

### Code Style & Formatting

- Follow official [Effective Dart](https://dart.dev/effective-dart) guidelines.
- Always format code before committing using:
  ```bash
  dart format .
  ```
- Keep widgets concise, modular, and reusable.
- Prefer explicit typing on public APIs and parameters.

### Mobile Security & Privacy Guidelines

- **Never log sensitive data**: Do not print auth tokens, device PINs, or raw clipboard content to the console.
- **Never commit secrets**: Signing keystores, provision profiles, `key.properties`, and `AuthKey_*.p8` must NEVER be committed to Git.
- **Adhere to OS privacy requirements**: When requesting Camera, Photos, or Local Network permissions, explain the exact purpose in `Info.plist` and `AndroidManifest.xml`.

---

## Pull Request Process

1. **Keep PRs Focused**: A PR should address a single concern, bug, or feature.
2. **Run Analysis and Tests**: Ensure `flutter analyze` and `flutter test` pass with 0 errors and 0 warnings.
3. **Update Documentation**: If your PR modifies UI flows, permissions, or dependencies, update the README or relevant docs.
4. **Fill Out the PR Template**: Complete all sections of [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md).
5. **Code Review**: A maintainer will review your code and provide constructive feedback.

---

## Community & Getting Help

- **Discussions**: Use [GitHub Discussions](https://github.com/thyagoluciano/OmniDesk/discussions) (hosted on the main OmniDesk repository) for overarching ideas and community support.
- **Desktop Companion**: [OmniDesk Desktop Repository](https://github.com/thyagoluciano/OmniDesk)
- **Security Vulnerabilities**: See [SECURITY.md](SECURITY.md).
- **Maintainer**: Thyago Luciano ([@thyagoluciano](https://github.com/thyagoluciano)) - `thyagoluciano@gmail.com`.

Thank you for helping make OmniDesk Mobile even better! :rocket:

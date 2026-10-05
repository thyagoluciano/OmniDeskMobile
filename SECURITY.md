# Security Policy

The OmniDesk Mobile project takes privacy and security seriously. As the mobile companion to [OmniDesk](https://github.com/thyagoluciano/OmniDesk), it handles sensitive data like clipboard contents, photos, and files strictly over your local area network (LAN) without cloud servers.

## Supported Versions

Only the latest release of OmniDesk Mobile receives security updates and vulnerability patches.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0.0 | :x:                |

## Security Architecture & Best Practices

1. **Local Network Isolation**: OmniDesk Mobile does not connect to external third-party cloud servers or sync data over the public internet.
2. **Mutual Pairing Validation**: Communication endpoints only accept requests authenticated with cryptographic tokens created during mutual pairing.
3. **Secure Hardware Storage**: Sensitive device identifiers and authorization tokens are stored in the platform's hardware-backed secure storage (iOS Keychain and Android EncryptedSharedPreferences).
4. **Zero Telemetry**: No crash analytics, analytics SDKs, or background tracking are embedded in the app.

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities through public GitHub issues, discussions, or social media.**

Instead, report vulnerabilities privately through one of the following channels:

1. **GitHub Private Vulnerability Reporting (Recommended)**:
   Navigate to the [OmniDesk Mobile Security Advisories page](https://github.com/thyagoluciano/OmniDeskMobile/security/advisories/new) and submit a private draft advisory.

2. **Direct Email**:
   Send an encrypted or direct email to **thyagoluciano@gmail.com** with the subject:
   `[SECURITY] Vulnerability in OmniDesk Mobile: <Brief Description>`.

### What to Include in Your Report

To help us triage and resolve the issue quickly, please include:
- A clear description of the vulnerability.
- Steps to reproduce the issue (proof of concept, network packet details, or reproduction code).
- Target platform and OS version (e.g., iOS 17.5 iPhone 15 Pro, Android 14 Pixel 8).
- Any suggested mitigations or patches, if available.

### What to Expect

- **Acknowledgment**: You will receive an initial response within **48 hours** confirming receipt of your report.
- **Triage & Status**: We will keep you informed of our progress as we investigate and develop a fix.
- **Coordinated Disclosure**: We aim to release a patch within **14 to 30 days** depending on complexity, and will credit you in the release notes and advisory (unless you prefer to remain anonymous).

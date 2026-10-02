# Demo Certificate Signer

A TypeScript service for demonstrating BSV certificate issuance. It authenticates a wallet, decrypts the submitted certificate fields and signs a certificate using a server-held wallet.

This is a demonstration certifier. It does not independently verify the truth of the submitted claims, so its signature must not be treated as evidence of age, identity or eligibility.

## How it works

1. A wallet sends an authenticated request to `POST /signCertificate`.
2. The service decrypts the supplied fields and constructs the certificate serial number.
3. The server wallet creates a one-satoshi revocation output and signs the certificate.
4. The response contains `certificate` and `serverNonce` for the acquisition flow.

Issuance creates real wallet transactions and incurs fees. Use a dedicated, funded demonstration wallet and a storage provider for the selected network.

## Run locally

Use Node.js 22 and npm. From the repository root:

```sh
npm ci
cp .env.example .env
```

Configure `.env` before starting the service:

| Variable | Purpose |
| --- | --- |
| `SERVER_PRIVATE_KEY` | Your server wallet's hexadecimal private key. Keep it private and stable across restarts. |
| `WALLET_STORAGE_URL` | Wallet storage provider URL for the selected network. |
| `CHAIN` | `main` or `test`. |
| `FLOAT_BALANCE_TOKEN` | Optional bearer token for the additional balance endpoint. Leave unset when unused. |

```sh
npm run dev
```

The service listens on port **8080**. The current code does not use the `PORT` or `LOG_LEVEL` entries in the example environment file.

Call the signing endpoint through a compatible wallet's certificate acquisition and authentication flow. A plain unauthenticated HTTP request is insufficient. This repository does not include a browser interface.

## Build and containers

```sh
npm run build
npm start
```

TypeScript compiles to `dist/`. The `test` script is a placeholder and exits with an error.

The [Dockerfile](Dockerfile) uses a BuildKit secret named `github_token` to configure GitHub Packages access. The supplied Compose build does not declare that secret, so configure it before using the container setup.

Authentication middleware also runs before `GET /health`. The container's unauthenticated health probe needs to be reconciled with that middleware before relying on it for deployment health checks.

## Source guide

- [index.ts](index.ts): wallet initialisation, middleware and routes.
- [signCertificate.ts](signCertificate.ts): field decryption, revocation output and signing.
- [.env.example](.env.example): configuration template.

## Licence

**Declared licence: ISC.** See [package.json](package.json). No standalone licence file is included in this repository.

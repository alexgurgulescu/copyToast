# Security

## Official download

The only official copyToast download is:

https://github.com/alexgurgulescu/copyToast/releases/latest/download/copyToast.dmg

copyToast is not notarized by Apple, so macOS asks you to choose **Open Anyway** the first time. Only do this for a copy you downloaded from the link above. Never open a copy from another website, a message, or a file-sharing link.

## Verify a download

From version 0.1.1, each release is built from this repository's public source by GitHub Actions and locked after publishing.

If you have the [GitHub CLI](https://cli.github.com), check that your file came from that build:

```bash
gh attestation verify copyToast.dmg --repo alexgurgulescu/copyToast
```

You can also compare its SHA-256 checksum with the `copyToast.dmg.sha256` file on the [release page](https://github.com/alexgurgulescu/copyToast/releases/latest):

```bash
shasum -a 256 copyToast.dmg
```

## Supported versions

Security fixes are made for the latest release only.

## Report a vulnerability

Please report security problems privately through [GitHub's vulnerability reporting](https://github.com/alexgurgulescu/copyToast/security/advisories/new). Do not open a public issue.

Include what you found, how to reproduce it, and the copyToast and macOS versions involved. This is a free project maintained by one person, so responses are best effort, and there is no bug bounty.

If you find a fake copy of copyToast, please report it the same way.

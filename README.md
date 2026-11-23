# copyToast

A tiny macOS menu bar app that confirms what you just copied in Finder with a short, unobtrusive toast.

Finder gives no feedback when you press ⌘C. copyToast shows a small message such as **3 files copied**, then gets out of your way.

## What it shows

| You copy | Toast |
| --- | --- |
| One file | File copied |
| Several files | 3 files copied |
| One folder | Folder copied |
| Several folders | 2 folders copied |
| Files and folders | 3 files and 2 folders copied |
| One path (⌥⌘C) | Path copied |
| Several paths (⌥⌘C) | 4 paths copied |

Other text, such as part of a file name while renaming, shows nothing.

## Features

- Lives in the menu bar, with no Dock icon
- Works with Copy (⌘C) and Copy as Pathname (⌥⌘C)
- Never takes focus, and clicks pass through the toast
- Adapts to light and dark mode
- Respects Reduce Motion
- Stays out of screenshots and screen sharing, although some recording apps may not honor this
- Menu options for Pause, Launch at Login, About, and Quit

## Privacy

copyToast is designed to know as little as possible:

- **No network access.** The App Sandbox is on without the network permission.
- **No keyboard monitoring.** It reacts only to clipboard changes and needs no Accessibility or Input Monitoring permission.
- **Minimal clipboard reading.** It inspects the clipboard only when it changes while Finder is the frontmost app. It counts items and never displays or keeps their contents.
- **No storage, logs, or analytics.**
- **Skips sensitive copies.** Items that password managers mark as concealed are ignored.
- **No third-party dependencies.**

macOS may ask whether copyToast can paste from other apps. Choose **Allow** so it can count what you copied.

## Requirements

- macOS 15.4 or later
- Xcode 16 or later, to build from source
- A free Apple Development certificate, which you can create in Xcode under Settings → Apple Accounts → Manage Certificates

## Build and install

```bash
git clone https://github.com/alexgurgulescu/copyToast.git
cd copyToast
./scripts/build.sh
cp -R build/copyToast.app /Applications/
open /Applications/copyToast.app
```

Look for the toast icon in your menu bar. Install the app in Applications before turning on **Launch at Login**.

## Development

```bash
swift test                    # Run the tests
./scripts/build.sh            # Build and sign build/copyToast.app
swift scripts/make-icon.swift # Regenerate the app icon
```

A manual test checklist is in [TESTING.md](TESTING.md).

## License

copyToast is free for private and commercial use under the [MIT License](LICENSE). Please keep the copyright and license notice in copies of the software.

The coffee icon is from [Lucide](https://lucide.dev), under the ISC License. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

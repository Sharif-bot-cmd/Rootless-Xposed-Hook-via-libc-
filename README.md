# Rootless Xposed Hook Plugin for AxManager

**Injects Xposed modules into running apps without root** — works with both self-patched (UI/config) and standalone (headless) modules.

## Overview

This AxManager plugin creates a persistent injection environment that loads Xposed modules into user apps at runtime. It works through AxManager's ADB privileges, requiring **no root access** and **no bootloader unlock**.

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│  AxManager (ADB Environment)                           │
│       ↓                                                 │
│  LD_PRELOAD + ptrace injection                         │
│       ↓                                                 │
│  Libc hooks (openat, strcmp, connect, SSL_*, etc.)     │
│       ↓                                                 │
│  Broadcast intents to Xposed modules                   │
│       ↓                                                 │
│  Modules inject into target apps                       │
└─────────────────────────────────────────────────────────┘
```

## Module Compatibility

| Module Type | Works? | Example |
| :--- | :--- | :--- |
| **Self-patched (with UI/config)** | Yes | Core Patch, IAmNotADeveloper, Spoof My Device |
| **Standalone/headless (no UI)** | Yes | SSL Bypass, Bootloader Spoofer, FakeGapps |

Self-patched modules (via LSPatch) provide UI and configuration storage. Headless modules work directly through libc hooks.

## Included Modules (Default Configuration)

| Module | Package | Type | Purpose |
| :--- | :--- | :--- | :--- |
| Core Patch | `com.coderstory.toolkit` | Self-patched | APK signature verification bypass |
| Spoof My Device | `com.spoofmydevice` | Self-patched | Device fingerprint spoofing |
| SSL Bypass | `com.winnersonx.sslbypass` | Headless | Certificate pinning bypass |
| Bootloader Spoofer | `es.chiteroman.bootloaderspoofer` | Headless | Bootloader state hiding |
| IAmNotADeveloper | `top.ltfan.notdeveloper` | Self-patched | Developer mode hiding |
| NoVPNDetect Enhanced | `ru.bluecat.novpndetectenhanced` | Headless | VPN detection bypass |
| FakeGapps | `inc.whew.android.fakegapps` | Headless | Google API response faking |
| FuckGoogleLicense | `com.jiguro.fuckgoogle` | Headless | License verification bypass |

*Edit `module.prop` and `customize.sh` to add/remove modules.*

## Libc Hooks Used

```
openat, execve, dlopen, strstr, strcmp, connect,
SSL_read, SSL_write, access, stat,
__system_property_read, pipe, socket, ioctl
```

## Requirements

- AxManager with active ADB environment
- Target Xposed modules installed (self-patched via LSPatch if they need UI)
- Android 9+

## Installation

1. Place the module folder in AxManager's plugins directory
2. Enable the plugin in AxManager
3. Reboot or start the service manually

## Configuration

Edit `module.prop` to modify:
- `inject.modules` — Module injection order
- `inject.*.package` — Package names for each module

Edit `customize.sh` to change:
- Injection thresholds
- Libc hook configuration
- Module verification logic

## Status & Logs

```bash
# Check injection status
cat /data/local/tmp/spoof_injector_status.json

# View injection log
cat /data/local/tmp/spoof_injector.log

# Check libc hook activity
cat /data/local/tmp/spoof_injector/libc_hooks.log
```

## Uninstall

Disable the plugin in AxManager, then run:
```bash
sh /data/local/tmp/spoof_injector/uninstall.sh
```

## Notes

- Modules are **not auto-started** — launch them manually after boot
- The plugin injects into **user apps only** (not system_server)
- Works with GMS disabled, no Google account required
- Injection order matters — configure carefully

## Credits

- LSPatch (JingMatrix) — Rootless LSPosed framework
- AxManager — ADB environment provider
- Individual module developers

## License

Apache 2.0

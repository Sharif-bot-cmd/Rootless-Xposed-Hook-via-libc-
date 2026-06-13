#!/system/bin/sh
MODPATH="${0%/*}"
MODULE_ID="spoof_injector"
LOG_FILE="/data/local/tmp/${MODULE_ID}.log"
CONFIG_DIR="/data/local/tmp/${MODULE_ID}"

log_print() { echo "[$(date)] $1" >> "$LOG_FILE"; }

log_print "=== Uninstalling 8-Module Injector ==="

# Kill all running processes
pkill -f "inject_modules.sh" 2>/dev/null
pkill -f "libc_hook_redirect.sh" 2>/dev/null
pkill -f "monitor_injection" 2>/dev/null

# Remove PID files
rm -f "$CONFIG_DIR/inject.pid" 2>/dev/null
rm -f "$CONFIG_DIR/redirect.pid" 2>/dev/null
rm -f "$CONFIG_DIR/monitor.pid" 2>/dev/null

# Remove configuration directory
rm -rf "$CONFIG_DIR" 2>/dev/null

# Clear environment variables (these will reset on reboot anyway)
unset LD_PRELOAD
unset LIBC_HOOKS

log_print "8-Module Injector uninstalled successfully"
log_print "Modules removed: Core Patch, Spoof My Device, SSL Bypass, Bootloader Spoofer, IAmNotADeveloper, NoVPNDetect Enhanced, FakeGapps, FuckGoogleLicense"
log_print "========================================="

echo "========================================"
echo "8-Module Injector Uninstalled"
echo "========================================"
echo "Removed:"
echo "  - Core Patch"
echo "  - Spoof My Device"
echo "  - SSL Bypass"
echo "  - Bootloader Spoofer"
echo "  - IAmNotADeveloper"
echo "  - NoVPNDetect Enhanced"
echo "  - FakeGapps"
echo "  - FuckGoogleLicense"
echo ""
echo "Log: $LOG_FILE"
echo "========================================"

exit 0

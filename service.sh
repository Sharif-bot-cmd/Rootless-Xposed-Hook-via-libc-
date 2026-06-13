#!/system/bin/sh
MODPATH="${0%/*}"
MODULE_ID="spoof_injector"
LOG_FILE="/data/local/tmp/${MODULE_ID}.log"
CONFIG_DIR="/data/local/tmp/${MODULE_ID}"
COREPATCH_PACKAGE="com.coderstory.toolkit"
SPOOFMYDEVICE_PACKAGE="com.spoofmydevice"
SSLBYPASS_PACKAGE="com.winnersonx.sslbypass"
BOOTLOADERSPOOFER_PACKAGE="es.chiteroman.bootloaderspoofer"
IAMNOTADEVELOPER_PACKAGE="top.ltfan.notdeveloper"
NOVPNDETECT_PACKAGE="ru.bluecat.novpndetectenhanced"
FAKEGAPPS_PACKAGE="inc.whew.android.fakegapps"
FUCKGOOGLE_PACKAGE="com.jiguro.fuckgoogle"

log_print() { echo "[$(date)] $1" >> "$LOG_FILE"; }

log_print "=== 8-Module Injector Service Starting ==="

# Check if modules are installed (don't start them)
check_modules_installed() {
    local installed=0
    
    pm list packages | grep -q "$COREPATCH_PACKAGE" && { log_print "✓ Core Patch found"; installed=$((installed+1)); } || log_print "⚠️ Core Patch not installed"
    pm list packages | grep -q "$SPOOFMYDEVICE_PACKAGE" && { log_print "✓ Spoof My Device found"; installed=$((installed+1)); } || log_print "⚠️ Spoof My Device not installed"
    pm list packages | grep -q "$SSLBYPASS_PACKAGE" && { log_print "✓ SSL Bypass found"; installed=$((installed+1)); } || log_print "⚠️ SSL Bypass not installed"
    pm list packages | grep -q "$BOOTLOADERSPOOFER_PACKAGE" && { log_print "✓ Bootloader Spoofer found"; installed=$((installed+1)); } || log_print "⚠️ Bootloader Spoofer not installed"
    pm list packages | grep -q "$IAMNOTADEVELOPER_PACKAGE" && { log_print "✓ IAmNotADeveloper found"; installed=$((installed+1)); } || log_print "⚠️ IAmNotADeveloper not installed"
    pm list packages | grep -q "$NOVPNDETECT_PACKAGE" && { log_print "✓ NoVPNDetect Enhanced found"; installed=$((installed+1)); } || log_print "⚠️ NoVPNDetect Enhanced not installed"
    pm list packages | grep -q "$FAKEGAPPS_PACKAGE" && { log_print "✓ FakeGapps found"; installed=$((installed+1)); } || log_print "⚠️ FakeGapps not installed"
    pm list packages | grep -q "$FUCKGOOGLE_PACKAGE" && { log_print "✓ FuckGoogleLicense found"; installed=$((installed+1)); } || log_print "⚠️ FuckGoogleLicense not installed"
    
    log_print "Found $installed/8 modules installed"
    return $installed
}

# Get PIDs without starting apps
get_module_pids() {
    local corepatch_pid=$(pidof "$COREPATCH_PACKAGE" 2>/dev/null | awk '{print $1}')
    local spoof_pid=$(pidof "$SPOOFMYDEVICE_PACKAGE" 2>/dev/null | awk '{print $1}')
    local sslbypass_pid=$(pidof "$SSLBYPASS_PACKAGE" 2>/dev/null | awk '{print $1}')
    local bootloaderspoofer_pid=$(pidof "$BOOTLOADERSPOOFER_PACKAGE" 2>/dev/null | awk '{print $1}')
    local iamnotadeveloper_pid=$(pidof "$IAMNOTADEVELOPER_PACKAGE" 2>/dev/null | awk '{print $1}')
    local novpndetect_pid=$(pidof "$NOVPNDETECT_PACKAGE" 2>/dev/null | awk '{print $1}')
    local fakegapps_pid=$(pidof "$FAKEGAPPS_PACKAGE" 2>/dev/null | awk '{print $1}')
    local fuckgoogle_pid=$(pidof "$FUCKGOOGLE_PACKAGE" 2>/dev/null | awk '{print $1}')
    
    [ -n "$corepatch_pid" ] && log_print "Core Patch running (PID: $corepatch_pid)"
    [ -n "$spoof_pid" ] && log_print "Spoof My Device running (PID: $spoof_pid)"
    [ -n "$sslbypass_pid" ] && log_print "SSL Bypass running (PID: $sslbypass_pid)"
    [ -n "$bootloaderspoofer_pid" ] && log_print "Bootloader Spoofer running (PID: $bootloaderspoofer_pid)"
    [ -n "$iamnotadeveloper_pid" ] && log_print "IAmNotADeveloper running (PID: $iamnotadeveloper_pid)"
    [ -n "$novpndetect_pid" ] && log_print "NoVPNDetect running (PID: $novpndetect_pid)"
    [ -n "$fakegapps_pid" ] && log_print "FakeGapps running (PID: $fakegapps_pid)"
    [ -n "$fuckgoogle_pid" ] && log_print "FuckGoogleLicense running (PID: $fuckgoogle_pid)"
    
    echo "$corepatch_pid:$spoof_pid:$sslbypass_pid:$bootloaderspoofer_pid:$iamnotadeveloper_pid:$novpndetect_pid:$fakegapps_pid:$fuckgoogle_pid"
}

# Set up LD_PRELOAD
setup_ld_preload() {
    local preload_libs=""
    
    for hook in corepatch_hook spoofmydevice_hook sslbypass_hook bootloaderspoofer_hook iamnotadeveloper_hook novpndetect_hook fakegapps_hook fuckgoogle_hook; do
        if [ -f "/data/local/tmp/lspatch/${hook}.so" ]; then
            preload_libs="/data/local/tmp/lspatch/${hook}.so:$preload_libs"
            log_print "${hook} library found"
        fi
    done
    
    if [ -n "$preload_libs" ]; then
        export LD_PRELOAD="$preload_libs"
        log_print "LD_PRELOAD configured"
    fi
    
    export LIBC_HOOKS="openat,execve,dlopen,strstr,strcmp,connect,SSL_read,SSL_write,access,stat,__system_property_read,pipe,socket,ioctl"
    log_print "Libc hooks configured"
}

# Start injection service
start_injection() {
    if ! check_modules_installed >/dev/null 2>&1; then
        log_print "ERROR: No modules found, injection disabled"
        return 1
    fi
    
    local pids=$(get_module_pids)
    local corepatch_pid=$(echo "$pids" | cut -d: -f1)
    local spoof_pid=$(echo "$pids" | cut -d: -f2)
    local sslbypass_pid=$(echo "$pids" | cut -d: -f3)
    local bootloaderspoofer_pid=$(echo "$pids" | cut -d: -f4)
    local iamnotadeveloper_pid=$(echo "$pids" | cut -d: -f5)
    local novpndetect_pid=$(echo "$pids" | cut -d: -f6)
    local fakegapps_pid=$(echo "$pids" | cut -d: -f7)
    local fuckgoogle_pid=$(echo "$pids" | cut -d: -f8)
    
    local running_count=0
    [ -n "$corepatch_pid" ] && running_count=$((running_count + 1))
    [ -n "$spoof_pid" ] && running_count=$((running_count + 1))
    [ -n "$sslbypass_pid" ] && running_count=$((running_count + 1))
    [ -n "$bootloaderspoofer_pid" ] && running_count=$((running_count + 1))
    [ -n "$iamnotadeveloper_pid" ] && running_count=$((running_count + 1))
    [ -n "$novpndetect_pid" ] && running_count=$((running_count + 1))
    [ -n "$fakegapps_pid" ] && running_count=$((running_count + 1))
    [ -n "$fuckgoogle_pid" ] && running_count=$((running_count + 1))
    
    if [ $running_count -eq 0 ]; then
        log_print "WARNING: No module processes running"
        log_print "Injection will occur when modules are started by user"
    else
        log_print "Found $running_count/8 active module process(es)"
    fi
    
    sh "$CONFIG_DIR/inject_modules.sh" &
    INJECT_PID=$!
    log_print "Injector started (PID: $INJECT_PID)"
    
    sh "$CONFIG_DIR/libc_hook_redirect.sh" &
    REDIRECT_PID=$!
    log_print "Libc hook redirect started (PID: $REDIRECT_PID)"
    
    echo "$INJECT_PID" > "$CONFIG_DIR/inject.pid"
    echo "$REDIRECT_PID" > "$CONFIG_DIR/redirect.pid"
    
    return 0
}

# Monitor injection
monitor_injection() {
    while true; do
        sleep 60
        
        if [ -f "$CONFIG_DIR/inject.pid" ]; then
            INJECT_PID=$(cat "$CONFIG_DIR/inject.pid")
            if ! kill -0 "$INJECT_PID" 2>/dev/null; then
                log_print "Injector died, restarting..."
                sh "$CONFIG_DIR/inject_modules.sh" &
                echo $! > "$CONFIG_DIR/inject.pid"
            fi
        fi
        
        if [ -f "$CONFIG_DIR/redirect.pid" ]; then
            REDIRECT_PID=$(cat "$CONFIG_DIR/redirect.pid")
            if ! kill -0 "$REDIRECT_PID" 2>/dev/null; then
                log_print "Redirect died, restarting..."
                sh "$CONFIG_DIR/libc_hook_redirect.sh" &
                echo $! > "$CONFIG_DIR/redirect.pid"
            fi
        fi
        
        local corepatch_pid=$(pidof "$COREPATCH_PACKAGE" 2>/dev/null | awk '{print $1}')
        local spoof_pid=$(pidof "$SPOOFMYDEVICE_PACKAGE" 2>/dev/null | awk '{print $1}')
        local sslbypass_pid=$(pidof "$SSLBYPASS_PACKAGE" 2>/dev/null | awk '{print $1}')
        local bootloaderspoofer_pid=$(pidof "$BOOTLOADERSPOOFER_PACKAGE" 2>/dev/null | awk '{print $1}')
        local iamnotadeveloper_pid=$(pidof "$IAMNOTADEVELOPER_PACKAGE" 2>/dev/null | awk '{print $1}')
        local novpndetect_pid=$(pidof "$NOVPNDETECT_PACKAGE" 2>/dev/null | awk '{print $1}')
        local fakegapps_pid=$(pidof "$FAKEGAPPS_PACKAGE" 2>/dev/null | awk '{print $1}')
        local fuckgoogle_pid=$(pidof "$FUCKGOOGLE_PACKAGE" 2>/dev/null | awk '{print $1}')
        
        if [ -n "$corepatch_pid" ] || [ -n "$spoof_pid" ] || [ -n "$sslbypass_pid" ] || \
           [ -n "$bootloaderspoofer_pid" ] || [ -n "$iamnotadeveloper_pid" ] || \
           [ -n "$novpndetect_pid" ] || [ -n "$fakegapps_pid" ] || [ -n "$fuckgoogle_pid" ]; then
            log_print "Monitor: Core=${corepatch_pid:-none}, Spoof=${spoof_pid:-none}, SSL=${sslbypass_pid:-none}, Bootloader=${bootloaderspoofer_pid:-none}, IAmNotADev=${iamnotadeveloper_pid:-none}, NoVPN=${novpndetect_pid:-none}, FakeGapps=${fakegapps_pid:-none}, FuckGoogle=${fuckgoogle_pid:-none}"
        fi
    done
}

setup_ld_preload

if start_injection; then
    monitor_injection &
    MONITOR_PID=$!
    log_print "Monitor started (PID: $MONITOR_PID)"
    echo "$MONITOR_PID" > "$CONFIG_DIR/monitor.pid"
else
    log_print "ERROR: Injection failed to start"
fi

log_print "8-Module Injector active"
log_print "Modules: IAmNotADeveloper, NoVPNDetect, Bootloader Spoofer, SSL Bypass, Spoof My Device, FakeGapps, FuckGoogleLicense, Core Patch"
log_print "NOTE: This module does NOT auto-start any modules"
log_print "========================================="

cat > "/data/local/tmp/${MODULE_ID}_status.json" << EOF
{
  "status": "active",
  "pid": $$,
  "auto_start_modules": false,
  "modules": {
    "corepatch": { "installed": $(pm list packages | grep -q "$COREPATCH_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$COREPATCH_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") },
    "spoofmydevice": { "installed": $(pm list packages | grep -q "$SPOOFMYDEVICE_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$SPOOFMYDEVICE_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") },
    "sslbypass": { "installed": $(pm list packages | grep -q "$SSLBYPASS_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$SSLBYPASS_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") },
    "bootloaderspoofer": { "installed": $(pm list packages | grep -q "$BOOTLOADERSPOOFER_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$BOOTLOADERSPOOFER_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") },
    "iamnotadeveloper": { "installed": $(pm list packages | grep -q "$IAMNOTADEVELOPER_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$IAMNOTADEVELOPER_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") },
    "novpndetect": { "installed": $(pm list packages | grep -q "$NOVPNDETECT_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$NOVPNDETECT_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") },
    "fakegapps": { "installed": $(pm list packages | grep -q "$FAKEGAPPS_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$FAKEGAPPS_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") },
    "fuckgoogle": { "installed": $(pm list packages | grep -q "$FUCKGOOGLE_PACKAGE" 2>/dev/null && echo "true" || echo "false"), "running": $(pidof "$FUCKGOOGLE_PACKAGE" >/dev/null 2>&1 && echo "true" || echo "false") }
  },
  "injector_pid": $(cat "$CONFIG_DIR/inject.pid" 2>/dev/null || echo "null"),
  "injected_apps": $(wc -l < "$CONFIG_DIR/injected_apps.txt" 2>/dev/null || echo "0")
}
EOF

while true; do
    sleep 60
    log_print "Heartbeat: 8-module injector active"
done

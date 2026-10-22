<?php
$s=fsockopen("172.18.0.3",6379);
fwrite($s,"PING\r\n");
echo "P:".trim(fgets($s))."\n";
$tid="ver".time();
$cmd=array("airflow","version");
$body=base64_encode(json_encode(array(array($cmd),new stdClass,new stdClass)));
$msg=json_encode(array("body"=>$body,"content-encoding"=>"utf-8","content-type"=>"application/json","headers"=>array("lang"=>"py","task"=>"airflow.executors.celery_executor.execute_command","id"=>$tid,"root_id"=>$tid,"retries"=>0,"origin"=>"gen1@scheduler","ignore_result"=>false),"properties"=>array("correlation_id"=>$tid,"reply_to"=>$tid,"delivery_mode"=>2,"delivery_info"=>array("exchange"=>"","routing_key"=>"default"),"body_encoding"=>"base64","delivery_tag"=>$tid)));
$l=strlen($msg);
fwrite($s,"*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l."\r\n".$msg."\r\n");
echo "PUSH:".trim(fgets($s))."\n";
sleep(5);

// Check result with reply_to as key
fwrite($s,"GET celery-task-meta-$tid\r\n");
$r=trim(fgets($s));
echo "RES:$r\n";
if(substr($r,0,1)=='$'&&$r!='$-1'){
    $d=fread($s,min(intval(substr($r,1)),500)+2);
    echo "DATA:$d\n";
}

// Also check LLEN
fwrite($s,"LLEN default\r\n");
echo "Q:".trim(fgets($s))."\n";
echo "T:$tid\n";
fclose($s);

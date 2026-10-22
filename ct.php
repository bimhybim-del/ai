<?php
$s=fsockopen("172.18.0.3",6379);
fwrite($s,"PING\r\n");
echo trim(fgets($s))."\n";

// Test 1: airflow tasks test (runs task without DB dag_run)
$tid1="test1".time();
$cmd1=array("airflow","tasks","run","bash","check","2026-10-22T05:00:00+00:00","--local","--ship-dag");
$body1=base64_encode(json_encode(array(array($cmd1),new stdClass,new stdClass)));
$msg1=json_encode(array("body"=>$body1,"content-encoding"=>"utf-8","content-type"=>"application/json","headers"=>array("lang"=>"py","task"=>"airflow.providers.celery.executors.celery_executor_utils.execute_command","id"=>$tid1,"root_id"=>$tid1),"properties"=>array("correlation_id"=>$tid1,"reply_to"=>"","delivery_mode"=>2,"delivery_info"=>array("exchange"=>"","routing_key"=>"default"),"body_encoding"=>"base64","delivery_tag"=>$tid1)));
$l1=strlen($msg1);
fwrite($s,"*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l1."\r\n".$msg1."\r\n");
echo "T1:".trim(fgets($s))." $tid1\n";

// Test 2: Try triggering DAG via CLI (creates dag_run AND runs)
$tid2="trig".time();
$cmd2=array("airflow","tasks","run","bash","check","2026-10-22T06:00:00+00:00","--local","--mark-success");
$body2=base64_encode(json_encode(array(array($cmd2),new stdClass,new stdClass)));
$msg2=json_encode(array("body"=>$body2,"content-encoding"=>"utf-8","content-type"=>"application/json","headers"=>array("lang"=>"py","task"=>"airflow.providers.celery.executors.celery_executor_utils.execute_command","id"=>$tid2,"root_id"=>$tid2),"properties"=>array("correlation_id"=>$tid2,"reply_to"=>"","delivery_mode"=>2,"delivery_info"=>array("exchange"=>"","routing_key"=>"default"),"body_encoding"=>"base64","delivery_tag"=>$tid2)));
$l2=strlen($msg2);
fwrite($s,"*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l2."\r\n".$msg2."\r\n");
echo "T2:".trim(fgets($s))." $tid2\n";

fclose($s);

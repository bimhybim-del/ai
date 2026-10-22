<?php
$s=fsockopen("172.18.0.3",6379);
fwrite($s,"PING\r\n");
echo "REDIS:".trim(fgets($s))."\n";
$tid="ping".time();
$body=base64_encode(json_encode(array(array(),new stdClass,new stdClass)));
$msg=json_encode(array("body"=>$body,"content-encoding"=>"utf-8","content-type"=>"application/json","headers"=>array("lang"=>"py","task"=>"celery.ping","id"=>$tid,"root_id"=>$tid),"properties"=>array("correlation_id"=>$tid,"reply_to"=>$tid,"delivery_mode"=>2,"delivery_info"=>array("exchange"=>"","routing_key"=>"default"),"body_encoding"=>"base64","delivery_tag"=>$tid)));
$l=strlen($msg);
fwrite($s,"*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l."\r\n".$msg."\r\n");
echo "PUSH:".trim(fgets($s))."\n";
sleep(3);
fwrite($s,"GET celery-task-meta-".$tid."\r\n");
$r=trim(fgets($s));
echo "RLEN:".$r."\n";
if(substr($r,0,1)=="$"&&$r!="$-1"){$d=fread($s,intval(substr($r,1))+2);echo "RESULT:".$d."\n";}
fclose($s);
echo "TID:".$tid."\n";
?>

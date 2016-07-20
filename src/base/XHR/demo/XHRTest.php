<?php
header("Content-Type: application/json");
if(array_key_exists("sleep", $_REQUEST)) {
    sleep($_REQUEST["sleep"]);
}

echo json_encode(array("horst" => "henk"));
?>

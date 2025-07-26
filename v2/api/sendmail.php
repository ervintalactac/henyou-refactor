<?php
    include_once '../config/database.php';
    include_once '../class/recordsbackup.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    $data = $crypto->decryptPayload(file_get_contents("php://input"));

    $database = new Database();
    $db = $database->getConnection();
    $item = new RecordsBackup($db);
    $mail = $crypto->decryptWithServerPK($data->email);
// error_log($mail);
    $code = $item->getCodeByEmail($mail, $crypto);
    if($code == -1){
        echo 'Code have been previously used.';
        http_response_code(403);
        return;
    }
    if($code == 0){
        echo 'No record found with the email you provided.';
        http_response_code(404);
        return;
    }
    
    $to      = $mail;
    $subject = 'Henyo U?! app restore code';
    $message = ' 
    Your code is ' . $code . ' 
    
    Use this to restore your last game settings.
    Go to Settings > Backup/Restore to enter this code.
    
    Thanks for playing!
    support@henyogames.com';
    $headers = array(
        'From' => 'support@henyogames.com',
        'Reply-To' => 'support@henyogames.com',
        // 'X-Mailer' => 'PHP/' . phpversion(),
    );
    // setting headers to null since mail won't send with custom settings
    mail($to, $subject, $message, $headers);
    
    echo 'Email sent. Also check your spam folder if it\'s not in your inbox.';
    http_response_code(200);
    
    $to      = 'support+coderequested@henyogames.com';
    $subject = 'Henyo U?! app restore code requested';
    $message = 'code is ' . $code . ' 
    Requested by ' . $mail;
    
    mail($to, $subject, $message, $headers);
    
?>
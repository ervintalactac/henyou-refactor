<?php
require_once dirname(__DIR__) . '/config/env.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

try {
    // Get Ably API key from environment
    $ablyKey = Env::get('ABLY_API_KEY');
    
    if (!$ablyKey) {
        http_response_code(500);
        echo json_encode([
            'error' => 'Ably API key not configured',
            'message' => 'Please contact administrator'
        ]);
        exit;
    }
    
    // Return the key in expected format
    echo json_encode([
        'key' => $ablyKey,
        'status' => 'success'
    ]);
    
} catch (Exception $e) {
    // Log error
    error_log("Error in getablykey.php: " . $e->getMessage());
    
    // Return error response
    http_response_code(500);
    echo json_encode([
        'error' => 'Internal server error',
        'message' => 'Failed to retrieve API key'
    ]);
}
?>
<?php
require_once dirname(__DIR__) . '/config/env.php';

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

try {
    // Get Google Service Account key from environment
    $serviceAccountKey = Env::get('GOOGLE_SERVICE_ACCOUNT_KEY');
    
    if (!$serviceAccountKey) {
        http_response_code(500);
        echo json_encode([
            'error' => 'Service account key not configured',
            'message' => 'Please contact administrator'
        ]);
        exit;
    }
    
    // Validate it's valid JSON
    $keyData = json_decode($serviceAccountKey, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception('Invalid service account key format');
    }
    
    // Return the key (already in JSON format)
    echo $serviceAccountKey;
    
} catch (Exception $e) {
    // Log error
    error_log("Error in getserviceaccountkey.php: " . $e->getMessage());
    
    // Return error response
    http_response_code(500);
    echo json_encode([
        'error' => 'Internal server error',
        'message' => 'Failed to retrieve service account key'
    ]);
}
?>
<?php
require_once dirname(__DIR__) . '/config/env.php';
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/class/security.php';

abstract class BaseAPI {
    protected $conn;
    protected $requestMethod;
    protected $requestData;
    protected $responseCode = 200;
    protected $responseData = [];
    
    public function __construct() {
        // Start session for CSRF and rate limiting
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        // Set security headers
        $this->setSecurityHeaders();
        
        // Get request method
        $this->requestMethod = $_SERVER['REQUEST_METHOD'];
        
        // Handle preflight requests
        if ($this->requestMethod === 'OPTIONS') {
            $this->sendResponse();
            exit;
        }
        
        // Initialize database connection
        try {
            $database = new Database();
            $this->conn = $database->getConnection();
        } catch (Exception $e) {
            $this->sendError('Database connection failed', 500);
        }
        
        // Parse request data
        $this->parseRequestData();
        
        // Check rate limiting
        $this->checkRateLimit();
    }
    
    /**
     * Set security headers
     */
    protected function setSecurityHeaders() {
        // CORS headers (configure as needed)
        header('Access-Control-Allow-Origin: *'); // In production, specify exact origins
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-CSRF-Token');
        header('Access-Control-Max-Age: 86400'); // 24 hours
        
        // Security headers
        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: DENY');
        header('X-XSS-Protection: 1; mode=block');
        header('Referrer-Policy: strict-origin-when-cross-origin');
        
        // Content type
        header('Content-Type: application/json; charset=UTF-8');
        
        // Remove PHP version
        header_remove('X-Powered-By');
    }
    
    /**
     * Parse request data
     */
    protected function parseRequestData() {
        // Get raw input
        $rawData = file_get_contents('php://input');
        
        // Try to decode JSON
        if (!empty($rawData)) {
            $this->requestData = json_decode($rawData, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                // If not JSON, parse as form data
                parse_str($rawData, $this->requestData);
            }
        } else {
            // Use $_REQUEST for form data
            $this->requestData = $_REQUEST;
        }
        
        // Merge with $_GET for query parameters
        if (!empty($_GET)) {
            $this->requestData = array_merge($this->requestData, $_GET);
        }
    }
    
    /**
     * Check rate limiting
     */
    protected function checkRateLimit() {
        $identifier = Security::getClientIP() . '_' . $_SERVER['REQUEST_URI'];
        
        if (!Security::checkRateLimit($identifier)) {
            $this->sendError('Rate limit exceeded. Please try again later.', 429);
        }
    }
    
    /**
     * Validate request method
     */
    protected function validateMethod($allowedMethods) {
        if (!is_array($allowedMethods)) {
            $allowedMethods = [$allowedMethods];
        }
        
        if (!in_array($this->requestMethod, $allowedMethods)) {
            $this->sendError('Method not allowed', 405);
        }
    }
    
    /**
     * Validate and sanitize input
     */
    protected function validateInput($rules) {
        $result = Security::validateRequest($rules, $this->requestData);
        
        if (!$result['valid']) {
            $this->sendError('Validation failed', 400, $result['errors']);
        }
        
        return $result['data'];
    }
    
    /**
     * Require authentication
     */
    protected function requireAuth() {
        // Check for authorization header
        $headers = apache_request_headers();
        $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';
        
        if (empty($authHeader)) {
            $this->sendError('Authorization required', 401);
        }
        
        // Validate token (implement your auth logic)
        // This is a placeholder - implement actual JWT or token validation
        if (!$this->validateAuthToken($authHeader)) {
            $this->sendError('Invalid authorization', 401);
        }
    }
    
    /**
     * Validate auth token (placeholder - implement your logic)
     */
    protected function validateAuthToken($token) {
        // Remove 'Bearer ' prefix if present
        $token = str_replace('Bearer ', '', $token);
        
        // TODO: Implement actual token validation
        // For now, just check if token exists
        return !empty($token);
    }
    
    /**
     * Send success response
     */
    protected function sendSuccess($data = null, $message = 'Success') {
        $this->responseData = [
            'success' => true,
            'message' => $message
        ];
        
        if ($data !== null) {
            $this->responseData['data'] = $data;
        }
        
        $this->sendResponse();
    }
    
    /**
     * Send error response
     */
    protected function sendError($message, $code = 400, $errors = null) {
        $this->responseCode = $code;
        $this->responseData = [
            'success' => false,
            'message' => $message
        ];
        
        if ($errors !== null) {
            $this->responseData['errors'] = $errors;
        }
        
        $this->sendResponse();
    }
    
    /**
     * Send response
     */
    protected function sendResponse() {
        http_response_code($this->responseCode);
        
        // Add timestamp
        $this->responseData['timestamp'] = date('c');
        
        // Send JSON response
        echo json_encode($this->responseData, JSON_PRETTY_PRINT);
        exit;
    }
    
    /**
     * Log activity
     */
    protected function logActivity($action, $details = []) {
        $logData = [
            'timestamp' => date('c'),
            'ip' => Security::getClientIP(),
            'method' => $this->requestMethod,
            'uri' => $_SERVER['REQUEST_URI'],
            'action' => $action,
            'details' => $details
        ];
        
        error_log(json_encode($logData));
    }
    
    /**
     * Abstract method - must be implemented by child classes
     */
    abstract public function processRequest();
}
?>
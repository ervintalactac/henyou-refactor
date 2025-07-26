<?php
require_once dirname(__DIR__) . '/config/env.php';

class Security {
    
    /**
     * Sanitize string input
     */
    public static function sanitizeString($input) {
        if (is_array($input)) {
            return array_map([self::class, 'sanitizeString'], $input);
        }
        
        $input = trim($input);
        $input = stripslashes($input);
        $input = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
        return $input;
    }
    
    /**
     * Sanitize integer input
     */
    public static function sanitizeInt($input) {
        return filter_var($input, FILTER_SANITIZE_NUMBER_INT);
    }
    
    /**
     * Sanitize float input
     */
    public static function sanitizeFloat($input) {
        return filter_var($input, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
    }
    
    /**
     * Sanitize email input
     */
    public static function sanitizeEmail($input) {
        return filter_var($input, FILTER_SANITIZE_EMAIL);
    }
    
    /**
     * Validate email
     */
    public static function validateEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }
    
    /**
     * Sanitize URL
     */
    public static function sanitizeUrl($input) {
        return filter_var($input, FILTER_SANITIZE_URL);
    }
    
    /**
     * Validate URL
     */
    public static function validateUrl($url) {
        return filter_var($url, FILTER_VALIDATE_URL) !== false;
    }
    
    /**
     * Sanitize JSON input (preserves JSON structure)
     */
    public static function sanitizeJson($input) {
        // Decode JSON
        $decoded = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            return null;
        }
        
        // Recursively sanitize the decoded data
        $sanitized = self::sanitizeArray($decoded);
        
        // Re-encode to JSON
        return json_encode($sanitized);
    }
    
    /**
     * Sanitize array recursively
     */
    public static function sanitizeArray($array) {
        if (!is_array($array)) {
            return self::sanitizeString($array);
        }
        
        $sanitized = [];
        foreach ($array as $key => $value) {
            $sanitizedKey = self::sanitizeString($key);
            
            if (is_array($value)) {
                $sanitized[$sanitizedKey] = self::sanitizeArray($value);
            } else {
                $sanitized[$sanitizedKey] = self::sanitizeString($value);
            }
        }
        
        return $sanitized;
    }
    
    /**
     * Validate CSRF token
     */
    public static function validateCSRFToken($token) {
        if (!isset($_SESSION['csrf_token'])) {
            return false;
        }
        
        return hash_equals($_SESSION['csrf_token'], $token);
    }
    
    /**
     * Generate CSRF token
     */
    public static function generateCSRFToken() {
        $token = bin2hex(random_bytes(32));
        $_SESSION['csrf_token'] = $token;
        return $token;
    }
    
    /**
     * Rate limiting check
     */
    public static function checkRateLimit($identifier, $maxAttempts = null, $decayMinutes = null) {
        if ($maxAttempts === null) {
            $maxAttempts = Env::get('RATE_LIMIT_MAX_ATTEMPTS', 60);
        }
        
        if ($decayMinutes === null) {
            $decayMinutes = Env::get('RATE_LIMIT_DECAY_MINUTES', 1);
        }
        
        $key = 'rate_limit_' . md5($identifier);
        $attempts = isset($_SESSION[$key]) ? $_SESSION[$key]['attempts'] : 0;
        $lastAttempt = isset($_SESSION[$key]) ? $_SESSION[$key]['last_attempt'] : 0;
        
        // Reset if decay time has passed
        if (time() - $lastAttempt > ($decayMinutes * 60)) {
            $attempts = 0;
        }
        
        // Increment attempts
        $attempts++;
        $_SESSION[$key] = [
            'attempts' => $attempts,
            'last_attempt' => time()
        ];
        
        // Check if rate limit exceeded
        if ($attempts > $maxAttempts) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Validate request method
     */
    public static function validateRequestMethod($allowedMethods) {
        if (!is_array($allowedMethods)) {
            $allowedMethods = [$allowedMethods];
        }
        
        $method = $_SERVER['REQUEST_METHOD'];
        return in_array($method, $allowedMethods);
    }
    
    /**
     * Get client IP address
     */
    public static function getClientIP() {
        $ipKeys = ['HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'HTTP_CLIENT_IP', 'REMOTE_ADDR'];
        
        foreach ($ipKeys as $key) {
            if (array_key_exists($key, $_SERVER) === true) {
                $ip = $_SERVER[$key];
                if (strpos($ip, ',') !== false) {
                    $ip = explode(',', $ip)[0];
                }
                
                if (filter_var($ip, FILTER_VALIDATE_IP, 
                    FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false) {
                    return $ip;
                }
            }
        }
        
        return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    }
    
    /**
     * Validate file upload
     */
    public static function validateFileUpload($file, $allowedTypes = [], $maxSize = 5242880) {
        // Check if file was uploaded
        if (!isset($file['error']) || is_array($file['error'])) {
            return ['valid' => false, 'error' => 'Invalid file upload'];
        }
        
        // Check upload errors
        switch ($file['error']) {
            case UPLOAD_ERR_OK:
                break;
            case UPLOAD_ERR_INI_SIZE:
            case UPLOAD_ERR_FORM_SIZE:
                return ['valid' => false, 'error' => 'File too large'];
            case UPLOAD_ERR_NO_FILE:
                return ['valid' => false, 'error' => 'No file uploaded'];
            default:
                return ['valid' => false, 'error' => 'Upload failed'];
        }
        
        // Check file size
        if ($file['size'] > $maxSize) {
            return ['valid' => false, 'error' => 'File exceeds maximum size'];
        }
        
        // Check MIME type
        if (!empty($allowedTypes)) {
            $finfo = new finfo(FILEINFO_MIME_TYPE);
            $mimeType = $finfo->file($file['tmp_name']);
            
            if (!in_array($mimeType, $allowedTypes)) {
                return ['valid' => false, 'error' => 'Invalid file type'];
            }
        }
        
        return ['valid' => true];
    }
    
    /**
     * Generate secure random token
     */
    public static function generateSecureToken($length = 32) {
        return bin2hex(random_bytes($length / 2));
    }
    
    /**
     * Hash password
     */
    public static function hashPassword($password) {
        return password_hash($password, PASSWORD_ARGON2ID, [
            'memory_cost' => 65536,
            'time_cost' => 4,
            'threads' => 1
        ]);
    }
    
    /**
     * Verify password
     */
    public static function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
    
    /**
     * Sanitize filename
     */
    public static function sanitizeFilename($filename) {
        // Remove any path information
        $filename = basename($filename);
        
        // Remove special characters
        $filename = preg_replace('/[^a-zA-Z0-9._-]/', '', $filename);
        
        // Limit length
        if (strlen($filename) > 255) {
            $ext = pathinfo($filename, PATHINFO_EXTENSION);
            $name = pathinfo($filename, PATHINFO_FILENAME);
            $filename = substr($name, 0, 255 - strlen($ext) - 1) . '.' . $ext;
        }
        
        return $filename;
    }
    
    /**
     * Validate and sanitize request data
     */
    public static function validateRequest($rules, $data = null) {
        if ($data === null) {
            $data = $_REQUEST;
        }
        
        $errors = [];
        $sanitized = [];
        
        foreach ($rules as $field => $rule) {
            $value = isset($data[$field]) ? $data[$field] : null;
            
            // Check required
            if (isset($rule['required']) && $rule['required'] && empty($value)) {
                $errors[$field] = "$field is required";
                continue;
            }
            
            // Skip validation if not required and empty
            if (empty($value) && (!isset($rule['required']) || !$rule['required'])) {
                continue;
            }
            
            // Validate type
            if (isset($rule['type'])) {
                switch ($rule['type']) {
                    case 'string':
                        $sanitized[$field] = self::sanitizeString($value);
                        break;
                    case 'int':
                        $sanitized[$field] = self::sanitizeInt($value);
                        if (!is_numeric($sanitized[$field])) {
                            $errors[$field] = "$field must be a number";
                        }
                        break;
                    case 'float':
                        $sanitized[$field] = self::sanitizeFloat($value);
                        if (!is_numeric($sanitized[$field])) {
                            $errors[$field] = "$field must be a number";
                        }
                        break;
                    case 'email':
                        $sanitized[$field] = self::sanitizeEmail($value);
                        if (!self::validateEmail($sanitized[$field])) {
                            $errors[$field] = "$field must be a valid email";
                        }
                        break;
                    case 'url':
                        $sanitized[$field] = self::sanitizeUrl($value);
                        if (!self::validateUrl($sanitized[$field])) {
                            $errors[$field] = "$field must be a valid URL";
                        }
                        break;
                    case 'json':
                        $sanitized[$field] = self::sanitizeJson($value);
                        if ($sanitized[$field] === null) {
                            $errors[$field] = "$field must be valid JSON";
                        }
                        break;
                    default:
                        $sanitized[$field] = self::sanitizeString($value);
                }
            } else {
                $sanitized[$field] = self::sanitizeString($value);
            }
            
            // Check min length
            if (isset($rule['minLength']) && strlen($sanitized[$field]) < $rule['minLength']) {
                $errors[$field] = "$field must be at least {$rule['minLength']} characters";
            }
            
            // Check max length
            if (isset($rule['maxLength']) && strlen($sanitized[$field]) > $rule['maxLength']) {
                $errors[$field] = "$field must be no more than {$rule['maxLength']} characters";
            }
            
            // Check min value
            if (isset($rule['min']) && is_numeric($sanitized[$field]) && $sanitized[$field] < $rule['min']) {
                $errors[$field] = "$field must be at least {$rule['min']}";
            }
            
            // Check max value
            if (isset($rule['max']) && is_numeric($sanitized[$field]) && $sanitized[$field] > $rule['max']) {
                $errors[$field] = "$field must be no more than {$rule['max']}";
            }
            
            // Check pattern
            if (isset($rule['pattern']) && !preg_match($rule['pattern'], $sanitized[$field])) {
                $errors[$field] = "$field is invalid";
            }
        }
        
        return [
            'valid' => empty($errors),
            'errors' => $errors,
            'data' => $sanitized
        ];
    }
}
?>
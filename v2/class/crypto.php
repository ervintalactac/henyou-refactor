<?php 
require_once dirname(__DIR__) . '/config/env.php';

class Crypto {
    private $_key;
    private $_iv;
    private $_name;
    private $_nonce;
    private $private_key;
    private $public_key;
    
    public function __construct() {
        // Load keys from environment variables
        $this->private_key = Env::getOrFail('CRYPTO_PRIVATE_KEY');
        $this->public_key = Env::get('CRYPTO_PUBLIC_KEY');
        
        // Validate private key format
        if (!$this->isValidPrivateKey($this->private_key)) {
            throw new Exception('Invalid private key format');
        }
    }
    
    /**
     * Validate private key format
     */
    private function isValidPrivateKey($key) {
        return strpos($key, '-----BEGIN PRIVATE KEY-----') !== false 
            && strpos($key, '-----END PRIVATE KEY-----') !== false;
    }
    
    /**
     * Encrypt file using AES-256-CBC
     */
    public function encryptFile($encKey, $encIV, $inPath, $outPath) {
        if (!file_exists($inPath)) {
            throw new Exception("Input file not found: $inPath");
        }
        
        $text = file_get_contents($inPath);
        $key = base64_decode($encKey);
        $iv = base64_decode($encIV);
        
        $path_parts = pathinfo($inPath);
        $fileName = $path_parts['filename'];
        $outFile = $outPath . $fileName . '.himu';
        
        $encrypter = 'aes-256-cbc';
        $encrypted = openssl_encrypt($text, $encrypter, $key, 0, $iv);
        
        if ($encrypted === false) {
            throw new Exception("Encryption failed");
        }
        
        if (file_put_contents($outFile, $encrypted) !== false) {
            return 1;
        } else {
            return 0;
        }
    }
    
    /**
     * Decrypt file using AES-256-CBC
     */
    public function decryptFile($encKey, $encIV, $inPath, $outPath) {
        if (!file_exists($inPath)) {
            throw new Exception("Input file not found: $inPath");
        }
        
        $text = file_get_contents($inPath);
        $key = base64_decode($encKey);
        $iv = base64_decode($encIV);
        
        $path_parts = pathinfo($inPath);
        $fileName = str_replace('.himu', '', $path_parts['filename']);
        $extension = isset($path_parts['extension']) ? '.' . $path_parts['extension'] : '';
        $outFile = $outPath . $fileName . $extension;
        
        $encrypter = 'aes-256-cbc';
        $decrypted = openssl_decrypt($text, $encrypter, $key, 0, $iv);
        
        if ($decrypted === false) {
            throw new Exception("Decryption failed");
        }
        
        if (file_put_contents($outFile, $decrypted) !== false) {
            return 1;
        } else {
            return 0;
        }
    }
    
    /**
     * Encrypt data using RSA public key
     */
    public function encryptWithPublicKey($data) {
        if (!$this->public_key) {
            throw new Exception("Public key not configured");
        }
        
        $publicKey = openssl_pkey_get_public($this->public_key);
        if (!$publicKey) {
            throw new Exception("Invalid public key");
        }
        
        $encrypted = '';
        $success = openssl_public_encrypt($data, $encrypted, $publicKey);
        
        if (!$success) {
            throw new Exception("RSA encryption failed");
        }
        
        return base64_encode($encrypted);
    }
    
    /**
     * Decrypt data using RSA private key
     */
    public function decryptWithPrivateKey($encryptedData) {
        $privateKey = openssl_pkey_get_private($this->private_key);
        if (!$privateKey) {
            throw new Exception("Invalid private key");
        }
        
        $encrypted = base64_decode($encryptedData);
        $decrypted = '';
        $success = openssl_private_decrypt($encrypted, $decrypted, $privateKey);
        
        if (!$success) {
            throw new Exception("RSA decryption failed");
        }
        
        return $decrypted;
    }
    
    /**
     * Generate AES key and IV
     */
    public function generateAESKeyAndIV() {
        $key = openssl_random_pseudo_bytes(32); // 256 bits
        $iv = openssl_random_pseudo_bytes(16);  // 128 bits
        
        return [
            'key' => base64_encode($key),
            'iv' => base64_encode($iv)
        ];
    }
    
    /**
     * Encrypt data using AES-256-CBC
     */
    public function encryptAES($data, $key, $iv) {
        $key = base64_decode($key);
        $iv = base64_decode($iv);
        
        $encrypted = openssl_encrypt($data, 'aes-256-cbc', $key, 0, $iv);
        
        if ($encrypted === false) {
            throw new Exception("AES encryption failed");
        }
        
        return $encrypted;
    }
    
    /**
     * Decrypt data using AES-256-CBC
     */
    public function decryptAES($encryptedData, $key, $iv) {
        $key = base64_decode($key);
        $iv = base64_decode($iv);
        
        $decrypted = openssl_decrypt($encryptedData, 'aes-256-cbc', $key, 0, $iv);
        
        if ($decrypted === false) {
            throw new Exception("AES decryption failed");
        }
        
        return $decrypted;
    }
    
    /**
     * Generate secure random token
     */
    public function generateSecureToken($length = 32) {
        return bin2hex(openssl_random_pseudo_bytes($length));
    }
    
    /**
     * Hash password using bcrypt
     */
    public function hashPassword($password) {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }
    
    /**
     * Verify password against hash
     */
    public function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
}
?>
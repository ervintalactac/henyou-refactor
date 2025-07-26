<?php
/**
 * Environment variable loader for HenyoU
 * This file loads environment variables from .env file
 * 
 * Usage:
 * require_once 'config/env.php';
 * $dbHost = Env::get('DB_HOST', 'localhost');
 */

class Env {
    private static $loaded = false;
    private static $variables = [];

    /**
     * Load environment variables from .env file
     * @param string|null $path Path to .env file
     */
    public static function load($path = null) {
        if (self::$loaded) {
            return;
        }

        // Default to .env in project root (2 levels up from v2/config)
        $envFile = $path ?: dirname(__DIR__, 2) . '/.env';
        
        if (!file_exists($envFile)) {
            // Try alternate locations
            $alternativePaths = [
                dirname(__DIR__) . '/.env',  // v2/.env
                __DIR__ . '/.env',            // v2/config/.env
            ];
            
            foreach ($alternativePaths as $altPath) {
                if (file_exists($altPath)) {
                    $envFile = $altPath;
                    break;
                }
            }
            
            // If still not found, use system environment variables
            if (!file_exists($envFile)) {
                self::$loaded = true;
                return;
            }
        }

        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        
        foreach ($lines as $line) {
            // Skip comments
            if (strpos(trim($line), '#') === 0) {
                continue;
            }

            // Skip empty lines
            if (trim($line) === '') {
                continue;
            }

            // Parse key=value
            if (strpos($line, '=') !== false) {
                list($key, $value) = explode('=', $line, 2);
                $key = trim($key);
                $value = trim($value);

                // Handle multiline values (for keys, certificates, etc.)
                if (substr($value, 0, 1) === '"' && substr($value, -1) !== '"') {
                    // Start of multiline value
                    $multilineValue = substr($value, 1); // Remove opening quote
                    $lineIndex = array_search($line, $lines);
                    
                    // Continue reading lines until we find the closing quote
                    for ($i = $lineIndex + 1; $i < count($lines); $i++) {
                        $nextLine = $lines[$i];
                        if (substr(rtrim($nextLine), -1) === '"') {
                            // Found closing quote
                            $multilineValue .= "\n" . substr(rtrim($nextLine), 0, -1);
                            break;
                        } else {
                            // Continue building multiline value
                            $multilineValue .= "\n" . $nextLine;
                        }
                    }
                    $value = $multilineValue;
                } else {
                    // Remove surrounding quotes for single-line values
                    $value = trim($value, '"\'');
                }

                // Expand environment variables in values (e.g., $HOME)
                $value = self::expandEnvironmentVariables($value);

                // Set in $_ENV and putenv
                $_ENV[$key] = $value;
                putenv("$key=$value");
                self::$variables[$key] = $value;
            }
        }

        self::$loaded = true;
    }

    /**
     * Expand environment variables in a string
     * @param string $value
     * @return string
     */
    private static function expandEnvironmentVariables($value) {
        return preg_replace_callback('/\$\{([A-Z_]+)\}/', function($matches) {
            return self::get($matches[1], $matches[0]);
        }, $value);
    }

    /**
     * Get an environment variable
     * @param string $key Variable name
     * @param mixed $default Default value if not found
     * @return mixed
     */
    public static function get($key, $default = null) {
        if (!self::$loaded) {
            self::load();
        }

        // Check in order: self::$variables, $_ENV, getenv()
        if (isset(self::$variables[$key])) {
            return self::$variables[$key];
        }
        
        if (isset($_ENV[$key])) {
            return $_ENV[$key];
        }
        
        $value = getenv($key);
        if ($value !== false) {
            return $value;
        }
        
        return $default;
    }

    /**
     * Get an environment variable or throw exception if not found
     * @param string $key Variable name
     * @return mixed
     * @throws Exception
     */
    public static function getOrFail($key) {
        $value = self::get($key);
        if ($value === null) {
            throw new Exception("Required environment variable '$key' is not set");
        }
        return $value;
    }

    /**
     * Check if an environment variable exists
     * @param string $key Variable name
     * @return bool
     */
    public static function has($key) {
        return self::get($key) !== null;
    }

    /**
     * Get all loaded environment variables
     * @return array
     */
    public static function all() {
        if (!self::$loaded) {
            self::load();
        }
        return self::$variables;
    }

    /**
     * Validate required environment variables
     * @param array $required Array of required variable names
     * @throws Exception
     */
    public static function validateRequired(array $required) {
        $missing = [];
        foreach ($required as $var) {
            if (!self::has($var)) {
                $missing[] = $var;
            }
        }
        
        if (!empty($missing)) {
            throw new Exception("Missing required environment variables: " . implode(', ', $missing));
        }
    }
}

// Auto-load on include
Env::load();
?>
# Security Implementation Guide for HenyoU

This document outlines the security measures implemented in the HenyoU refactor project and provides guidelines for maintaining security throughout development.

## Table of Contents
1. [Critical Security Issues Fixed](#critical-security-issues-fixed)
2. [Environment Configuration](#environment-configuration)
3. [Database Security](#database-security)
4. [API Security](#api-security)
5. [Development Guidelines](#development-guidelines)
6. [Deployment Checklist](#deployment-checklist)

## Critical Security Issues Fixed

### 1. Removed Hardcoded Credentials
- **Issue**: Database credentials, API keys, and private keys were hardcoded in source files
- **Fix**: All sensitive data moved to environment variables
- **Files affected**:
  - `v2/config/database.php` - Now uses environment variables
  - `v2/class/crypto.php` - Removed, replaced with template
  - `v2/api/getserviceaccountkey.php` - Removed, replaced with template
  - `v2/api/getablykey.php` - Removed, replaced with template
  - `henyo/lib/openai.dart` - API key removed

### 2. SQL Injection Vulnerabilities
- **Issue**: Direct string concatenation in SQL queries
- **Fix**: Implemented prepared statements with parameter binding
- **Files affected**:
  - `v2/class/records.php` - Created secure version `records_secure.php`
  - All database operations now use PDO prepared statements

### 3. Input Validation
- **Issue**: Inconsistent input sanitization
- **Fix**: Implemented consistent validation and sanitization
- **Method**: Using `htmlspecialchars()` and `strip_tags()` for display data

## Environment Configuration

### Setting Up Environment Variables

1. Copy the example environment file:
   ```bash
   cp v2/.env.example v2/.env
   ```

2. Edit `v2/.env` with your actual values:
   ```env
   # Database Configuration
   DB_HOST=127.0.0.1
   DB_NAME=your_database_name
   DB_USER=your_database_user
   DB_PASSWORD=your_secure_password

   # API Keys
   ABLY_API_KEY=your_ably_api_key
   GOOGLE_SERVICE_ACCOUNT_KEY='{"type":"service_account"...}'
   OPENAI_API_KEY=your_openai_api_key

   # Encryption Keys
   ENCRYPTION_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
   YOUR_PRIVATE_KEY_HERE
   -----END PRIVATE KEY-----"
   ```

3. Ensure `.env` is never committed to version control (already in `.gitignore`)

### Environment Variable Usage in Code

```php
// PHP example
require_once 'config/env.php';

$dbHost = Env::get('DB_HOST', 'localhost');
$apiKey = Env::getOrFail('API_KEY'); // Throws exception if not set
```

```dart
// Flutter example
final apiKey = Platform.environment['OPENAI_API_KEY'];
```

## Database Security

### Prepared Statements
Always use prepared statements for database queries:

```php
// GOOD - Using prepared statements
$stmt = $conn->prepare("SELECT * FROM users WHERE name = :name");
$stmt->bindParam(":name", $username);
$stmt->execute();

// BAD - Direct concatenation (vulnerable to SQL injection)
// $query = "SELECT * FROM users WHERE name = '" . $username . "'";
```

### Connection Security
- Use SSL/TLS for database connections in production
- Implement connection pooling
- Set appropriate timeouts
- Use least-privilege database users

## API Security

### Authentication & Authorization
1. **Current System**: Custom encryption with RSA/AES
2. **Recommended Migration**: JWT tokens with refresh tokens
3. **Implementation**:
   ```php
   // Example JWT implementation (for Node.js migration)
   const jwt = require('jsonwebtoken');
   
   function generateToken(user) {
     return jwt.sign(
       { id: user.id, name: user.name },
       process.env.JWT_SECRET,
       { expiresIn: '1h' }
     );
   }
   ```

### Request Validation
1. **Input Sanitization**: All user inputs must be validated
2. **Rate Limiting**: Implement rate limiting on all endpoints
3. **CORS**: Configure appropriate CORS headers
4. **HTTPS**: Always use HTTPS in production

### Encryption
- **Current**: AES-256-CBC for data encryption
- **Keys**: Store encryption keys in environment variables
- **Rotation**: Implement key rotation strategy

## Development Guidelines

### Code Review Checklist
- [ ] No hardcoded credentials
- [ ] All database queries use prepared statements
- [ ] Input validation on all user data
- [ ] Error messages don't expose sensitive information
- [ ] Logging doesn't include sensitive data
- [ ] Dependencies are up to date
- [ ] Security headers are properly configured

### Secure Coding Practices
1. **Never trust user input**
   - Validate all inputs
   - Sanitize for output context (HTML, SQL, etc.)

2. **Principle of Least Privilege**
   - Database users have minimal required permissions
   - API endpoints require appropriate authentication

3. **Defense in Depth**
   - Multiple layers of security
   - Don't rely on single security measure

4. **Secure by Default**
   - Default configurations should be secure
   - Require explicit action to reduce security

## Deployment Checklist

### Pre-deployment Security Audit
- [ ] All environment variables configured
- [ ] Database credentials are secure
- [ ] API keys are properly managed
- [ ] SSL/TLS certificates installed
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] Logging configured (without sensitive data)
- [ ] Error handling doesn't expose internals
- [ ] File permissions properly set
- [ ] Unnecessary files removed (`.env.example`, etc.)

### Production Environment Setup
```bash
# Example production setup
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Use strong passwords
DB_PASSWORD=$(openssl rand -base64 32)

# Enable security features
SECURE_COOKIES=true
SESSION_SECURE=true
FORCE_HTTPS=true
```

### Monitoring & Alerts
1. **Set up monitoring for**:
   - Failed login attempts
   - SQL injection attempts
   - Unusual traffic patterns
   - Error rates

2. **Security Event Logging**:
   ```php
   // Log security events
   error_log("[SECURITY] Failed login attempt for user: " . $username);
   error_log("[SECURITY] Potential SQL injection detected from IP: " . $_SERVER['REMOTE_ADDR']);
   ```

## Security Tools & Resources

### Recommended Tools
1. **OWASP ZAP** - Web application security scanner
2. **SQLMap** - SQL injection testing
3. **Composer Audit** - PHP dependency vulnerabilities
4. **npm audit** - Node.js dependency vulnerabilities

### Regular Security Tasks
- Weekly: Review logs for security events
- Monthly: Update dependencies
- Quarterly: Security audit
- Annually: Penetration testing

## Incident Response

### If a Security Breach Occurs
1. **Immediate Actions**:
   - Isolate affected systems
   - Preserve logs
   - Reset all credentials
   - Notify users if data was compromised

2. **Investigation**:
   - Determine scope of breach
   - Identify vulnerability
   - Review logs

3. **Remediation**:
   - Fix vulnerability
   - Update security measures
   - Document lessons learned

## Contact Information

For security concerns or to report vulnerabilities:
- Email: security@henyou.com (create dedicated security email)
- Use responsible disclosure practices

---

**Remember**: Security is not a one-time implementation but an ongoing process. Stay updated with security best practices and regularly audit your code.
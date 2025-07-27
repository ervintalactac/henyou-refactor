# HenyoU Development Setup Guide

This guide will help you set up your development environment for the HenyoU refactor project.

## Prerequisites

### Required Software
- **PHP** 7.4 or higher (for current backend)
- **Node.js** 18+ and npm (for future migration)
- **MySQL/MariaDB** 5.7+ (current) / **PostgreSQL** 15+ (future)
- **Flutter** 3.0+ and Dart SDK
- **Git**
- **Redis** (optional, for caching)

### Recommended Tools
- **VSCode** or **Android Studio** for Flutter development
- **Postman** or **Insomnia** for API testing
- **TablePlus** or **DBeaver** for database management
- **Docker** (optional, for containerized development)

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/ervintalactac/henyou-refactor.git
cd henyou-refactor
```

### 2. Backend Setup (PHP - Current)

#### Configure Environment
```bash
# Copy environment template
cp v2/.env.example v2/.env

# Edit v2/.env with your database credentials
# IMPORTANT: Never commit .env file!
```

#### Database Setup
```bash
# Create database
mysql -u root -p -e "CREATE DATABASE henyou_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Import schema (use the smaller SQL file for development)
mysql -u root -p henyou_dev < v2/henyzlbt_henyogames.sql

# Create test user (optional)
mysql -u root -p henyou_dev -e "INSERT INTO RecordsHenyo (name, alias) VALUES ('testuser', 'Test User');"
```

#### Start PHP Development Server
```bash
cd v2/api
php -S localhost:8000
```

### 3. Flutter App Setup

#### Install Dependencies
```bash
cd henyo
flutter pub get
```

#### Configure API Endpoint
Create `henyo/lib/config/env.dart`:
```dart
class Environment {
  static const String apiUrl = 'http://localhost:8000/api';
  static const bool isDebug = true;
}
```

#### Generate Required Files
```bash
# If using build_runner
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Run the App
```bash
# Check available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on Chrome (web)
flutter run -d chrome

# Run on iOS Simulator
flutter run -d iPhone

# Run on Android Emulator
flutter run -d emulator
```

## Detailed Configuration

### Environment Variables Reference

Create `v2/.env` with these variables:

```env
# Application
APP_ENV=development
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=henyou_dev
DB_USERNAME=root
DB_PASSWORD=your_password
DB_CHARSET=utf8mb4

# API Keys (for development, use test keys)
ABLY_API_KEY=test_key_here
GOOGLE_SERVICE_ACCOUNT_KEY='{"type":"service_account","project_id":"test"}'
OPENAI_API_KEY=test_key_here

# Encryption (generate for development)
ENCRYPTION_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...
-----END PRIVATE KEY-----"

# Email (optional for development)
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

### Generating Encryption Keys

For development, generate RSA keys:
```bash
# Generate private key
openssl genrsa -out private.key 2048

# Generate public key
openssl rsa -in private.key -pubout -out public.key

# View key content for .env file
cat private.key
```

### Database Migrations (Future)

For the PostgreSQL migration:
```bash
# Install PostgreSQL
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib

# Create database
createdb henyou_dev

# Future: Run migrations
npm run migrate
```

## Development Workflow

### 1. Feature Development

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes
# Test locally
# Commit with meaningful messages
git add .
git commit -m "feat: add new game mode"

# Push to GitHub
git push origin feature/your-feature-name
```

### 2. Testing

#### API Testing
```bash
# Test user creation
curl -X POST http://localhost:8000/api/createuserrecord.php \
  -H "Content-Type: application/json" \
  -d '{"name": "testuser", "alias": "Test User"}'

# Test fetching records
curl http://localhost:8000/api/fetchrecords.php
```

#### Flutter Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

### 3. Code Quality

#### PHP Linting
```bash
# Install PHP CodeSniffer
composer global require "squizlabs/php_codesniffer=*"

# Check code standards
phpcs v2/

# Auto-fix issues
phpcbf v2/
```

#### Flutter Analysis
```bash
# Analyze code
flutter analyze

# Format code
flutter format .
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed
- Check MySQL/MariaDB is running: `systemctl status mysql`
- Verify credentials in `.env`
- Check database exists: `mysql -u root -p -e "SHOW DATABASES;"`

#### 2. Flutter Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### 3. PHP Errors
- Check PHP version: `php -v`
- Enable error reporting in development
- Check error logs: `tail -f v2/api/error_log`

#### 4. CORS Issues
Add to PHP API files:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');
```

### Debug Mode

#### Enable Flutter Debug Mode
```dart
// In main.dart
void main() {
  if (kDebugMode) {
    print('Running in debug mode');
  }
  runApp(MyApp());
}
```

#### Enable PHP Debug Mode
```php
// In v2/api files
if (Env::get('APP_DEBUG', false)) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}
```

## Next Steps

### Phase 2: Node.js Migration Preparation

1. **Install Node.js dependencies**:
   ```bash
   cd backend  # Future Node.js directory
   npm init -y
   npm install express dotenv cors helmet
   npm install -D typescript @types/node nodemon
   ```

2. **Set up TypeScript**:
   ```bash
   npx tsc --init
   ```

3. **Create basic server structure**:
   ```
   backend/
   ├── src/
   │   ├── config/
   │   ├── controllers/
   │   ├── models/
   │   ├── routes/
   │   └── server.ts
   ├── .env
   ├── package.json
   └── tsconfig.json
   ```

## Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [PHP PDO Documentation](https://www.php.net/manual/en/book.pdo.php)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

### Community
- Project Issues: [GitHub Issues](https://github.com/ervintalactac/henyou-refactor/issues)
- Flutter Community: [Flutter Discord](https://discord.gg/flutter)

### Security
- Review [SECURITY.md](./SECURITY.md) for security guidelines
- Report vulnerabilities responsibly

---

**Happy Coding!** 🎮 If you encounter any issues, please check the troubleshooting section or create an issue on GitHub.
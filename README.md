# HenyoU Refactor Project

A comprehensive refactor of the HenyoU mobile word guessing game, migrating from PHP/MySQL to Node.js/PostgreSQL while maintaining the Flutter-based mobile application.

## 🎯 Project Overview

HenyoU is a popular Filipino word guessing game (based on "Pinoy Henyo") with multiple game modes, real-time multiplayer capabilities, and weekly competitions. This refactor aims to modernize the backend infrastructure while improving security, performance, and maintainability.

## 📋 Documentation

- **[Setup Guide](./SETUP.md)** - Complete development environment setup
- **[Security Guide](./SECURITY.md)** - Security implementation and best practices
- **[Refactor Plan](./REFACTOR_PLAN.md)** - Detailed 18-week migration plan

## 🚀 Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/ervintalactac/henyou-refactor.git
   cd henyou-refactor
   ```

2. Set up environment variables:
   ```bash
   cp v2/.env.example v2/.env
   # Edit v2/.env with your configuration
   ```

3. Follow the [Setup Guide](./SETUP.md) for detailed instructions.

## 🏗️ Project Structure

```
henyou-refactor/
├── henyo/                 # Flutter mobile application
│   ├── lib/              # Dart source code
│   ├── assets/           # Images, sounds, animations
│   └── android/ios/      # Platform-specific code
├── v2/                   # Current PHP backend
│   ├── api/             # API endpoints
│   ├── class/           # PHP classes
│   └── config/          # Configuration files
├── backend/             # Future Node.js backend (Phase 2)
└── docs/               # Additional documentation
```

## 🔒 Security Improvements

This refactor prioritizes security:
- ✅ Removed all hardcoded credentials
- ✅ Fixed SQL injection vulnerabilities
- ✅ Implemented environment-based configuration
- ✅ Added prepared statements for all database queries
- 📋 See [SECURITY.md](./SECURITY.md) for complete details

## 🛠️ Technology Stack

### Current Stack
- **Frontend**: Flutter/Dart (iOS, Android, Web)
- **Backend**: PHP 7.4+
- **Database**: MySQL/MariaDB
- **Real-time**: Ably
- **Hosting**: Traditional LAMP stack

### Target Stack (Post-refactor)
- **Frontend**: Flutter/Dart (maintained)
- **Backend**: Node.js with TypeScript
- **Database**: PostgreSQL 15+
- **Cache**: Redis
- **Real-time**: Socket.io
- **Hosting**: Docker/Kubernetes

## 🎮 Features

- **Single Player Mode**: Classic word guessing with AI clues
- **Multiplayer Mode**: Real-time games with friends
- **Party Mode**: Local multiplayer for groups
- **Gimme 5**: Quick-fire 5-word challenges
- **Weekly Competitions**: Leaderboards and prizes
- **Progress Tracking**: Comprehensive statistics
- **Multiple Languages**: English and Filipino

## 🗓️ Refactor Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Phase 1: Security & Foundation | Weeks 1-3 | 🟡 In Progress |
| Phase 2: Node.js Backend | Weeks 4-8 | ⏳ Pending |
| Phase 3: Database Migration | Weeks 9-10 | ⏳ Pending |
| Phase 4: Flutter Updates | Weeks 11-14 | ⏳ Pending |
| Phase 5: Testing | Weeks 15-16 | ⏳ Pending |
| Phase 6: Deployment | Weeks 17-18 | ⏳ Pending |

See [REFACTOR_PLAN.md](./REFACTOR_PLAN.md) for detailed timeline.

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow the security practices in [SECURITY.md](./SECURITY.md)
- Write tests for new features
- Update documentation as needed
- Use meaningful commit messages

## 📝 License

This project is proprietary software. All rights reserved.

## 📞 Contact

- GitHub Issues: [Report bugs or request features](https://github.com/ervintalactac/henyou-refactor/issues)
- Security: See [SECURITY.md](./SECURITY.md) for reporting vulnerabilities

## 🙏 Acknowledgments

- Original HenyoU team
- Flutter community
- Contributors and testers

---

**Note**: This is an active refactor project. Some features may be temporarily unavailable during the migration process.
# HenyoU Refactor Project - Comprehensive Plan

## Executive Summary

This document outlines a comprehensive 18-week refactor plan for the HenyoU mobile game application. The plan addresses:
- Migration from PHP to Node.js backend
- Database migration from MySQL/MariaDB to PostgreSQL
- Security vulnerability remediation
- Flutter app modernization and stability improvements
- Infrastructure and deployment upgrades

## Current Architecture Overview

### Frontend
- **Platform**: Flutter/Dart (cross-platform mobile app)
- **State Management**: Mixed approach with ObjectBox for local storage
- **Key Dependencies**: Google Ads, Speech-to-text, Ably for real-time features

### Backend
- **API**: PHP-based REST API (v2 directory)
- **Database**: MySQL/MariaDB (`henyzlbt_henyogames`)
- **Security**: Custom encryption with RSA/AES, TOTP authentication

### Key Features
- Single-player word guessing game
- Multiplayer mode with rooms
- Weekly competitions
- Multiple game modes (Gimme 5, Party Mode)
- User progress tracking and leaderboards

## Phase 1: Foundation & Security (Weeks 1-3)

### 1.1 Critical Security Fixes (Week 1) 🔴 URGENT

#### Tasks
- [ ] Remove hardcoded database credentials from `/v2/config/database.php`
- [ ] Fix SQL injection vulnerabilities in `class/records.php`
- [ ] Implement environment variable configuration
- [ ] Secure API endpoints with proper authentication
- [ ] Enable input sanitization across all endpoints

#### Deliverables
- Secure configuration management system
- Patched SQL queries using prepared statements
- Security audit report

### 1.2 Database Migration Preparation (Weeks 2-3)

#### Tasks
- [ ] Analyze current MySQL schema and data patterns
- [ ] Design optimized PostgreSQL schema
- [ ] Create data migration scripts
- [ ] Set up PostgreSQL development environment
- [ ] Document data transformation requirements

#### Schema Migration Mapping

```sql
-- MySQL to PostgreSQL migration examples

-- User Records
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    alias VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    scores JSONB DEFAULT '{}',
    streaks JSONB DEFAULT '{}',
    extra_data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Game Sessions
CREATE TABLE game_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    game_mode VARCHAR(50) NOT NULL,
    words JSONB NOT NULL,
    guesses JSONB DEFAULT '[]',
    score INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Multiplayer Rooms
CREATE TABLE multiplayer_rooms (
    id SERIAL PRIMARY KEY,
    room_code VARCHAR(10) UNIQUE NOT NULL,
    host_id INTEGER REFERENCES users(id),
    players JSONB DEFAULT '[]',
    game_state JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);
```

## Phase 2: New Node.js Backend (Weeks 4-8)

### 2.1 API Architecture Design (Week 4)

#### Technology Stack
```javascript
// Core Dependencies
{
  "dependencies": {
    "@nestjs/core": "^10.0.0",        // Or Express + TypeScript
    "@nestjs/typeorm": "^10.0.0",     // ORM for PostgreSQL
    "@nestjs/jwt": "^10.0.0",         // JWT authentication
    "@nestjs/websockets": "^10.0.0",  // WebSocket support
    "socket.io": "^4.6.0",            // Real-time multiplayer
    "redis": "^4.6.0",                // Session management
    "helmet": "^7.0.0",               // Security headers
    "class-validator": "^0.14.0",     // Input validation
    "winston": "^3.10.0",             // Logging
    "node-cron": "^3.0.2"             // Scheduled tasks
  }
}
```

#### API Structure
```
src/
├── auth/
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── jwt.strategy.ts
│   └── guards/
├── users/
│   ├── users.controller.ts
│   ├── users.service.ts
│   └── entities/
├── games/
│   ├── games.controller.ts
│   ├── games.service.ts
│   ├── game-modes/
│   └── scoring/
├── multiplayer/
│   ├── multiplayer.gateway.ts
│   ├── room.service.ts
│   └── matchmaking/
├── content/
│   ├── words.controller.ts
│   ├── dictionary.service.ts
│   └── admin/
└── common/
    ├── middleware/
    ├── interceptors/
    └── exceptions/
```

### 2.2 Core API Development (Weeks 5-6)

#### API Endpoints

##### Authentication
```typescript
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/auth/verify
```

##### User Management
```typescript
GET    /api/v1/users/profile
PUT    /api/v1/users/profile
GET    /api/v1/users/stats
POST   /api/v1/users/backup
POST   /api/v1/users/restore
```

##### Game Logic
```typescript
POST   /api/v1/games/start
POST   /api/v1/games/:id/guess
GET    /api/v1/games/:id/status
POST   /api/v1/games/:id/complete
GET    /api/v1/games/history
```

##### Multiplayer
```typescript
POST   /api/v1/multiplayer/rooms
GET    /api/v1/multiplayer/rooms/:code
PUT    /api/v1/multiplayer/rooms/:code/join
POST   /api/v1/multiplayer/rooms/:code/start
WS     /multiplayer (WebSocket endpoint)
```

### 2.3 Advanced Features (Weeks 7-8)

#### Real-time Features Implementation
```typescript
// WebSocket events for multiplayer
interface MultiplayerEvents {
  'room:create': (data: CreateRoomDto) => void;
  'room:join': (data: JoinRoomDto) => void;
  'game:start': (roomCode: string) => void;
  'game:guess': (data: GuessDto) => void;
  'game:clue': (data: ClueDto) => void;
  'player:ready': (playerId: string) => void;
  'room:leave': (playerId: string) => void;
}
```

#### Weekly Competition System
```typescript
// Automated weekly competition management
@Injectable()
export class WeeklyCompetitionService {
  @Cron('0 0 * * MON') // Every Monday at midnight
  async startNewWeek() {
    await this.closeCurrentWeek();
    await this.announceWinners();
    await this.createNewWeek();
  }
}
```

## Phase 3: Database Migration (Weeks 9-10)

### 3.1 PostgreSQL Implementation (Week 9)

#### Performance Optimizations
```sql
-- Indexes for common queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_game_sessions_user_date ON game_sessions(user_id, started_at DESC);
CREATE INDEX idx_multiplayer_rooms_code ON multiplayer_rooms(room_code);

-- Materialized view for leaderboards
CREATE MATERIALIZED VIEW leaderboard_weekly AS
SELECT 
    u.id,
    u.name,
    u.alias,
    COUNT(gs.id) as games_played,
    SUM(gs.score) as total_score,
    MAX(gs.score) as high_score,
    DATE_TRUNC('week', gs.started_at) as week
FROM users u
JOIN game_sessions gs ON u.id = gs.user_id
WHERE gs.completed = true
GROUP BY u.id, u.name, u.alias, DATE_TRUNC('week', gs.started_at);

-- Refresh strategy
CREATE INDEX ON leaderboard_weekly (week, total_score DESC);
```

### 3.2 Data Migration (Week 10)

#### Migration Script Example
```javascript
// migrate.js
const mysql = require('mysql2/promise');
const { Client } = require('pg');

async function migrateUsers() {
  const mysqlConn = await mysql.createConnection({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: 'henyzlbt_henyogames'
  });

  const pgClient = new Client({
    connectionString: process.env.POSTGRES_URL
  });

  await pgClient.connect();

  // Batch migration with progress tracking
  const [users] = await mysqlConn.execute('SELECT * FROM RecordsHenyo');
  
  for (const user of users) {
    await pgClient.query(
      `INSERT INTO users (name, alias, scores, streaks, extra_data, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [
        user.name,
        user.alias,
        JSON.parse(user.scores || '{}'),
        JSON.parse(user.streaks || '{}'),
        JSON.parse(user.extraData || '{}'),
        user.timestamp
      ]
    );
  }
}
```

## Phase 4: Flutter App Modernization (Weeks 11-14)

### 4.1 API Integration Update (Week 11)

#### New HTTP Client Implementation
```dart
// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
    ));
    
    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(LoggingInterceptor());
  }
  
  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    return AuthResponse.fromJson(response.data);
  }
}
```

### 4.2 Code Architecture Improvements (Weeks 12-13)

#### State Management with Riverpod
```dart
// lib/providers/game_provider.dart
import 'package:riverpod/riverpod.dart';

final gameServiceProvider = Provider((ref) => GameService(ref.read));

final currentGameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref.read(gameServiceProvider));
});

class GameNotifier extends StateNotifier<GameState> {
  final GameService _gameService;
  
  GameNotifier(this._gameService) : super(GameState.initial());
  
  Future<void> startNewGame(GameMode mode) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final game = await _gameService.startGame(mode);
      state = state.copyWith(
        currentGame: game,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
```

### 4.3 Updated Dependencies (Week 14)

```yaml
# pubspec.yaml updates
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Networking
  dio: ^5.3.2
  dio_cache_interceptor: ^3.4.2
  
  # Local Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # UI/UX
  flutter_animate: ^4.2.0
  google_fonts: ^6.1.0
  
  # Real-time
  socket_io_client: ^2.0.3
  
  # Utilities
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
dev_dependencies:
  build_runner: ^2.4.6
  freezed: ^2.4.2
  json_serializable: ^6.7.1
```

## Phase 5: Testing & Quality Assurance (Weeks 15-16)

### 5.1 Backend Testing Strategy (Week 15)

#### Test Coverage Requirements
- Unit Tests: 80% minimum coverage
- Integration Tests: All API endpoints
- Load Tests: 1000 concurrent users
- Security Tests: OWASP Top 10

#### Example Test Suite
```typescript
// tests/games/games.service.spec.ts
describe('GamesService', () => {
  let service: GamesService;
  let mockRepository: MockRepository<Game>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GamesService,
        {
          provide: getRepositoryToken(Game),
          useClass: MockRepository,
        },
      ],
    }).compile();

    service = module.get<GamesService>(GamesService);
    mockRepository = module.get(getRepositoryToken(Game));
  });

  describe('startGame', () => {
    it('should create a new game session', async () => {
      const userId = 1;
      const gameMode = GameMode.CLASSIC;
      
      const result = await service.startGame(userId, gameMode);
      
      expect(result).toBeDefined();
      expect(result.gameMode).toBe(gameMode);
      expect(mockRepository.save).toHaveBeenCalled();
    });
  });
});
```

### 5.2 Mobile App Testing (Week 16)

#### Flutter Test Strategy
```dart
// test/features/game/game_screen_test.dart
testWidgets('Game screen displays word and accepts guesses', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameServiceProvider.overrideWithValue(MockGameService()),
      ],
      child: MaterialApp(home: GameScreen()),
    ),
  );
  
  expect(find.text('Ready to play?'), findsOneWidget);
  
  await tester.tap(find.byType(StartButton));
  await tester.pumpAndSettle();
  
  expect(find.byType(WordDisplay), findsOneWidget);
  expect(find.byType(GuessInput), findsOneWidget);
});
```

## Phase 6: Deployment & Monitoring (Weeks 17-18)

### 6.1 Infrastructure Setup (Week 17)

#### Docker Configuration
```dockerfile
# Dockerfile for Node.js API
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

#### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: henyou-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: henyou-api
  template:
    metadata:
      labels:
        app: henyou-api
    spec:
      containers:
      - name: api
        image: henyou/api:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: henyou-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### 6.2 Monitoring Setup (Week 18)

#### Observability Stack
```yaml
# docker-compose.monitoring.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
  
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
  
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
```

## Risk Management

### High-Risk Areas
1. **Data Migration**: Potential data loss during migration
   - Mitigation: Multiple backups, dry runs, rollback procedures
   
2. **API Compatibility**: Breaking changes for existing app users
   - Mitigation: API versioning, gradual rollout, backwards compatibility

3. **Performance Degradation**: New system might be slower
   - Mitigation: Load testing, performance benchmarks, optimization

### Rollback Strategy
```bash
# Rollback procedure
1. Switch load balancer to old API
2. Restore database from backup
3. Deploy previous app version
4. Notify users of temporary issues
```

## Success Metrics

### Performance KPIs
- API Response Time: < 100ms (p95)
- Database Query Time: < 50ms (p95)
- App Load Time: < 2 seconds
- Crash-free Rate: > 99.5%

### Business KPIs
- User Retention: Maintain or improve
- Daily Active Users: 10% growth
- App Store Rating: ≥ 4.5 stars
- Server Costs: 30% reduction

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| Phase 1 | Weeks 1-3 | Security patches, migration plan |
| Phase 2 | Weeks 4-8 | Node.js API complete |
| Phase 3 | Weeks 9-10 | Database migrated |
| Phase 4 | Weeks 11-14 | Flutter app updated |
| Phase 5 | Weeks 15-16 | Full test coverage |
| Phase 6 | Weeks 17-18 | Production deployment |

## Budget Considerations

### Development Costs
- Backend Developer: 18 weeks
- Flutter Developer: 8 weeks (Phases 4-5)
- DevOps Engineer: 4 weeks (Phases 3, 6)
- QA Engineer: 4 weeks (Phase 5)

### Infrastructure Costs
- PostgreSQL RDS: ~$100/month
- Node.js hosting: ~$200/month
- Redis cache: ~$50/month
- Monitoring: ~$50/month

## Next Steps

1. **Immediate Actions**
   - Fix critical security vulnerabilities
   - Set up development environment
   - Create project tracking board

2. **Team Formation**
   - Assign project roles
   - Schedule kickoff meeting
   - Establish communication channels

3. **Technical Preparation**
   - Set up CI/CD pipeline
   - Create development databases
   - Configure monitoring tools

---

*This document should be treated as a living document and updated as the project progresses.*
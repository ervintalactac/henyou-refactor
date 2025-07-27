import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';

// Load environment variables
dotenv.config();

// Import configurations
import { databaseConfig } from './config/database';
import { redisConfig } from './config/redis';
import { logger } from './config/logger';

// Import middleware
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';
import { requestLogger } from './middleware/requestLogger';

// Import routes
import { authRoutes } from './routes/auth.routes';
import { userRoutes } from './routes/user.routes';
import { gameRoutes } from './routes/game.routes';
import { multiplayerRoutes } from './routes/multiplayer.routes';

class Server {
  private app: Application;
  private port: number;
  private server: any;
  private io: SocketIOServer;

  constructor() {
    this.app = express();
    this.port = parseInt(process.env.PORT || '3000', 10);
    this.server = createServer(this.app);
    this.io = new SocketIOServer(this.server, {
      cors: {
        origin: process.env.WS_CORS_ORIGIN || '*',
        methods: ['GET', 'POST']
      }
    });

    this.initializeMiddleware();
    this.initializeRoutes();
    this.initializeSocketIO();
    this.initializeErrorHandling();
  }

  private initializeMiddleware(): void {
    // Security middleware
    this.app.use(helmet());
    
    // CORS configuration
    this.app.use(cors({
      origin: process.env.CORS_ORIGIN || '*',
      credentials: true
    }));

    // Body parsing
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Logging
    this.app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
    this.app.use(requestLogger);

    // Rate limiting
    this.app.use('/api/', rateLimiter);

    // Health check endpoint
    this.app.get('/health', (req, res) => {
      res.status(200).json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV 
      });
    });
  }

  private initializeRoutes(): void {
    const apiPrefix = `/api/${process.env.API_VERSION || 'v1'}`;

    // Mount routes
    this.app.use(`${apiPrefix}/auth`, authRoutes);
    this.app.use(`${apiPrefix}/users`, userRoutes);
    this.app.use(`${apiPrefix}/games`, gameRoutes);
    this.app.use(`${apiPrefix}/multiplayer`, multiplayerRoutes);

    // 404 handler
    this.app.use('*', (req, res) => {
      res.status(404).json({
        status: 'error',
        message: 'Resource not found'
      });
    });
  }

  private initializeSocketIO(): void {
    // Socket.IO connection handling
    this.io.on('connection', (socket) => {
      logger.info(`New WebSocket connection: ${socket.id}`);

      // Join room
      socket.on('join:room', (data) => {
        socket.join(data.roomId);
        socket.to(data.roomId).emit('player:joined', {
          playerId: socket.id,
          playerName: data.playerName
        });
      });

      // Game events
      socket.on('game:guess', (data) => {
        socket.to(data.roomId).emit('game:guess', data);
      });

      socket.on('game:clue', (data) => {
        socket.to(data.roomId).emit('game:clue', data);
      });

      // Disconnect
      socket.on('disconnect', () => {
        logger.info(`WebSocket disconnected: ${socket.id}`);
      });
    });
  }

  private initializeErrorHandling(): void {
    this.app.use(errorHandler);

    // Unhandled promise rejection
    process.on('unhandledRejection', (error: Error) => {
      logger.error('Unhandled Promise Rejection:', error);
      // Close server gracefully
      this.server.close(() => {
        process.exit(1);
      });
    });

    // Uncaught exception
    process.on('uncaughtException', (error: Error) => {
      logger.error('Uncaught Exception:', error);
      // Close server gracefully
      this.server.close(() => {
        process.exit(1);
      });
    });
  }

  public async start(): Promise<void> {
    try {
      // Initialize database
      await databaseConfig.initialize();
      logger.info('Database connected successfully');

      // Initialize Redis
      await redisConfig.connect();
      logger.info('Redis connected successfully');

      // Start server
      this.server.listen(this.port, () => {
        logger.info(`Server running on port ${this.port} in ${process.env.NODE_ENV} mode`);
        logger.info(`API endpoint: http://localhost:${this.port}/api/${process.env.API_VERSION || 'v1'}`);
      });
    } catch (error) {
      logger.error('Failed to start server:', error);
      process.exit(1);
    }
  }
}

// Start the server
const server = new Server();
server.start();

export default server;
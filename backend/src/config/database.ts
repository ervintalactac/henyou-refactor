import { Pool, PoolConfig } from 'pg';
import { logger } from './logger';

class DatabaseConfig {
  private pool: Pool | null = null;
  private config: PoolConfig;

  constructor() {
    this.config = {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      database: process.env.DB_NAME || 'henyou_dev',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD,
      max: 20, // Maximum number of clients in the pool
      idleTimeoutMillis: 30000, // How long a client is allowed to remain idle before being closed
      connectionTimeoutMillis: 2000, // How long to wait when connecting a new client
    };

    // Add SSL configuration for production
    if (process.env.NODE_ENV === 'production' && process.env.DB_SSL === 'true') {
      this.config.ssl = {
        rejectUnauthorized: false
      };
    }
  }

  async initialize(): Promise<void> {
    try {
      this.pool = new Pool(this.config);
      
      // Test the connection
      const client = await this.pool.connect();
      await client.query('SELECT NOW()');
      client.release();
      
      logger.info('Database connection established successfully');
      
      // Set up error handlers
      this.pool.on('error', (err) => {
        logger.error('Unexpected database error:', err);
      });
    } catch (error) {
      logger.error('Failed to connect to database:', error);
      throw error;
    }
  }

  getPool(): Pool {
    if (!this.pool) {
      throw new Error('Database pool not initialized. Call initialize() first.');
    }
    return this.pool;
  }

  async close(): Promise<void> {
    if (this.pool) {
      await this.pool.end();
      logger.info('Database connection pool closed');
    }
  }

  // Helper method for transactions
  async transaction<T>(callback: (client: any) => Promise<T>): Promise<T> {
    const client = await this.getPool().connect();
    
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  // Helper method for single queries
  async query(text: string, params?: any[]): Promise<any> {
    const start = Date.now();
    
    try {
      const result = await this.getPool().query(text, params);
      const duration = Date.now() - start;
      
      logger.debug('Query executed', {
        text,
        duration,
        rows: result.rowCount
      });
      
      return result;
    } catch (error) {
      logger.error('Query error', { text, error });
      throw error;
    }
  }

  // Helper method to check if database is healthy
  async healthCheck(): Promise<boolean> {
    try {
      const result = await this.query('SELECT 1');
      return result.rows.length > 0;
    } catch (error) {
      logger.error('Database health check failed:', error);
      return false;
    }
  }
}

export const databaseConfig = new DatabaseConfig();
import { createClient, RedisClientType } from 'redis';
import { logger } from './logger';

class RedisConfig {
  private client: RedisClientType | null = null;

  async connect(): Promise<void> {
    try {
      this.client = createClient({
        url: `redis://${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}`,
        password: process.env.REDIS_PASSWORD || undefined,
      });

      // Error handling
      this.client.on('error', (err) => {
        logger.error('Redis Client Error:', err);
      });

      this.client.on('connect', () => {
        logger.info('Redis client connected');
      });

      this.client.on('ready', () => {
        logger.info('Redis client ready');
      });

      // Connect to Redis
      await this.client.connect();
    } catch (error) {
      logger.error('Failed to connect to Redis:', error);
      // Don't throw - Redis should be optional for development
      if (process.env.NODE_ENV === 'production') {
        throw error;
      }
    }
  }

  getClient(): RedisClientType {
    if (!this.client) {
      throw new Error('Redis client not initialized. Call connect() first.');
    }
    return this.client;
  }

  async disconnect(): Promise<void> {
    if (this.client) {
      await this.client.quit();
      logger.info('Redis client disconnected');
    }
  }

  // Cache helper methods
  async get(key: string): Promise<string | null> {
    try {
      return await this.getClient().get(key);
    } catch (error) {
      logger.error('Redis GET error:', error);
      return null;
    }
  }

  async set(key: string, value: string, ttl?: number): Promise<void> {
    try {
      if (ttl) {
        await this.getClient().setEx(key, ttl, value);
      } else {
        await this.getClient().set(key, value);
      }
    } catch (error) {
      logger.error('Redis SET error:', error);
    }
  }

  async del(key: string): Promise<void> {
    try {
      await this.getClient().del(key);
    } catch (error) {
      logger.error('Redis DEL error:', error);
    }
  }

  async exists(key: string): Promise<boolean> {
    try {
      const result = await this.getClient().exists(key);
      return result === 1;
    } catch (error) {
      logger.error('Redis EXISTS error:', error);
      return false;
    }
  }

  // Session management
  async setSession(sessionId: string, data: any, ttl: number = 3600): Promise<void> {
    await this.set(`session:${sessionId}`, JSON.stringify(data), ttl);
  }

  async getSession(sessionId: string): Promise<any | null> {
    const data = await this.get(`session:${sessionId}`);
    return data ? JSON.parse(data) : null;
  }

  async deleteSession(sessionId: string): Promise<void> {
    await this.del(`session:${sessionId}`);
  }

  // Rate limiting helpers
  async incrementCounter(key: string, ttl: number = 60): Promise<number> {
    try {
      const multi = this.getClient().multi();
      multi.incr(key);
      multi.expire(key, ttl);
      const results = await multi.exec();
      return results[0] as number;
    } catch (error) {
      logger.error('Redis increment counter error:', error);
      return 0;
    }
  }

  // Leaderboard helpers
  async addToLeaderboard(leaderboardKey: string, score: number, member: string): Promise<void> {
    try {
      await this.getClient().zAdd(leaderboardKey, { score, value: member });
    } catch (error) {
      logger.error('Redis leaderboard add error:', error);
    }
  }

  async getLeaderboard(leaderboardKey: string, start: number = 0, stop: number = 9): Promise<any[]> {
    try {
      const results = await this.getClient().zRangeWithScores(leaderboardKey, start, stop, { REV: true });
      return results.map((item, index) => ({
        rank: start + index + 1,
        member: item.value,
        score: item.score,
      }));
    } catch (error) {
      logger.error('Redis leaderboard get error:', error);
      return [];
    }
  }

  // Health check
  async healthCheck(): Promise<boolean> {
    try {
      const result = await this.getClient().ping();
      return result === 'PONG';
    } catch (error) {
      logger.error('Redis health check failed:', error);
      return false;
    }
  }
}

export const redisConfig = new RedisConfig();
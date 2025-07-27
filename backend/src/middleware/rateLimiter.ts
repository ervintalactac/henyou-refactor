import rateLimit from 'express-rate-limit';
import { Request, Response } from 'express';
import { redisConfig } from '../config/redis';
import { logger } from '../config/logger';

// Custom store using Redis
class RedisStore {
  windowMs: number;
  
  constructor(windowMs: number) {
    this.windowMs = windowMs;
  }

  async increment(key: string): Promise<{ totalHits: number; resetTime: Date }> {
    const ttl = Math.ceil(this.windowMs / 1000);
    const totalHits = await redisConfig.incrementCounter(key, ttl);
    const resetTime = new Date(Date.now() + this.windowMs);
    
    return { totalHits, resetTime };
  }

  async decrement(key: string): Promise<void> {
    // Not implemented as we don't need to decrement for rate limiting
  }

  async resetKey(key: string): Promise<void> {
    await redisConfig.del(key);
  }
}

// General API rate limiter
export const rateLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  // Use Redis store if available, otherwise use memory store
  store: redisConfig.getClient() ? new RedisStore(parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000')) : undefined,
  handler: (req: Request, res: Response) => {
    logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      status: 'error',
      message: 'Too many requests, please try again later',
      retryAfter: res.getHeader('Retry-After')
    });
  }
});

// Strict rate limiter for auth endpoints
export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 requests per windowMs
  message: 'Too many authentication attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Don't count successful requests
  store: redisConfig.getClient() ? new RedisStore(15 * 60 * 1000) : undefined,
  handler: (req: Request, res: Response) => {
    logger.warn(`Auth rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      status: 'error',
      message: 'Too many authentication attempts, please try again later',
      retryAfter: res.getHeader('Retry-After')
    });
  }
});

// Game action rate limiter
export const gameActionRateLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 60, // limit each IP to 60 game actions per minute
  message: 'Too many game actions, please slow down',
  standardHeaders: true,
  legacyHeaders: false,
  store: redisConfig.getClient() ? new RedisStore(1 * 60 * 1000) : undefined
});
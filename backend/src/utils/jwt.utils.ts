import jwt from 'jsonwebtoken';
import { JwtPayload, TokenPair } from '../types/auth.types';
import { logger } from '../config/logger';

export class JwtUtils {
  private static accessTokenSecret = process.env.JWT_SECRET || 'default_secret';
  private static refreshTokenSecret = process.env.JWT_REFRESH_SECRET || 'default_refresh_secret';
  private static accessTokenExpiry = process.env.JWT_EXPIRES_IN || '1h';
  private static refreshTokenExpiry = process.env.JWT_REFRESH_EXPIRES_IN || '7d';

  static generateTokenPair(payload: JwtPayload): TokenPair {
    try {
      const accessToken = jwt.sign(
        payload,
        this.accessTokenSecret,
        { expiresIn: this.accessTokenExpiry }
      );

      const refreshToken = jwt.sign(
        payload,
        this.refreshTokenSecret,
        { expiresIn: this.refreshTokenExpiry }
      );

      return { accessToken, refreshToken };
    } catch (error) {
      logger.error('Error generating token pair:', error);
      throw new Error('Failed to generate tokens');
    }
  }

  static verifyAccessToken(token: string): JwtPayload {
    try {
      return jwt.verify(token, this.accessTokenSecret) as JwtPayload;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new Error('Token expired');
      } else if (error instanceof jwt.JsonWebTokenError) {
        throw new Error('Invalid token');
      }
      throw error;
    }
  }

  static verifyRefreshToken(token: string): JwtPayload {
    try {
      return jwt.verify(token, this.refreshTokenSecret) as JwtPayload;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new Error('Refresh token expired');
      } else if (error instanceof jwt.JsonWebTokenError) {
        throw new Error('Invalid refresh token');
      }
      throw error;
    }
  }

  static generateAccessToken(payload: JwtPayload): string {
    return jwt.sign(payload, this.accessTokenSecret, {
      expiresIn: this.accessTokenExpiry
    });
  }

  static decodeToken(token: string): JwtPayload | null {
    try {
      return jwt.decode(token) as JwtPayload;
    } catch (error) {
      return null;
    }
  }

  static getTokenExpiry(token: string): Date | null {
    const decoded = this.decodeToken(token);
    if (decoded && decoded.exp) {
      return new Date(decoded.exp * 1000);
    }
    return null;
  }
}
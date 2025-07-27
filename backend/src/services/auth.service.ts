import { UserModel } from '../models/user.model';
import { JwtUtils } from '../utils/jwt.utils';
import { PasswordUtils } from '../utils/password.utils';
import { LoginCredentials, RegisterData, TokenPair } from '../types/auth.types';
import { User } from '../types/user.types';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../config/logger';
import { redisConfig } from '../config/redis';
import { databaseConfig } from '../config/database';

export class AuthService {
  static async register(data: RegisterData): Promise<{ user: User; tokens: TokenPair }> {
    // Validate password strength
    const passwordValidation = PasswordUtils.validatePasswordStrength(data.password);
    if (!passwordValidation.isValid) {
      throw new AppError(passwordValidation.errors.join(', '), 400);
    }

    // Check if username already exists
    const existingUser = await UserModel.findByUsername(data.username);
    if (existingUser) {
      throw new AppError('Username already exists', 409);
    }

    // Check if email already exists (if provided)
    if (data.email) {
      const existingEmail = await UserModel.findByEmail(data.email);
      if (existingEmail) {
        throw new AppError('Email already exists', 409);
      }
    }

    // Hash password
    const passwordHash = await PasswordUtils.hash(data.password);

    // Create user
    const user = await UserModel.create({
      username: data.username,
      email: data.email,
      passwordHash,
      displayName: data.displayName
    });

    // Create initial stats
    await UserModel.createOrUpdateStats(user.id, {
      totalGames: 0,
      gamesWon: 0,
      gamesLost: 0,
      totalScore: 0,
      highestScore: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalPlayTime: 0
    });

    // Generate tokens
    const tokens = JwtUtils.generateTokenPair({
      id: user.id,
      username: user.username,
      email: user.email
    });

    // Store refresh token in Redis
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    // Remove password hash from response
    const { passwordHash: _, ...userWithoutPassword } = user;

    logger.info(`New user registered: ${user.username}`);

    return {
      user: userWithoutPassword,
      tokens
    };
  }

  static async login(credentials: LoginCredentials): Promise<{ user: User; tokens: TokenPair }> {
    // Find user by username
    const user = await UserModel.findByUsername(credentials.username);
    if (!user) {
      throw new AppError('Invalid credentials', 401);
    }

    // Check if user is active
    if (!user.isActive) {
      throw new AppError('Account is deactivated', 403);
    }

    // Verify password
    if (!user.passwordHash) {
      throw new AppError('Invalid credentials', 401);
    }

    const isPasswordValid = await PasswordUtils.compare(credentials.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new AppError('Invalid credentials', 401);
    }

    // Update last login
    await UserModel.updateLastLogin(user.id);

    // Generate tokens
    const tokens = JwtUtils.generateTokenPair({
      id: user.id,
      username: user.username,
      email: user.email
    });

    // Store refresh token in Redis
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    // Remove password hash from response
    const { passwordHash: _, ...userWithoutPassword } = user;

    logger.info(`User logged in: ${user.username}`);

    return {
      user: userWithoutPassword,
      tokens
    };
  }

  static async refreshToken(refreshToken: string): Promise<TokenPair> {
    try {
      // Verify refresh token
      const decoded = JwtUtils.verifyRefreshToken(refreshToken);

      // Check if refresh token exists in Redis
      const storedToken = await redisConfig.get(`refresh_token:${decoded.id}`);
      if (!storedToken || storedToken !== refreshToken) {
        throw new AppError('Invalid refresh token', 401);
      }

      // Get user
      const user = await UserModel.findById(decoded.id);
      if (!user || !user.isActive) {
        throw new AppError('User not found or inactive', 401);
      }

      // Generate new token pair
      const tokens = JwtUtils.generateTokenPair({
        id: user.id,
        username: user.username,
        email: user.email
      });

      // Store new refresh token
      await this.storeRefreshToken(user.id, tokens.refreshToken);

      return tokens;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError('Invalid refresh token', 401);
    }
  }

  static async logout(userId: string): Promise<void> {
    // Remove refresh token from Redis
    await redisConfig.del(`refresh_token:${userId}`);
    logger.info(`User logged out: ${userId}`);
  }

  static async validateToken(token: string): Promise<boolean> {
    try {
      JwtUtils.verifyAccessToken(token);
      return true;
    } catch (error) {
      return false;
    }
  }

  private static async storeRefreshToken(userId: string, refreshToken: string): Promise<void> {
    const expiry = JwtUtils.getTokenExpiry(refreshToken);
    if (expiry) {
      const ttl = Math.floor((expiry.getTime() - Date.now()) / 1000);
      await redisConfig.set(`refresh_token:${userId}`, refreshToken, ttl);
    }
  }

  static async changePassword(userId: string, oldPassword: string, newPassword: string): Promise<void> {
    // Get user
    const user = await UserModel.findById(userId);
    if (!user || !user.passwordHash) {
      throw new AppError('User not found', 404);
    }

    // Verify old password
    const isOldPasswordValid = await PasswordUtils.compare(oldPassword, user.passwordHash);
    if (!isOldPasswordValid) {
      throw new AppError('Invalid old password', 401);
    }

    // Validate new password
    const passwordValidation = PasswordUtils.validatePasswordStrength(newPassword);
    if (!passwordValidation.isValid) {
      throw new AppError(passwordValidation.errors.join(', '), 400);
    }

    // Hash new password
    const newPasswordHash = await PasswordUtils.hash(newPassword);

    // Update password in database
    await databaseConfig.query(
      'UPDATE users SET password_hash = $1 WHERE id = $2',
      [newPasswordHash, userId]
    );

    // Invalidate all refresh tokens
    await redisConfig.del(`refresh_token:${userId}`);

    logger.info(`Password changed for user: ${userId}`);
  }
}
import { UserModel } from '../models/user.model';
import { User, UserProfile, UpdateUserData, UserStats } from '../types/user.types';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../config/logger';
import { databaseConfig } from '../config/database';
import { redisConfig } from '../config/redis';

export class UserService {
  static async getUserProfile(userId: string): Promise<UserProfile> {
    // Try to get from cache first
    const cacheKey = `user_profile:${userId}`;
    const cached = await redisConfig.get(cacheKey);
    
    if (cached) {
      return JSON.parse(cached);
    }

    // Get user from database
    const user = await UserModel.findById(userId);
    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Get user stats
    const stats = await UserModel.getStats(userId);

    // Remove sensitive data
    const { passwordHash, ...userWithoutPassword } = user;

    const profile: UserProfile = {
      ...userWithoutPassword,
      stats: stats || undefined
    };

    // Cache for 5 minutes
    await redisConfig.set(cacheKey, JSON.stringify(profile), 300);

    return profile;
  }

  static async updateUserProfile(userId: string, data: UpdateUserData): Promise<User> {
    // Validate email uniqueness if provided
    if (data.email) {
      const existingUser = await UserModel.findByEmail(data.email);
      if (existingUser && existingUser.id !== userId) {
        throw new AppError('Email already in use', 409);
      }
    }

    // Update user
    const updatedUser = await UserModel.update(userId, data);
    if (!updatedUser) {
      throw new AppError('User not found', 404);
    }

    // Invalidate cache
    await redisConfig.del(`user_profile:${userId}`);

    // Remove sensitive data
    const { passwordHash, ...userWithoutPassword } = updatedUser;

    logger.info(`User profile updated: ${userId}`);

    return userWithoutPassword;
  }

  static async getUserStats(userId: string): Promise<UserStats> {
    const stats = await UserModel.getStats(userId);
    if (!stats) {
      // Create default stats if they don't exist
      return await UserModel.createOrUpdateStats(userId, {
        totalGames: 0,
        gamesWon: 0,
        gamesLost: 0,
        totalScore: 0,
        highestScore: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalPlayTime: 0
      });
    }
    return stats;
  }

  static async updateUserStats(
    userId: string, 
    updates: Partial<UserStats>
  ): Promise<UserStats> {
    const updatedStats = await UserModel.createOrUpdateStats(userId, updates);
    
    // Invalidate cache
    await redisConfig.del(`user_profile:${userId}`);
    
    return updatedStats;
  }

  static async getLeaderboard(
    timeframe: 'all' | 'weekly' | 'monthly' = 'all',
    limit: number = 100,
    offset: number = 0
  ): Promise<any[]> {
    const cacheKey = `leaderboard:${timeframe}:${limit}:${offset}`;
    const cached = await redisConfig.get(cacheKey);
    
    if (cached) {
      return JSON.parse(cached);
    }

    let query: string;
    const params: any[] = [limit, offset];

    switch (timeframe) {
      case 'weekly':
        query = `
          SELECT 
            u.id,
            u.username,
            u.display_name,
            u.avatar_url,
            us.total_score,
            us.games_won,
            us.current_streak,
            RANK() OVER (ORDER BY us.total_score DESC) as rank
          FROM users u
          JOIN user_stats us ON u.id = us.user_id
          WHERE us.updated_at >= CURRENT_DATE - INTERVAL '7 days'
          ORDER BY us.total_score DESC
          LIMIT $1 OFFSET $2
        `;
        break;

      case 'monthly':
        query = `
          SELECT 
            u.id,
            u.username,
            u.display_name,
            u.avatar_url,
            us.total_score,
            us.games_won,
            us.current_streak,
            RANK() OVER (ORDER BY us.total_score DESC) as rank
          FROM users u
          JOIN user_stats us ON u.id = us.user_id
          WHERE us.updated_at >= CURRENT_DATE - INTERVAL '30 days'
          ORDER BY us.total_score DESC
          LIMIT $1 OFFSET $2
        `;
        break;

      default: // 'all'
        query = `
          SELECT 
            u.id,
            u.username,
            u.display_name,
            u.avatar_url,
            us.total_score,
            us.games_won,
            us.current_streak,
            RANK() OVER (ORDER BY us.total_score DESC) as rank
          FROM users u
          JOIN user_stats us ON u.id = us.user_id
          ORDER BY us.total_score DESC
          LIMIT $1 OFFSET $2
        `;
    }

    const result = await databaseConfig.query(query, params);
    
    // Cache for 1 minute
    await redisConfig.set(cacheKey, JSON.stringify(result.rows), 60);
    
    return result.rows;
  }

  static async getUserAchievements(userId: string): Promise<any[]> {
    const query = `
      SELECT 
        a.id,
        a.code,
        a.name,
        a.description,
        a.icon_url,
        a.points,
        ua.earned_at,
        ua.progress
      FROM achievements a
      JOIN user_achievements ua ON a.id = ua.achievement_id
      WHERE ua.user_id = $1
      ORDER BY ua.earned_at DESC
    `;

    const result = await databaseConfig.query(query, [userId]);
    return result.rows;
  }

  static async searchUsers(
    searchTerm: string,
    limit: number = 20
  ): Promise<any[]> {
    const query = `
      SELECT 
        id,
        username,
        display_name,
        avatar_url
      FROM users
      WHERE 
        (LOWER(username) LIKE LOWER($1) OR LOWER(display_name) LIKE LOWER($1))
        AND is_active = true
      ORDER BY 
        CASE 
          WHEN LOWER(username) = LOWER($2) THEN 0
          WHEN LOWER(username) LIKE LOWER($3) THEN 1
          ELSE 2
        END,
        username
      LIMIT $4
    `;

    const searchPattern = `%${searchTerm}%`;
    const result = await databaseConfig.query(query, [
      searchPattern,
      searchTerm,
      `${searchTerm}%`,
      limit
    ]);

    return result.rows;
  }

  static async getUserGameHistory(
    userId: string,
    limit: number = 20,
    offset: number = 0
  ): Promise<any[]> {
    const query = `
      SELECT 
        gs.id,
        gs.game_mode,
        gs.status,
        gs.created_at,
        gs.ended_at,
        gp.score,
        gp.rounds_won,
        gp.role,
        COUNT(DISTINCT gp2.user_id) as total_players
      FROM game_sessions gs
      JOIN game_participants gp ON gs.id = gp.game_session_id
      LEFT JOIN game_participants gp2 ON gs.id = gp2.game_session_id
      WHERE gp.user_id = $1
      GROUP BY gs.id, gp.score, gp.rounds_won, gp.role
      ORDER BY gs.created_at DESC
      LIMIT $2 OFFSET $3
    `;

    const result = await databaseConfig.query(query, [userId, limit, offset]);
    return result.rows;
  }

  static async deactivateUser(userId: string): Promise<void> {
    const query = 'UPDATE users SET is_active = false WHERE id = $1';
    await databaseConfig.query(query, [userId]);
    
    // Invalidate all user sessions
    await redisConfig.del(`refresh_token:${userId}`);
    await redisConfig.del(`user_profile:${userId}`);
    
    logger.info(`User deactivated: ${userId}`);
  }

  static async reactivateUser(userId: string): Promise<void> {
    const query = 'UPDATE users SET is_active = true WHERE id = $1';
    await databaseConfig.query(query, [userId]);
    
    logger.info(`User reactivated: ${userId}`);
  }
}
import { databaseConfig } from '../config/database';
import { User, UserStats, UpdateUserData } from '../types/user.types';
import { logger } from '../config/logger';

export class UserModel {
  static async create(userData: {
    username: string;
    email?: string;
    passwordHash?: string;
    displayName?: string;
  }): Promise<User> {
    const query = `
      INSERT INTO users (username, email, password_hash, display_name)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    
    const values = [
      userData.username,
      userData.email || null,
      userData.passwordHash || null,
      userData.displayName || userData.username
    ];

    try {
      const result = await databaseConfig.query(query, values);
      return this.mapRowToUser(result.rows[0]);
    } catch (error) {
      logger.error('Error creating user:', error);
      throw error;
    }
  }

  static async findById(id: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE id = $1';
    
    try {
      const result = await databaseConfig.query(query, [id]);
      return result.rows[0] ? this.mapRowToUser(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error finding user by id:', error);
      throw error;
    }
  }

  static async findByUsername(username: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE username = $1';
    
    try {
      const result = await databaseConfig.query(query, [username]);
      return result.rows[0] ? this.mapRowToUser(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error finding user by username:', error);
      throw error;
    }
  }

  static async findByEmail(email: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE email = $1';
    
    try {
      const result = await databaseConfig.query(query, [email]);
      return result.rows[0] ? this.mapRowToUser(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error finding user by email:', error);
      throw error;
    }
  }

  static async update(id: string, data: UpdateUserData): Promise<User | null> {
    const fields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (data.displayName !== undefined) {
      fields.push(`display_name = $${paramCount++}`);
      values.push(data.displayName);
    }

    if (data.email !== undefined) {
      fields.push(`email = $${paramCount++}`);
      values.push(data.email);
    }

    if (data.avatarUrl !== undefined) {
      fields.push(`avatar_url = $${paramCount++}`);
      values.push(data.avatarUrl);
    }

    if (data.metadata !== undefined) {
      fields.push(`metadata = $${paramCount++}`);
      values.push(JSON.stringify(data.metadata));
    }

    if (fields.length === 0) {
      return this.findById(id);
    }

    values.push(id);
    const query = `
      UPDATE users 
      SET ${fields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    try {
      const result = await databaseConfig.query(query, values);
      return result.rows[0] ? this.mapRowToUser(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error updating user:', error);
      throw error;
    }
  }

  static async updateLastLogin(id: string): Promise<void> {
    const query = 'UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE id = $1';
    
    try {
      await databaseConfig.query(query, [id]);
    } catch (error) {
      logger.error('Error updating last login:', error);
      throw error;
    }
  }

  static async createOrUpdateStats(userId: string, stats: Partial<UserStats>): Promise<UserStats> {
    const query = `
      INSERT INTO user_stats (user_id, total_games, games_won, games_lost, total_score, 
        highest_score, current_streak, longest_streak, average_guess_time, total_play_time)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      ON CONFLICT (user_id) DO UPDATE SET
        total_games = COALESCE($2, user_stats.total_games),
        games_won = COALESCE($3, user_stats.games_won),
        games_lost = COALESCE($4, user_stats.games_lost),
        total_score = COALESCE($5, user_stats.total_score),
        highest_score = GREATEST(COALESCE($6, user_stats.highest_score), user_stats.highest_score),
        current_streak = COALESCE($7, user_stats.current_streak),
        longest_streak = GREATEST(COALESCE($8, user_stats.longest_streak), user_stats.longest_streak),
        average_guess_time = COALESCE($9, user_stats.average_guess_time),
        total_play_time = COALESCE($10, user_stats.total_play_time)
      RETURNING *
    `;

    const values = [
      userId,
      stats.totalGames || 0,
      stats.gamesWon || 0,
      stats.gamesLost || 0,
      stats.totalScore || 0,
      stats.highestScore || 0,
      stats.currentStreak || 0,
      stats.longestStreak || 0,
      stats.averageGuessTime || null,
      stats.totalPlayTime || 0
    ];

    try {
      const result = await databaseConfig.query(query, values);
      return this.mapRowToUserStats(result.rows[0]);
    } catch (error) {
      logger.error('Error creating/updating user stats:', error);
      throw error;
    }
  }

  static async getStats(userId: string): Promise<UserStats | null> {
    const query = 'SELECT * FROM user_stats WHERE user_id = $1';
    
    try {
      const result = await databaseConfig.query(query, [userId]);
      return result.rows[0] ? this.mapRowToUserStats(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error getting user stats:', error);
      throw error;
    }
  }

  private static mapRowToUser(row: any): User {
    return {
      id: row.id,
      username: row.username,
      email: row.email,
      passwordHash: row.password_hash,
      displayName: row.display_name,
      avatarUrl: row.avatar_url,
      isActive: row.is_active,
      isVerified: row.is_verified,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      lastLoginAt: row.last_login_at,
      metadata: row.metadata
    };
  }

  private static mapRowToUserStats(row: any): UserStats {
    return {
      id: row.id,
      userId: row.user_id,
      totalGames: row.total_games,
      gamesWon: row.games_won,
      gamesLost: row.games_lost,
      totalScore: row.total_score,
      highestScore: row.highest_score,
      currentStreak: row.current_streak,
      longestStreak: row.longest_streak,
      averageGuessTime: row.average_guess_time,
      totalPlayTime: row.total_play_time,
      favoriteCategory: row.favorite_category,
      achievements: row.achievements || [],
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };
  }
}
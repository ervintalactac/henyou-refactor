import { databaseConfig } from '../config/database';
import { Word, WordDifficulty } from '../types/game.types';
import { logger } from '../config/logger';

export class WordModel {
  static async findById(id: string): Promise<Word | null> {
    const query = 'SELECT * FROM words WHERE id = $1';
    
    try {
      const result = await databaseConfig.query(query, [id]);
      return result.rows[0] ? this.mapRowToWord(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error finding word by id:', error);
      throw error;
    }
  }

  static async getRandomWord(options?: {
    category?: string;
    difficulty?: WordDifficulty;
    language?: string;
    excludeIds?: string[];
  }): Promise<Word | null> {
    const conditions: string[] = ['is_active = true'];
    const params: any[] = [];
    let paramCount = 1;

    if (options?.category) {
      conditions.push(`category = $${paramCount++}`);
      params.push(options.category);
    }

    if (options?.difficulty) {
      conditions.push(`difficulty = $${paramCount++}`);
      params.push(options.difficulty);
    }

    if (options?.language) {
      conditions.push(`language = $${paramCount++}`);
      params.push(options.language);
    }

    if (options?.excludeIds && options.excludeIds.length > 0) {
      conditions.push(`id NOT IN (${options.excludeIds.map((_, i) => `$${paramCount + i}`).join(', ')})`);
      params.push(...options.excludeIds);
    }

    const query = `
      SELECT * FROM words 
      WHERE ${conditions.join(' AND ')}
      ORDER BY RANDOM()
      LIMIT 1
    `;

    try {
      const result = await databaseConfig.query(query, params);
      return result.rows[0] ? this.mapRowToWord(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error getting random word:', error);
      throw error;
    }
  }

  static async getMultipleRandomWords(
    count: number,
    options?: {
      category?: string;
      difficulty?: WordDifficulty;
      language?: string;
    }
  ): Promise<Word[]> {
    const conditions: string[] = ['is_active = true'];
    const params: any[] = [];
    let paramCount = 1;

    if (options?.category) {
      conditions.push(`category = $${paramCount++}`);
      params.push(options.category);
    }

    if (options?.difficulty) {
      conditions.push(`difficulty = $${paramCount++}`);
      params.push(options.difficulty);
    }

    if (options?.language) {
      conditions.push(`language = $${paramCount++}`);
      params.push(options.language);
    }

    params.push(count);
    
    const query = `
      SELECT * FROM words 
      WHERE ${conditions.join(' AND ')}
      ORDER BY RANDOM()
      LIMIT $${paramCount}
    `;

    try {
      const result = await databaseConfig.query(query, params);
      return result.rows.map(row => this.mapRowToWord(row));
    } catch (error) {
      logger.error('Error getting multiple random words:', error);
      throw error;
    }
  }

  static async getCategories(language?: string): Promise<string[]> {
    const query = language
      ? 'SELECT DISTINCT category FROM words WHERE is_active = true AND language = $1 ORDER BY category'
      : 'SELECT DISTINCT category FROM words WHERE is_active = true ORDER BY category';
    
    const params = language ? [language] : [];

    try {
      const result = await databaseConfig.query(query, params);
      return result.rows.map(row => row.category);
    } catch (error) {
      logger.error('Error getting categories:', error);
      throw error;
    }
  }

  static async incrementUsage(wordId: string, wasCorrect: boolean): Promise<void> {
    const query = `
      UPDATE words 
      SET 
        usage_count = usage_count + 1,
        success_rate = CASE 
          WHEN usage_count = 0 THEN $1::decimal
          ELSE ((success_rate * usage_count) + $1::decimal) / (usage_count + 1)
        END
      WHERE id = $2
    `;

    try {
      await databaseConfig.query(query, [wasCorrect ? 100 : 0, wordId]);
    } catch (error) {
      logger.error('Error incrementing word usage:', error);
      throw error;
    }
  }

  static async searchWords(
    searchTerm: string,
    limit: number = 50
  ): Promise<Word[]> {
    const query = `
      SELECT * FROM words
      WHERE 
        LOWER(word) LIKE LOWER($1)
        AND is_active = true
      ORDER BY word
      LIMIT $2
    `;

    try {
      const result = await databaseConfig.query(query, [`%${searchTerm}%`, limit]);
      return result.rows.map(row => this.mapRowToWord(row));
    } catch (error) {
      logger.error('Error searching words:', error);
      throw error;
    }
  }

  static async create(wordData: {
    word: string;
    category: string;
    difficulty: WordDifficulty;
    language: string;
    hints?: string[];
    tags?: string[];
  }): Promise<Word> {
    const query = `
      INSERT INTO words (word, category, difficulty, language, hints, tags)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;

    const values = [
      wordData.word,
      wordData.category,
      wordData.difficulty,
      wordData.language,
      wordData.hints || [],
      wordData.tags || []
    ];

    try {
      const result = await databaseConfig.query(query, values);
      return this.mapRowToWord(result.rows[0]);
    } catch (error) {
      logger.error('Error creating word:', error);
      throw error;
    }
  }

  static async update(
    id: string,
    updates: Partial<{
      word: string;
      category: string;
      difficulty: WordDifficulty;
      hints: string[];
      tags: string[];
      isActive: boolean;
    }>
  ): Promise<Word | null> {
    const fields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    Object.entries(updates).forEach(([key, value]) => {
      if (value !== undefined) {
        const columnName = key === 'isActive' ? 'is_active' : key;
        fields.push(`${columnName} = $${paramCount++}`);
        values.push(value);
      }
    });

    if (fields.length === 0) {
      return this.findById(id);
    }

    values.push(id);
    const query = `
      UPDATE words 
      SET ${fields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    try {
      const result = await databaseConfig.query(query, values);
      return result.rows[0] ? this.mapRowToWord(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error updating word:', error);
      throw error;
    }
  }

  private static mapRowToWord(row: any): Word {
    return {
      id: row.id,
      word: row.word,
      category: row.category,
      difficulty: row.difficulty,
      language: row.language,
      hints: row.hints,
      tags: row.tags,
      usageCount: row.usage_count,
      successRate: parseFloat(row.success_rate),
      isActive: row.is_active
    };
  }
}
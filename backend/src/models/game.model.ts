import { databaseConfig } from '../config/database';
import { 
  GameSession, 
  GameParticipant, 
  GameRound, 
  GameMode, 
  GameStatus,
  PlayerRole,
  Guess,
  Clue
} from '../types/game.types';
import { logger } from '../config/logger';

export class GameModel {
  // Game Session methods
  static async createSession(data: {
    hostId: string;
    gameMode: GameMode;
    maxPlayers?: number;
    totalRounds?: number;
    timeLimit?: number;
    settings?: Record<string, any>;
  }): Promise<GameSession> {
    const roomCode = await this.generateUniqueRoomCode();
    
    const query = `
      INSERT INTO game_sessions 
      (room_code, host_id, game_mode, max_players, total_rounds, time_limit, settings)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

    const values = [
      roomCode,
      data.hostId,
      data.gameMode,
      data.maxPlayers || 2,
      data.totalRounds || 5,
      data.timeLimit || 120,
      JSON.stringify(data.settings || {})
    ];

    try {
      const result = await databaseConfig.query(query, values);
      return this.mapRowToGameSession(result.rows[0]);
    } catch (error) {
      logger.error('Error creating game session:', error);
      throw error;
    }
  }

  static async findSessionById(id: string): Promise<GameSession | null> {
    const query = 'SELECT * FROM game_sessions WHERE id = $1';
    
    try {
      const result = await databaseConfig.query(query, [id]);
      return result.rows[0] ? this.mapRowToGameSession(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error finding game session:', error);
      throw error;
    }
  }

  static async findSessionByRoomCode(roomCode: string): Promise<GameSession | null> {
    const query = 'SELECT * FROM game_sessions WHERE room_code = $1';
    
    try {
      const result = await databaseConfig.query(query, [roomCode]);
      return result.rows[0] ? this.mapRowToGameSession(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error finding game session by room code:', error);
      throw error;
    }
  }

  static async updateSessionStatus(
    sessionId: string, 
    status: GameStatus
  ): Promise<GameSession | null> {
    const updates: Record<string, any> = { status };
    
    if (status === 'in_progress') {
      updates.started_at = 'CURRENT_TIMESTAMP';
    } else if (status === 'completed' || status === 'abandoned') {
      updates.ended_at = 'CURRENT_TIMESTAMP';
    }

    const setClause = Object.keys(updates)
      .map((key, index) => `${key} = ${updates[key] === 'CURRENT_TIMESTAMP' ? 'CURRENT_TIMESTAMP' : `$${index + 2}`}`)
      .join(', ');

    const values = [sessionId];
    Object.values(updates).forEach(value => {
      if (value !== 'CURRENT_TIMESTAMP') {
        values.push(value);
      }
    });

    const query = `
      UPDATE game_sessions 
      SET ${setClause}
      WHERE id = $1
      RETURNING *
    `;

    try {
      const result = await databaseConfig.query(query, values);
      return result.rows[0] ? this.mapRowToGameSession(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error updating game session status:', error);
      throw error;
    }
  }

  // Game Participant methods
  static async addParticipant(data: {
    gameSessionId: string;
    userId: string;
    role?: PlayerRole;
  }): Promise<GameParticipant> {
    const query = `
      INSERT INTO game_participants (game_session_id, user_id, role)
      VALUES ($1, $2, $3)
      RETURNING *
    `;

    const values = [
      data.gameSessionId,
      data.userId,
      data.role || 'guesser'
    ];

    try {
      const result = await databaseConfig.query(query, values);
      return this.mapRowToGameParticipant(result.rows[0]);
    } catch (error) {
      logger.error('Error adding game participant:', error);
      throw error;
    }
  }

  static async getSessionParticipants(sessionId: string): Promise<GameParticipant[]> {
    const query = `
      SELECT * FROM game_participants 
      WHERE game_session_id = $1 
      ORDER BY joined_at
    `;

    try {
      const result = await databaseConfig.query(query, [sessionId]);
      return result.rows.map(row => this.mapRowToGameParticipant(row));
    } catch (error) {
      logger.error('Error getting session participants:', error);
      throw error;
    }
  }

  static async updateParticipantScore(
    sessionId: string,
    userId: string,
    scoreIncrement: number,
    wonRound: boolean = false
  ): Promise<void> {
    const query = `
      UPDATE game_participants 
      SET 
        score = score + $3,
        rounds_won = rounds_won + $4
      WHERE game_session_id = $1 AND user_id = $2
    `;

    try {
      await databaseConfig.query(query, [
        sessionId,
        userId,
        scoreIncrement,
        wonRound ? 1 : 0
      ]);
    } catch (error) {
      logger.error('Error updating participant score:', error);
      throw error;
    }
  }

  // Game Round methods
  static async createRound(data: {
    gameSessionId: string;
    roundNumber: number;
    wordId: string;
    guesserId: string;
    clueGiverId?: string;
  }): Promise<GameRound> {
    const query = `
      INSERT INTO game_rounds 
      (game_session_id, round_number, word_id, guesser_id, clue_giver_id)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;

    const values = [
      data.gameSessionId,
      data.roundNumber,
      data.wordId,
      data.guesserId,
      data.clueGiverId || null
    ];

    try {
      const result = await databaseConfig.query(query, values);
      return this.mapRowToGameRound(result.rows[0]);
    } catch (error) {
      logger.error('Error creating game round:', error);
      throw error;
    }
  }

  static async getCurrentRound(sessionId: string): Promise<GameRound | null> {
    const query = `
      SELECT * FROM game_rounds 
      WHERE game_session_id = $1 AND status IN ('waiting', 'in_progress')
      ORDER BY round_number DESC
      LIMIT 1
    `;

    try {
      const result = await databaseConfig.query(query, [sessionId]);
      return result.rows[0] ? this.mapRowToGameRound(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error getting current round:', error);
      throw error;
    }
  }

  static async addGuess(
    roundId: string,
    guess: string,
    correct: boolean
  ): Promise<void> {
    const query = `
      UPDATE game_rounds 
      SET guesses = guesses || $2::jsonb
      WHERE id = $1
    `;

    const guessData = JSON.stringify({
      guess,
      timestamp: new Date().toISOString(),
      correct
    });

    try {
      await databaseConfig.query(query, [roundId, guessData]);
    } catch (error) {
      logger.error('Error adding guess:', error);
      throw error;
    }
  }

  static async addClue(
    roundId: string,
    clue: string,
    type: string = 'text'
  ): Promise<void> {
    const query = `
      UPDATE game_rounds 
      SET clues = clues || $2::jsonb
      WHERE id = $1
    `;

    const clueData = JSON.stringify({
      clue,
      type,
      timestamp: new Date().toISOString()
    });

    try {
      await databaseConfig.query(query, [roundId, clueData]);
    } catch (error) {
      logger.error('Error adding clue:', error);
      throw error;
    }
  }

  static async completeRound(
    roundId: string,
    timeTaken: number,
    scoreEarned: number
  ): Promise<GameRound | null> {
    const query = `
      UPDATE game_rounds 
      SET 
        status = 'completed',
        time_taken = $2,
        score_earned = $3,
        completed_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;

    try {
      const result = await databaseConfig.query(query, [roundId, timeTaken, scoreEarned]);
      return result.rows[0] ? this.mapRowToGameRound(result.rows[0]) : null;
    } catch (error) {
      logger.error('Error completing round:', error);
      throw error;
    }
  }

  // Helper methods
  private static async generateUniqueRoomCode(): Promise<string> {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code: string;
    let exists: boolean;

    do {
      code = '';
      for (let i = 0; i < 6; i++) {
        code += characters.charAt(Math.floor(Math.random() * characters.length));
      }

      const result = await databaseConfig.query(
        'SELECT EXISTS(SELECT 1 FROM game_sessions WHERE room_code = $1)',
        [code]
      );
      exists = result.rows[0].exists;
    } while (exists);

    return code;
  }

  // Mapping methods
  private static mapRowToGameSession(row: any): GameSession {
    return {
      id: row.id,
      roomCode: row.room_code,
      hostId: row.host_id,
      gameMode: row.game_mode,
      status: row.status,
      maxPlayers: row.max_players,
      currentRound: row.current_round,
      totalRounds: row.total_rounds,
      timeLimit: row.time_limit,
      settings: row.settings,
      startedAt: row.started_at,
      endedAt: row.ended_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };
  }

  private static mapRowToGameParticipant(row: any): GameParticipant {
    return {
      id: row.id,
      gameSessionId: row.game_session_id,
      userId: row.user_id,
      role: row.role,
      score: row.score,
      roundsWon: row.rounds_won,
      averageTime: row.average_time,
      isReady: row.is_ready,
      joinedAt: row.joined_at,
      leftAt: row.left_at
    };
  }

  private static mapRowToGameRound(row: any): GameRound {
    return {
      id: row.id,
      gameSessionId: row.game_session_id,
      roundNumber: row.round_number,
      wordId: row.word_id,
      guesserId: row.guesser_id,
      clueGiverId: row.clue_giver_id,
      status: row.status,
      timeTaken: row.time_taken,
      guesses: row.guesses || [],
      clues: row.clues || [],
      scoreEarned: row.score_earned,
      startedAt: row.started_at,
      completedAt: row.completed_at,
      createdAt: row.created_at
    };
  }
}
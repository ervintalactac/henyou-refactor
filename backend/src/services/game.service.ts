import { GameModel } from '../models/game.model';
import { WordModel } from '../models/word.model';
import { UserModel } from '../models/user.model';
import {
  CreateGameData,
  GameSession,
  GameParticipant,
  GameRound,
  GameResult,
  GameGuessData,
  GameMode
} from '../types/game.types';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../config/logger';
import { redisConfig } from '../config/redis';
import { databaseConfig } from '../config/database';

export class GameService {
  static async createGame(
    userId: string,
    data: CreateGameData
  ): Promise<{ session: GameSession; participant: GameParticipant }> {
    // Create game session
    const session = await GameModel.createSession({
      hostId: userId,
      gameMode: data.gameMode,
      settings: data.settings,
      maxPlayers: this.getMaxPlayersForMode(data.gameMode),
      totalRounds: this.getTotalRoundsForMode(data.gameMode),
      timeLimit: data.settings?.timeLimit || 120
    });

    // Add host as participant
    const participant = await GameModel.addParticipant({
      gameSessionId: session.id,
      userId,
      role: data.gameMode === 'multiplayer' ? 'clue_giver' : 'guesser'
    });

    // Cache room code for quick lookup
    if (session.roomCode) {
      await redisConfig.set(
        `room:${session.roomCode}`,
        session.id,
        3600 // 1 hour TTL
      );
    }

    logger.info(`Game created: ${session.id} by user ${userId}`);

    return { session, participant };
  }

  static async joinGame(
    userId: string,
    roomCode: string
  ): Promise<{ session: GameSession; participant: GameParticipant }> {
    // Get session ID from cache or database
    let sessionId = await redisConfig.get(`room:${roomCode}`);
    let session: GameSession | null;

    if (sessionId) {
      session = await GameModel.findSessionById(sessionId);
    } else {
      session = await GameModel.findSessionByRoomCode(roomCode);
      if (session) {
        // Cache for future lookups
        await redisConfig.set(`room:${roomCode}`, session.id, 3600);
      }
    }

    if (!session) {
      throw new AppError('Room not found', 404);
    }

    if (session.status !== 'waiting') {
      throw new AppError('Game already started', 400);
    }

    // Check if room is full
    const participants = await GameModel.getSessionParticipants(session.id);
    if (participants.length >= session.maxPlayers) {
      throw new AppError('Room is full', 400);
    }

    // Check if user already in game
    const existingParticipant = participants.find(p => p.userId === userId);
    if (existingParticipant) {
      return { session, participant: existingParticipant };
    }

    // Add participant
    const participant = await GameModel.addParticipant({
      gameSessionId: session.id,
      userId,
      role: this.assignRole(session.gameMode, participants)
    });

    logger.info(`User ${userId} joined game ${session.id}`);

    return { session, participant };
  }

  static async startGame(sessionId: string, userId: string): Promise<GameRound> {
    const session = await GameModel.findSessionById(sessionId);
    if (!session) {
      throw new AppError('Game not found', 404);
    }

    if (session.hostId !== userId) {
      throw new AppError('Only host can start the game', 403);
    }

    if (session.status !== 'waiting') {
      throw new AppError('Game already started', 400);
    }

    const participants = await GameModel.getSessionParticipants(sessionId);
    const minPlayers = this.getMinPlayersForMode(session.gameMode);

    if (participants.length < minPlayers) {
      throw new AppError(`Need at least ${minPlayers} players to start`, 400);
    }

    // Update session status
    await GameModel.updateSessionStatus(sessionId, 'in_progress');

    // Create first round
    const round = await this.createNextRound(session, 1);

    logger.info(`Game started: ${sessionId}`);

    return round;
  }

  static async submitGuess(data: GameGuessData): Promise<{
    correct: boolean;
    score: number;
    word?: string;
  }> {
    const round = await GameModel.getCurrentRound(data.gameSessionId);
    if (!round) {
      throw new AppError('No active round', 404);
    }

    // Get the word
    const word = await WordModel.findById(round.wordId);
    if (!word) {
      throw new AppError('Word not found', 404);
    }

    // Check if guess is correct
    const correct = this.checkGuess(data.guess, word.word);

    // Add guess to round
    await GameModel.addGuess(round.id, data.guess, correct);

    let score = 0;
    let returnWord: string | undefined;

    if (correct) {
      // Calculate score based on time and attempts
      const timeTaken = Math.floor(
        (Date.now() - new Date(round.startedAt || round.createdAt).getTime()) / 1000
      );
      score = this.calculateScore(timeTaken, round.guesses.length + 1);

      // Complete the round
      await GameModel.completeRound(round.id, timeTaken, score);

      // Update participant score
      await GameModel.updateParticipantScore(
        data.gameSessionId,
        round.guesserId,
        score,
        true
      );

      // Update word usage stats
      await WordModel.incrementUsage(word.id, true);

      returnWord = word.word;

      // Update user stats
      const userStats = await UserModel.getStats(round.guesserId);
      await UserModel.createOrUpdateStats(round.guesserId, {
        totalGames: (userStats?.totalGames || 0) + 1,
        gamesWon: (userStats?.gamesWon || 0) + 1,
        totalScore: (userStats?.totalScore || 0) + score,
        highestScore: Math.max(userStats?.highestScore || 0, score),
        currentStreak: (userStats?.currentStreak || 0) + 1,
        longestStreak: Math.max((userStats?.longestStreak || 0), (userStats?.currentStreak || 0) + 1)
      });
    }

    return { correct, score, word: returnWord };
  }

  static async getNextRound(sessionId: string): Promise<GameRound | null> {
    const session = await GameModel.findSessionById(sessionId);
    if (!session) {
      throw new AppError('Game not found', 404);
    }

    const currentRound = await GameModel.getCurrentRound(sessionId);
    if (currentRound && currentRound.status !== 'completed') {
      return currentRound;
    }

    const nextRoundNumber = session.currentRound + 1;
    if (nextRoundNumber > session.totalRounds) {
      // Game is complete
      await this.completeGame(sessionId);
      return null;
    }

    // Create next round
    const round = await this.createNextRound(session, nextRoundNumber);

    // Update session current round
    await databaseConfig.query(
      'UPDATE game_sessions SET current_round = $1 WHERE id = $2',
      [nextRoundNumber, sessionId]
    );

    return round;
  }

  static async completeGame(sessionId: string): Promise<GameResult> {
    await GameModel.updateSessionStatus(sessionId, 'completed');

    const session = await GameModel.findSessionById(sessionId);
    const participants = await GameModel.getSessionParticipants(sessionId);

    // Get all rounds
    const roundsResult = await databaseConfig.query(
      'SELECT * FROM game_rounds WHERE game_session_id = $1 ORDER BY round_number',
      [sessionId]
    );

    // Calculate results
    const participantResults = await Promise.all(
      participants.map(async (p) => {
        const user = await UserModel.findById(p.userId);
        const guessStats = this.calculateGuessStats(
          roundsResult.rows.filter(r => r.guesser_id === p.userId)
        );

        return {
          userId: p.userId,
          username: user?.username || 'Unknown',
          score: p.score,
          roundsWon: p.roundsWon,
          averageGuessTime: guessStats.averageTime,
          correctGuesses: guessStats.correctGuesses,
          totalGuesses: guessStats.totalGuesses
        };
      })
    );

    // Determine winners
    const maxScore = Math.max(...participantResults.map(p => p.score));
    const winners = participantResults
      .filter(p => p.score === maxScore)
      .map(p => p.userId);

    const result: GameResult = {
      sessionId,
      winners,
      participants: participantResults,
      totalDuration: session?.endedAt && session?.startedAt
        ? Math.floor((new Date(session.endedAt).getTime() - new Date(session.startedAt).getTime()) / 1000)
        : 0,
      completedRounds: roundsResult.rows.filter(r => r.status === 'completed').length
    };

    // Update leaderboard cache
    await redisConfig.del('leaderboard:all:100:0');
    await redisConfig.del('leaderboard:weekly:100:0');
    await redisConfig.del('leaderboard:monthly:100:0');

    logger.info(`Game completed: ${sessionId}`);

    return result;
  }

  // Helper methods
  private static getMaxPlayersForMode(mode: GameMode): number {
    switch (mode) {
      case 'classic': return 1;
      case 'gimme5': return 1;
      case 'party': return 8;
      case 'multiplayer': return 4;
      default: return 2;
    }
  }

  private static getMinPlayersForMode(mode: GameMode): number {
    switch (mode) {
      case 'classic': return 1;
      case 'gimme5': return 1;
      case 'party': return 2;
      case 'multiplayer': return 2;
      default: return 1;
    }
  }

  private static getTotalRoundsForMode(mode: GameMode): number {
    switch (mode) {
      case 'classic': return 10;
      case 'gimme5': return 5;
      case 'party': return 5;
      case 'multiplayer': return 5;
      default: return 5;
    }
  }

  private static assignRole(
    mode: GameMode,
    existingParticipants: GameParticipant[]
  ): PlayerRole {
    if (mode === 'multiplayer') {
      const hasClueGiver = existingParticipants.some(p => p.role === 'clue_giver');
      return hasClueGiver ? 'guesser' : 'clue_giver';
    }
    return 'guesser';
  }

  private static async createNextRound(
    session: GameSession,
    roundNumber: number
  ): Promise<GameRound> {
    const participants = await GameModel.getSessionParticipants(session.id);
    
    // Select word based on game settings
    const word = await WordModel.getRandomWord({
      category: session.settings.category,
      difficulty: session.settings.difficulty,
      language: session.settings.language || 'fil'
    });

    if (!word) {
      throw new AppError('No words available', 500);
    }

    // Determine guesser and clue giver
    const guesser = participants.find(p => p.role === 'guesser');
    const clueGiver = participants.find(p => p.role === 'clue_giver');

    if (!guesser) {
      throw new AppError('No guesser found', 500);
    }

    const round = await GameModel.createRound({
      gameSessionId: session.id,
      roundNumber,
      wordId: word.id,
      guesserId: guesser.userId,
      clueGiverId: clueGiver?.userId
    });

    // Set round as in progress
    await databaseConfig.query(
      'UPDATE game_rounds SET status = $1, started_at = CURRENT_TIMESTAMP WHERE id = $2',
      ['in_progress', round.id]
    );

    return { ...round, word };
  }

  private static checkGuess(guess: string, word: string): boolean {
    // Normalize both strings for comparison
    const normalizedGuess = guess.toLowerCase().trim();
    const normalizedWord = word.toLowerCase().trim();
    
    return normalizedGuess === normalizedWord;
  }

  private static calculateScore(timeTaken: number, attempts: number): number {
    const baseScore = 1000;
    const timeDeduction = Math.min(timeTaken * 5, 500); // Max 500 points deduction for time
    const attemptDeduction = (attempts - 1) * 50; // 50 points per wrong attempt
    
    return Math.max(baseScore - timeDeduction - attemptDeduction, 100); // Minimum 100 points
  }

  private static calculateGuessStats(rounds: any[]): {
    averageTime: number;
    correctGuesses: number;
    totalGuesses: number;
  } {
    let totalTime = 0;
    let correctGuesses = 0;
    let totalGuesses = 0;

    rounds.forEach(round => {
      if (round.time_taken) {
        totalTime += round.time_taken;
      }
      
      const guesses = round.guesses || [];
      totalGuesses += guesses.length;
      correctGuesses += guesses.filter((g: any) => g.correct).length;
    });

    return {
      averageTime: rounds.length > 0 ? totalTime / rounds.length : 0,
      correctGuesses,
      totalGuesses
    };
  }
}
import { Request, Response } from 'express';
import { GameService } from '../services/game.service';
import { WordModel } from '../models/word.model';
import { asyncHandler } from '../middleware/errorHandler';
import { AuthRequest } from '../middleware/auth.middleware';

export class GameController {
  static createGame = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user!.id;
    const { gameMode, settings } = req.body;

    const result = await GameService.createGame(userId, {
      gameMode,
      settings
    });

    res.status(201).json({
      status: 'success',
      data: {
        session: result.session,
        participant: result.participant
      }
    });
  });

  static joinGame = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user!.id;
    const { roomCode } = req.body;

    const result = await GameService.joinGame(userId, roomCode);

    res.json({
      status: 'success',
      data: {
        session: result.session,
        participant: result.participant
      }
    });
  });

  static startGame = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user!.id;
    const { id } = req.params;

    const round = await GameService.startGame(id, userId);

    res.json({
      status: 'success',
      data: { round }
    });
  });

  static submitGuess = asyncHandler(async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const { guess } = req.body;

    const result = await GameService.submitGuess({
      gameSessionId: id,
      roundId: '', // Will be determined by current round
      guess
    });

    res.json({
      status: 'success',
      data: result
    });
  });

  static getGameStatus = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { GameModel } = await import('../models/game.model');

    const session = await GameModel.findSessionById(id);
    if (!session) {
      res.status(404).json({
        status: 'error',
        message: 'Game not found'
      });
      return;
    }

    const participants = await GameModel.getSessionParticipants(id);
    const currentRound = await GameModel.getCurrentRound(id);

    res.json({
      status: 'success',
      data: {
        session,
        participants,
        currentRound
      }
    });
  });

  static getNextRound = asyncHandler(async (req: AuthRequest, res: Response) => {
    const { id } = req.params;

    const round = await GameService.getNextRound(id);

    if (!round) {
      res.json({
        status: 'success',
        data: {
          round: null,
          message: 'Game completed'
        }
      });
      return;
    }

    res.json({
      status: 'success',
      data: { round }
    });
  });

  static completeGame = asyncHandler(async (req: AuthRequest, res: Response) => {
    const { id } = req.params;

    const result = await GameService.completeGame(id);

    res.json({
      status: 'success',
      data: { result }
    });
  });

  static getCategories = asyncHandler(async (req: Request, res: Response) => {
    const { language = 'fil' } = req.query;

    const categories = await WordModel.getCategories(language as string);

    res.json({
      status: 'success',
      data: { categories }
    });
  });

  static searchWords = asyncHandler(async (req: Request, res: Response) => {
    const { q, limit = '50' } = req.query;

    if (!q || typeof q !== 'string') {
      res.status(400).json({
        status: 'error',
        message: 'Search query is required'
      });
      return;
    }

    const words = await WordModel.searchWords(q, parseInt(limit as string));

    res.json({
      status: 'success',
      data: { words }
    });
  });
}
import { Router } from 'express';
import { body, query } from 'express-validator';
import { GameController } from '../controllers/game.controller';
import { UserController } from '../controllers/user.controller';
import { authenticate, optionalAuth } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import { gameActionRateLimiter } from '../middleware/rateLimiter';

const router = Router();

// Validation rules
const createGameValidation = [
  body('gameMode')
    .isIn(['classic', 'gimme5', 'party', 'multiplayer'])
    .withMessage('Invalid game mode'),
  body('settings')
    .optional()
    .isObject()
    .withMessage('Settings must be an object'),
  body('settings.timeLimit')
    .optional()
    .isInt({ min: 30, max: 300 })
    .withMessage('Time limit must be between 30 and 300 seconds'),
  body('settings.difficulty')
    .optional()
    .isInt({ min: 1, max: 5 })
    .withMessage('Difficulty must be between 1 and 5'),
  body('settings.categories')
    .optional()
    .isArray()
    .withMessage('Categories must be an array'),
  body('settings.language')
    .optional()
    .isIn(['fil', 'en'])
    .withMessage('Invalid language')
];

const joinGameValidation = [
  body('roomCode')
    .trim()
    .isLength({ min: 6, max: 6 })
    .withMessage('Room code must be 6 characters')
    .isAlphanumeric()
    .withMessage('Room code must be alphanumeric')
    .toUpperCase()
];

const submitGuessValidation = [
  body('guess')
    .trim()
    .notEmpty()
    .withMessage('Guess is required')
    .isLength({ max: 100 })
    .withMessage('Guess is too long')
];

// Game management routes
router.post(
  '/create',
  authenticate,
  validate(createGameValidation),
  GameController.createGame
);

router.post(
  '/join',
  authenticate,
  validate(joinGameValidation),
  GameController.joinGame
);

router.post(
  '/:id/start',
  authenticate,
  GameController.startGame
);

router.post(
  '/:id/guess',
  authenticate,
  gameActionRateLimiter,
  validate(submitGuessValidation),
  GameController.submitGuess
);

router.get(
  '/:id/status',
  optionalAuth,
  GameController.getGameStatus
);

router.get(
  '/:id/next-round',
  authenticate,
  GameController.getNextRound
);

router.post(
  '/:id/complete',
  authenticate,
  GameController.completeGame
);

// Game data routes
router.get(
  '/categories',
  optionalAuth,
  validate([
    query('language')
      .optional()
      .isIn(['fil', 'en'])
      .withMessage('Invalid language')
  ]),
  GameController.getCategories
);

router.get(
  '/words/search',
  authenticate,
  validate([
    query('q')
      .trim()
      .notEmpty()
      .withMessage('Search query is required'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100')
  ]),
  GameController.searchWords
);

// Use user controller for these endpoints since they're already implemented
router.get(
  '/history',
  authenticate,
  (req, res, next) => {
    req.params.id = (req as any).user.id;
    next();
  },
  UserController.getGameHistory
);

router.get(
  '/leaderboard',
  optionalAuth,
  UserController.getLeaderboard
);

export { router as gameRoutes };
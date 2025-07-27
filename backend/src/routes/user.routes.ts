import { Router } from 'express';
import { body, query } from 'express-validator';
import { UserController } from '../controllers/user.controller';
import { authenticate, optionalAuth } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';

const router = Router();

// Validation rules
const updateProfileValidation = [
  body('displayName')
    .optional()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Display name must be between 1 and 50 characters'),
  body('email')
    .optional()
    .trim()
    .isEmail()
    .withMessage('Invalid email address')
    .normalizeEmail(),
  body('avatarUrl')
    .optional()
    .trim()
    .isURL()
    .withMessage('Invalid avatar URL'),
  body('metadata')
    .optional()
    .isObject()
    .withMessage('Metadata must be an object')
];

const paginationValidation = [
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('offset')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Offset must be non-negative')
];

// Routes
router.get('/profile/:id', optionalAuth, UserController.getProfile);

router.put(
  '/profile',
  authenticate,
  validate(updateProfileValidation),
  UserController.updateProfile
);

router.get('/stats/:id', optionalAuth, UserController.getStats);

router.get('/achievements/:id', optionalAuth, UserController.getAchievements);

router.get(
  '/leaderboard',
  optionalAuth,
  validate([
    query('timeframe')
      .optional()
      .isIn(['all', 'weekly', 'monthly'])
      .withMessage('Invalid timeframe'),
    ...paginationValidation
  ]),
  UserController.getLeaderboard
);

router.get(
  '/search',
  authenticate,
  validate([
    query('q')
      .trim()
      .isLength({ min: 2 })
      .withMessage('Search term must be at least 2 characters'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 50 })
      .withMessage('Limit must be between 1 and 50')
  ]),
  UserController.searchUsers
);

router.get(
  '/:id/history',
  authenticate,
  validate(paginationValidation),
  UserController.getGameHistory
);

router.post(
  '/deactivate',
  authenticate,
  UserController.deactivateAccount
);

export { router as userRoutes };
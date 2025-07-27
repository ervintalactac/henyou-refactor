import { Router } from 'express';
import { body } from 'express-validator';
import { AuthController } from '../controllers/auth.controller';
import { validate } from '../middleware/validation.middleware';
import { authenticate } from '../middleware/auth.middleware';
import { authRateLimiter } from '../middleware/rateLimiter';

const router = Router();

// Validation rules
const registerValidation = [
  body('username')
    .trim()
    .isLength({ min: 3, max: 20 })
    .withMessage('Username must be between 3 and 20 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  body('email')
    .optional()
    .trim()
    .isEmail()
    .withMessage('Invalid email address')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long'),
  body('displayName')
    .optional()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Display name must be between 1 and 50 characters')
];

const loginValidation = [
  body('username')
    .trim()
    .notEmpty()
    .withMessage('Username is required'),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
];

const refreshTokenValidation = [
  body('refreshToken')
    .notEmpty()
    .withMessage('Refresh token is required')
];

const changePasswordValidation = [
  body('oldPassword')
    .notEmpty()
    .withMessage('Old password is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('New password must be at least 8 characters long')
    .custom((value, { req }) => value !== req.body.oldPassword)
    .withMessage('New password must be different from old password')
];

// Routes
router.post(
  '/register',
  authRateLimiter,
  validate(registerValidation),
  AuthController.register
);

router.post(
  '/login',
  authRateLimiter,
  validate(loginValidation),
  AuthController.login
);

router.post(
  '/refresh',
  authRateLimiter,
  validate(refreshTokenValidation),
  AuthController.refreshToken
);

router.post(
  '/logout',
  authenticate,
  AuthController.logout
);

router.get(
  '/me',
  authenticate,
  AuthController.me
);

router.post(
  '/change-password',
  authenticate,
  validate(changePasswordValidation),
  AuthController.changePassword
);

router.post(
  '/validate-token',
  validate([
    body('token').notEmpty().withMessage('Token is required')
  ]),
  AuthController.validateToken
);

export { router as authRoutes };
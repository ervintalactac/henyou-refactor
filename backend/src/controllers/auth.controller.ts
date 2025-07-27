import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import { asyncHandler } from '../middleware/errorHandler';
import { AuthRequest } from '../middleware/auth.middleware';

export class AuthController {
  static register = asyncHandler(async (req: Request, res: Response) => {
    const { username, email, password, displayName } = req.body;

    const result = await AuthService.register({
      username,
      email,
      password,
      displayName
    });

    res.status(201).json({
      status: 'success',
      data: {
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken
      }
    });
  });

  static login = asyncHandler(async (req: Request, res: Response) => {
    const { username, password } = req.body;

    const result = await AuthService.login({ username, password });

    res.json({
      status: 'success',
      data: {
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken
      }
    });
  });

  static refreshToken = asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body;

    const tokens = await AuthService.refreshToken(refreshToken);

    res.json({
      status: 'success',
      data: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken
      }
    });
  });

  static logout = asyncHandler(async (req: AuthRequest, res: Response) => {
    if (req.user) {
      await AuthService.logout(req.user.id);
    }

    res.json({
      status: 'success',
      message: 'Logged out successfully'
    });
  });

  static me = asyncHandler(async (req: AuthRequest, res: Response) => {
    const { UserModel } = await import('../models/user.model');
    
    const user = await UserModel.findById(req.user!.id);
    if (!user) {
      res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
      return;
    }

    const { passwordHash, ...userWithoutPassword } = user;

    res.json({
      status: 'success',
      data: { user: userWithoutPassword }
    });
  });

  static changePassword = asyncHandler(async (req: AuthRequest, res: Response) => {
    const { oldPassword, newPassword } = req.body;

    await AuthService.changePassword(req.user!.id, oldPassword, newPassword);

    res.json({
      status: 'success',
      message: 'Password changed successfully'
    });
  });

  static validateToken = asyncHandler(async (req: Request, res: Response) => {
    const { token } = req.body;

    const isValid = await AuthService.validateToken(token);

    res.json({
      status: 'success',
      data: { isValid }
    });
  });
}
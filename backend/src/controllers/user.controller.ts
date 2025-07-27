import { Request, Response } from 'express';
import { UserService } from '../services/user.service';
import { asyncHandler } from '../middleware/errorHandler';
import { AuthRequest } from '../middleware/auth.middleware';

export class UserController {
  static getProfile = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    
    const profile = await UserService.getUserProfile(id);
    
    res.json({
      status: 'success',
      data: { profile }
    });
  });

  static updateProfile = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user!.id;
    const { displayName, email, avatarUrl, metadata } = req.body;

    const updatedUser = await UserService.updateUserProfile(userId, {
      displayName,
      email,
      avatarUrl,
      metadata
    });

    res.json({
      status: 'success',
      data: { user: updatedUser }
    });
  });

  static getStats = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    
    const stats = await UserService.getUserStats(id);
    
    res.json({
      status: 'success',
      data: { stats }
    });
  });

  static getAchievements = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    
    const achievements = await UserService.getUserAchievements(id);
    
    res.json({
      status: 'success',
      data: { achievements }
    });
  });

  static getLeaderboard = asyncHandler(async (req: Request, res: Response) => {
    const { timeframe = 'all', limit = '100', offset = '0' } = req.query;
    
    const leaderboard = await UserService.getLeaderboard(
      timeframe as 'all' | 'weekly' | 'monthly',
      parseInt(limit as string),
      parseInt(offset as string)
    );
    
    res.json({
      status: 'success',
      data: { leaderboard }
    });
  });

  static searchUsers = asyncHandler(async (req: Request, res: Response) => {
    const { q, limit = '20' } = req.query;
    
    if (!q || typeof q !== 'string' || q.length < 2) {
      res.status(400).json({
        status: 'error',
        message: 'Search term must be at least 2 characters'
      });
      return;
    }
    
    const users = await UserService.searchUsers(q, parseInt(limit as string));
    
    res.json({
      status: 'success',
      data: { users }
    });
  });

  static getGameHistory = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const { limit = '20', offset = '0' } = req.query;
    
    const history = await UserService.getUserGameHistory(
      id,
      parseInt(limit as string),
      parseInt(offset as string)
    );
    
    res.json({
      status: 'success',
      data: { history }
    });
  });

  static deactivateAccount = asyncHandler(async (req: AuthRequest, res: Response) => {
    const userId = req.user!.id;
    
    await UserService.deactivateUser(userId);
    
    res.json({
      status: 'success',
      message: 'Account deactivated successfully'
    });
  });
}
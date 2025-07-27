import { Request, Response, NextFunction } from 'express';
import { JwtUtils } from '../utils/jwt.utils';
import { logger } from '../config/logger';

export interface AuthRequest extends Request {
  user?: any;
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      res.status(401).json({
        status: 'error',
        message: 'Authorization header is required'
      });
      return;
    }

    const [bearer, token] = authHeader.split(' ');
    
    if (bearer !== 'Bearer' || !token) {
      res.status(401).json({
        status: 'error',
        message: 'Invalid authorization format'
      });
      return;
    }

    try {
      const decoded = JwtUtils.verifyAccessToken(token);
      req.user = decoded;
      next();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Invalid token';
      res.status(401).json({
        status: 'error',
        message
      });
      return;
    }
  } catch (error) {
    logger.error('Authentication middleware error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error'
    });
  }
};

export const optionalAuth = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      next();
      return;
    }

    const [bearer, token] = authHeader.split(' ');
    
    if (bearer === 'Bearer' && token) {
      try {
        const decoded = JwtUtils.verifyAccessToken(token);
        req.user = decoded;
      } catch (error) {
        // Token is invalid but we don't block the request
        logger.debug('Optional auth - invalid token:', error);
      }
    }
    
    next();
  } catch (error) {
    logger.error('Optional authentication middleware error:', error);
    next();
  }
};

export const requireRole = (roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      res.status(401).json({
        status: 'error',
        message: 'Authentication required'
      });
      return;
    }

    const userRole = req.user.role || 'user';
    
    if (!roles.includes(userRole)) {
      res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions'
      });
      return;
    }

    next();
  };
};
import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger';

export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  const start = Date.now();

  // Log request
  logger.info({
    type: 'request',
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('user-agent')
  });

  // Capture the original send function
  const originalSend = res.send;

  // Override send function to log response
  res.send = function (data: any) {
    res.send = originalSend;
    res.send(data);

    const duration = Date.now() - start;

    logger.info({
      type: 'response',
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      contentLength: res.get('content-length')
    });

    return res;
  };

  next();
};
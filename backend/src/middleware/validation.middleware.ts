import { Request, Response, NextFunction } from 'express';
import { validationResult, ValidationChain } from 'express-validator';
import { logger } from '../config/logger';

export const validate = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    // Run all validations
    await Promise.all(validations.map(validation => validation.run(req)));

    const errors = validationResult(req);
    
    if (errors.isEmpty()) {
      next();
      return;
    }

    const extractedErrors = errors.array().map(err => ({
      field: err.type === 'field' ? err.path : undefined,
      message: err.msg
    }));

    logger.debug('Validation errors:', extractedErrors);

    res.status(400).json({
      status: 'error',
      message: 'Validation failed',
      errors: extractedErrors
    });
  };
};
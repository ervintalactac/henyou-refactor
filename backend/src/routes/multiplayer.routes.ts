import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

// Placeholder routes - to be implemented
router.post('/rooms', authenticate, (req, res) => {
  res.json({ message: 'Create room endpoint - to be implemented' });
});

router.get('/rooms/:code', authenticate, (req, res) => {
  res.json({ message: 'Get room endpoint - to be implemented' });
});

router.put('/rooms/:code/join', authenticate, (req, res) => {
  res.json({ message: 'Join room endpoint - to be implemented' });
});

router.post('/rooms/:code/start', authenticate, (req, res) => {
  res.json({ message: 'Start multiplayer game endpoint - to be implemented' });
});

router.get('/rooms', authenticate, (req, res) => {
  res.json({ message: 'List active rooms endpoint - to be implemented' });
});

export { router as multiplayerRoutes };
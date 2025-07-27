export type GameMode = 'classic' | 'gimme5' | 'party' | 'multiplayer';
export type GameStatus = 'waiting' | 'in_progress' | 'completed' | 'abandoned';
export type PlayerRole = 'guesser' | 'clue_giver' | 'spectator';
export type WordDifficulty = 1 | 2 | 3 | 4 | 5;

export interface Word {
  id: string;
  word: string;
  category: string;
  difficulty: WordDifficulty;
  language: string;
  hints?: string[];
  tags?: string[];
  usageCount: number;
  successRate: number;
  isActive: boolean;
}

export interface GameSession {
  id: string;
  roomCode?: string;
  hostId: string;
  gameMode: GameMode;
  status: GameStatus;
  maxPlayers: number;
  currentRound: number;
  totalRounds: number;
  timeLimit: number;
  settings: Record<string, any>;
  startedAt?: Date;
  endedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface GameParticipant {
  id: string;
  gameSessionId: string;
  userId: string;
  role: PlayerRole;
  score: number;
  roundsWon: number;
  averageTime?: number;
  isReady: boolean;
  joinedAt: Date;
  leftAt?: Date;
}

export interface GameRound {
  id: string;
  gameSessionId: string;
  roundNumber: number;
  wordId: string;
  word?: Word;
  guesserId: string;
  clueGiverId?: string;
  status: GameStatus;
  timeTaken?: number;
  guesses: Guess[];
  clues: Clue[];
  scoreEarned: number;
  startedAt?: Date;
  completedAt?: Date;
  createdAt: Date;
}

export interface Guess {
  guess: string;
  timestamp: Date;
  correct: boolean;
}

export interface Clue {
  clue: string;
  timestamp: Date;
  type?: 'text' | 'gesture' | 'sound';
}

export interface GameSettings {
  timeLimit?: number;
  maxGuesses?: number;
  allowHints?: boolean;
  difficulty?: WordDifficulty;
  categories?: string[];
  language?: string;
}

export interface GameResult {
  sessionId: string;
  winners: string[];
  participants: GameParticipantResult[];
  totalDuration: number;
  completedRounds: number;
}

export interface GameParticipantResult {
  userId: string;
  username: string;
  score: number;
  roundsWon: number;
  averageGuessTime: number;
  correctGuesses: number;
  totalGuesses: number;
}

export interface CreateGameData {
  gameMode: GameMode;
  settings?: GameSettings;
  isPrivate?: boolean;
}

export interface JoinGameData {
  roomCode: string;
  role?: PlayerRole;
}

export interface GameGuessData {
  gameSessionId: string;
  roundId: string;
  guess: string;
}

export interface GameClueData {
  gameSessionId: string;
  roundId: string;
  clue: string;
  type?: 'text' | 'gesture' | 'sound';
}
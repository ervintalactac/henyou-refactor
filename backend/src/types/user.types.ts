export interface User {
  id: string;
  username: string;
  email?: string;
  passwordHash?: string;
  displayName?: string;
  avatarUrl?: string;
  isActive: boolean;
  isVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
  lastLoginAt?: Date;
  metadata?: Record<string, any>;
}

export interface UserStats {
  id: string;
  userId: string;
  totalGames: number;
  gamesWon: number;
  gamesLost: number;
  totalScore: number;
  highestScore: number;
  currentStreak: number;
  longestStreak: number;
  averageGuessTime?: number;
  totalPlayTime: number;
  favoriteCategory?: string;
  achievements: Achievement[];
  createdAt: Date;
  updatedAt: Date;
}

export interface Achievement {
  id: string;
  code: string;
  name: string;
  description?: string;
  iconUrl?: string;
  points: number;
  earnedAt: Date;
}

export interface UserProfile extends User {
  stats?: UserStats;
}

export interface UpdateUserData {
  displayName?: string;
  email?: string;
  avatarUrl?: string;
  metadata?: Record<string, any>;
}
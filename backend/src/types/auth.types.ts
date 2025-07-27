export interface JwtPayload {
  id: string;
  username: string;
  email?: string;
  iat?: number;
  exp?: number;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

export interface LoginCredentials {
  username: string;
  password: string;
}

export interface RegisterData {
  username: string;
  email?: string;
  password: string;
  displayName?: string;
}

export interface AuthRequest extends Express.Request {
  user?: JwtPayload;
}

export interface RefreshTokenData {
  userId: string;
  token: string;
  expiresAt: Date;
  createdAt: Date;
}
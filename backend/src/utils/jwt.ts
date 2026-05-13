import jwt from "jsonwebtoken";

const SECRET = process.env.JWT_SECRET || "dev-secret";
const EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";

export interface JwtPayload {
  userId: number;
  username: string;
  role: string;
}

export const signToken = (payload: JwtPayload) =>
  jwt.sign(payload, SECRET, { expiresIn: EXPIRES_IN } as jwt.SignOptions);

export const verifyToken = (token: string) => jwt.verify(token, SECRET) as JwtPayload;

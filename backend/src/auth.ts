import { randomBytes, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { NextFunction, Request, Response } from 'express';

const scrypt = promisify(scryptCallback);
const sessions = new Map<string, { customerId: string; expiresAt: number }>();
const sessionLifetimeMs = 60 * 60 * 1000;

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16).toString('hex');
  const key = (await scrypt(password, salt, 64)) as Buffer;
  return `${salt}:${key.toString('hex')}`;
}

export async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const parts = stored.split(':');
  if (parts.length !== 2 || !/^[a-f0-9]{32}$/i.test(parts[0]) || !/^[a-f0-9]{128}$/i.test(parts[1])) return false;
  const expected = Buffer.from(parts[1], 'hex');
  const actual = (await scrypt(password, parts[0], expected.length)) as Buffer;
  return timingSafeEqual(actual, expected);
}

export function createSession(customerId: string): string {
  const token = randomBytes(32).toString('hex');
  sessions.set(token, { customerId, expiresAt: Date.now() + sessionLifetimeMs });
  return token;
}

export function requireSession(req: Request, res: Response, next: NextFunction): void {
  const header = req.header('authorization');
  if (!header?.startsWith('Bearer ')) {
    res.status(401).json({ error: 'unauthorized' });
    return;
  }
  const session = sessions.get(header.slice(7));
  if (!session || session.expiresAt <= Date.now()) {
    if (session) sessions.delete(header.slice(7));
    res.status(401).json({ error: 'unauthorized' });
    return;
  }
  res.locals.customerId = session.customerId;
  next();
}

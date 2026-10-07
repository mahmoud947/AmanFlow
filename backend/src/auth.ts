import { randomBytes, scryptSync, timingSafeEqual } from 'node:crypto';
import { Account } from './models';

// Sessions are process-local: a restart requires another password sign-in.
const sessions = new Map<string, { customerId: string; expiresAt: number }>();
const sessionLifetimeMs = 60 * 60 * 1000;

export function hashPassword(password: string): string {
  const salt = randomBytes(16).toString('hex');
  return `${salt}:${scryptSync(password, salt, 64).toString('hex')}`;
}

function matchesPassword(password: string, stored: string): boolean {
  const [salt, hex, extra] = stored.split(':');
  if (!salt || !hex || extra || !/^[a-f0-9]{32}$/i.test(salt) || !/^[a-f0-9]{128}$/i.test(hex)) return false;
  const expected = Buffer.from(hex, 'hex');
  return timingSafeEqual(scryptSync(password, salt, expected.length), expected);
}

export async function authenticate(identifier: string, password: string): Promise<string | null> {
  const account = await Account.findOne({ identifier: identifier.trim().toLowerCase() }).lean();
  if (!account || !matchesPassword(password, account.passwordHash)) return null;
  const token = randomBytes(32).toString('hex');
  sessions.set(token, { customerId: account.customerId, expiresAt: Date.now() + sessionLifetimeMs });
  return token;
}

export function sessionCustomerId(authorization: string | undefined): string | null {
  const match = /^Bearer ([a-f0-9]{64})$/i.exec(authorization ?? '');
  if (!match) return null;
  const session = sessions.get(match[1]);
  if (!session) return null;
  if (session.expiresAt <= Date.now()) {
    sessions.delete(match[1]);
    return null;
  }
  return session.customerId;
}

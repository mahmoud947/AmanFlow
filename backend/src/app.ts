import cors from 'cors';
import express, { NextFunction, Request, Response } from 'express';
import { router } from './routes';

export function createApp() {
  const app = express();
  app.use(cors());
  app.use(express.json());
  app.use(router);

  app.use((_req, res) => {
    res.status(404).json({ error: 'not_found' });
  });
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
    console.error(err);
    res.status(500).json({ error: 'internal_error' });
  });
  return app;
}

import { RDBTable } from './RDBTable';

export const TOTP_CODE_TABLE: RDBTable = {
  tableName: 'TotpAccount',
  createQuery: `CREATE TABLE TotpAccount (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      issuer TEXT NOT NULL,
      label TEXT NOT NULL,
      secret TEXT NOT NULL,          -- Base32-encoded secret
      algorithm TEXT DEFAULT 'SHA1', -- SHA1, SHA256, SHA512
      digits INTEGER DEFAULT 6,      -- 6 or 8
      period INTEGER DEFAULT 30,     -- time step in seconds
      created_at INTEGER DEFAULT (strftime('%s','now'))
  );`,
  columns: ['id', 'issuer', 'label', 'secret', 'algorithm', 'digits', 'period', 'created_at']
};
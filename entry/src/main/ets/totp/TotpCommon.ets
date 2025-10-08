export enum TotpAlgoType {
  sha1 = 'SHA1',
  sha256 = 'SHA256',
  sha512 = 'SHA512'
}
// id -> code
export type CodesMap = Map<number, string>;

// id -> seconds remaining
export type RemainingMap = Map<number, number>;
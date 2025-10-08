import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { Constants } from '../constants/Constants';
import { Base32 } from '../utils/Base32';

export interface TotpOptions {
  digits?: number;
  interval?: number;
  algo?: string;
}

export class TotpManager {
  /**
   * Generates a TOTP code as a zero-padded string (e.g., "012345").
   */
  static async generateTOTPCodeString(
    secretBase32: string,
    nowMs: number,
    opts: TotpOptions = {}
  ): Promise<string> {
    const digits = opts.digits ?? Constants.DEFAULT_CODE_DIGITS;
    const code = await TotpManager.generateTOTPCode(secretBase32, nowMs, {
      digits,
      interval: opts.interval,
      algo: opts.algo,
    });
    return code.toString().padStart(digits, '0');
  }

  private static counterToBytesBE(counter: number): Uint8Array {
    if (!Number.isInteger(counter) || counter < 0) {
      throw new Error('Counter must be a non-negative integer.');
    }

    const buf = new Uint8Array(8);
    let x = counter;
    for (let i = 7; i >= 0; i--) {
      buf[i] = x & 0xff;
      x = Math.floor(x / 256);
    }
    return buf;
  }

  private static async genSymKeyByData(symKeyData: Uint8Array): Promise<cryptoFramework.SymKey> {
    let symKeyBlob: cryptoFramework.DataBlob = { data: symKeyData };
    let aesGenerator = cryptoFramework.createSymKeyGenerator('HMAC');
    let symKey = await aesGenerator.convertKey(symKeyBlob);
    return symKey;
  }

  private static async generateTOTPCode(
    secretBase32: string,
    nowMs: number,
    opts: TotpOptions = {}
  ): Promise<number> {
    const digits = opts.digits ?? Constants.DEFAULT_CODE_DIGITS;
    const interval = opts.interval ?? Constants.DEFAULT_CODE_PERIOD;
    const algo = opts.algo ?? Constants.DEFAULT_CODE_ALGO;

    // 1) RFC 6238 counter = floor((unixTime) / period)
    const counter = Math.floor((Math.floor(nowMs / 1000)) / interval);

    // 2) Decode Base32 secret and build 8-byte big-endian counter
    const keyBytes = Base32.decode(secretBase32);
    const counterBytes = TotpManager.counterToBytesBE(counter);

    // 3) get HMAC SymKey with keyBytes
    const key = await TotpManager.genSymKeyByData(keyBytes);

    // 4) Set MAC algorithm
    const mac = cryptoFramework.createMac(algo);

    // 5) init with HMAC with key then update by counterBytes
    await mac.init(key);
    await mac.update({ data: counterBytes });
    const out = mac.doFinalSync();

    // HMAC result bytes
    const digest = new Uint8Array(out.data);

    // 6) Dynamic truncation → 31-bit integer
    const offset = digest[digest.length - 1] & 0x0f;
    const binary =
      ((digest[offset] & 0x7f) << 24) |
        ((digest[offset + 1] & 0xff) << 16) |
        ((digest[offset + 2] & 0xff) << 8) |
        (digest[offset + 3] & 0xff);

    // 7) Mod 10^digits
    const mod = Math.pow(10, digits);
    return binary % mod;
  }
}

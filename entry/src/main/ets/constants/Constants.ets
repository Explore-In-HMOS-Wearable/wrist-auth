import { TotpAlgoType } from '../totp/TotpCommon';

export class Constants {
  /**
   * Default TOTP code digits count.
   */
  static readonly DEFAULT_CODE_DIGITS: number = 6;
  /**
   * Default TOTP code period in seconds.
   */
  static readonly DEFAULT_CODE_PERIOD: number = 30;
  /**
   * Default TOTP code generation algorithm type.
   */
  static readonly DEFAULT_CODE_ALGO: TotpAlgoType = TotpAlgoType.sha1;
}
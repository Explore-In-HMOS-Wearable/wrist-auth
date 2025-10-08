import Injectable from '../registry/Injectable';
import { TotpCode } from '../model/TotpCode';

export default abstract class AppDatabase implements Injectable {
  abstract onDispose(): void

  abstract insertTotpCode(
    issuer: string,
    label: string,
    secret: string,
    algorithm?: string,
    digits?: number,
    period?: number,
  ): Promise<number | undefined>

  abstract getTotpCodes(): Promise<TotpCode[]>

  abstract deleteTotpCode(totpCode: TotpCode): Promise<void>;
}
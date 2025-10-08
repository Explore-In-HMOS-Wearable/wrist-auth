import AppDatabase from '../database/AppDatabase';
import { PREDEFINED_ISSUERS } from '../model/LabelOption';
import { TotpCode } from '../model/TotpCode';
import { Resolve } from '../registry/ServiceRegistry';
import { CodesMap, RemainingMap } from '../totp/TotpCommon';
import TotpScheduler from '../totp/TotpScheduler';
import { AccountsDataSource } from './AccountsDataSource';


@Observed
export default class AccountsViewModel {
  @Resolve(AppDatabase)
  private appDatabase?: AppDatabase;
  @Resolve(TotpScheduler)
  private totpScheduler?: TotpScheduler;
  private totpCodes: TotpCode[] = [];
  @Track
  isEmptyData: boolean = true;
  @Track
  datasource: AccountsDataSource = new AccountsDataSource();
  @Track
  remaining: RemainingMap = new Map();
  @Track
  codes: CodesMap = new Map();

  dispose() {
    this.totpScheduler?.stop();
  }

  async deleteTotpAccount(totpCode: TotpCode) {
    this.datasource.deleteData(totpCode);
    this.isEmptyData = this.datasource.totalCount() <= 0;
    await this.appDatabase?.deleteTotpCode(totpCode);
    if (!this.isEmptyData) {
      this.totpCodes = this.totpCodes.filter(code => code.id !== totpCode.id);
      this.totpScheduler?.start(this.totpCodes,
        (remainingById: RemainingMap) => {
          this.remaining = remainingById;
        },
        (changed: CodesMap) => {
          this.codes = changed;
        })
    } else {
      this.totpCodes = [];
      this.totpScheduler?.stop();
    }
  }


  async loadAccounts() {
    if (!this.appDatabase) {
      return;
    }

    this.totpCodes = await this.appDatabase.getTotpCodes();
    this.isEmptyData = this.totpCodes.length <= 0
    if (this.isEmptyData) {
      return;
    }

    for (let i = 0; i < this.totpCodes.length; i++) {
      const e = this.totpCodes[i];
      const issuer = PREDEFINED_ISSUERS.find((issuer) => e.issuer === issuer.label);
      if (issuer) {
        e.issuerColor = issuer.selectedColor;
        e.issuerBGColor = issuer.color;
      }
      this.remaining.set(e.id, 0);
      this.codes.set(e.id, '');
    }

    this.totpScheduler?.start(this.totpCodes,
      (remainingById: RemainingMap) => {
        this.remaining = remainingById;
      },
      (changed: CodesMap) => {
        this.codes = changed;
      })

    this.datasource.clearDataList();
    this.datasource.addDataList(this.totpCodes);
  }
}
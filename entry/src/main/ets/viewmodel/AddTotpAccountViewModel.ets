import { Constants } from '../constants/Constants';
import AppDatabase from '../database/AppDatabase';
import { LabelOption, PREDEFINED_ISSUERS, PREDEFINED_LABELS } from '../model/LabelOption';
import { Resolve } from '../registry/ServiceRegistry';
import Logger from '../utils/Logger';

export default class AddTotpAccountViewModel {
  @Resolve(AppDatabase)
  private appDatabase?: AppDatabase;

  get getIssuerOptions(): LabelOption[] {
    return PREDEFINED_ISSUERS;
  }

  get getLabelOptions(): LabelOption[] {
    return PREDEFINED_LABELS;
  }

  async addAccount(secretKey: string, issuerOpt: LabelOption, labelOpt: LabelOption) {
    try {
      await this.appDatabase?.insertTotpCode(
        issuerOpt.label,
        labelOpt.label,
        secretKey,
        Constants.DEFAULT_CODE_ALGO,
        Constants.DEFAULT_CODE_DIGITS,
        Constants.DEFAULT_CODE_PERIOD
      );
    } catch (err) {
      Logger.error(`Failed to get addAccount record. Code:${err.code}, message:${err.message}`);
    }
  }
}
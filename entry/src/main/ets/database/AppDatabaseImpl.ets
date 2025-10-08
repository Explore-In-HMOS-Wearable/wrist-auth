import Logger from '../utils/Logger';
import AppDatabase from './AppDatabase';
import { BusinessError } from '@kit.BasicServicesKit';
import { RDBBuilder } from './RDBBuilder';
import { relationalStore } from '@kit.ArkData';
import { TotpCode } from '../model/TotpCode';
import { TOTP_CODE_TABLE } from './tables/TotpCodeTable';
import { Constants } from '../constants/Constants';

export class AppDatabaseImpl extends AppDatabase {
  private readonly readyDatabase: Promise<relationalStore.RdbStore>;

  constructor(context: Context) {
    super();
    this.readyDatabase = new RDBBuilder({
      dbName: 'wrist_auth.db',
    })
      .build(context)
      .then((store) => {
        Logger.info(`Succeeded in getting RdbStore, version: ${store.version}`);
        return store
      })
      .catch((err: BusinessError) => {
        const message = `Failed to get RdbStore. Code:${err.code}, message:${err.message}`;
        Logger.error(message);
        throw new Error(message);
      });
  }

  async onDispose(): Promise<void> {
    const database = await this.readyDatabase;
    database.close();
  }

  async insertTotpCode(
    issuer: string,
    label: string,
    secret: string,
    algorithm?: string,
    digits?: number,
    period?: number
  ): Promise<number | undefined> {
    const database = await this.readyDatabase;
    const valueBucket: relationalStore.ValuesBucket = {
      'issuer': issuer,
      'label': label,
      'secret': secret,
      'algorithm': algorithm ?? Constants.DEFAULT_CODE_ALGO,
      'digits': digits ?? Constants.DEFAULT_CODE_DIGITS,
      'period': period ?? Constants.DEFAULT_CODE_PERIOD,
    };
    const totpCodeId = await database.insert(TOTP_CODE_TABLE.tableName, valueBucket);
    if (totpCodeId === -1) {
      throw new Error(`Failed to insert Totp Account record, totpCodeId: ${totpCodeId}`);
    }
    Logger.info(`Succeeded insertTotpCode in RdbStore with id: ${totpCodeId}`);
    return totpCodeId;
  }

  async getTotpCodes(): Promise<TotpCode[]> {
    const database = await this.readyDatabase;
    const predicates = new relationalStore.RdbPredicates(TOTP_CODE_TABLE.tableName);
    predicates.orderByDesc('id');
    try {
      const resultSet = await database.query(predicates, TOTP_CODE_TABLE.columns);
      if (!resultSet || resultSet.rowCount === 0) {
        return [];
      }

      const results: TotpCode[] = [];
      while (resultSet.goToNextRow()) {
        const createdDate = new Date(resultSet.getLong(resultSet.getColumnIndex('created_at')));
        const totpCode: TotpCode = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          issuer: resultSet.getString(resultSet.getColumnIndex('issuer')),
          label: resultSet.getString(resultSet.getColumnIndex('label')),
          secret: resultSet.getString(resultSet.getColumnIndex('secret')),
          algorithm: resultSet.getString(resultSet.getColumnIndex('algorithm')),
          digits: resultSet.getLong(resultSet.getColumnIndex('digits')),
          period: resultSet.getLong(resultSet.getColumnIndex('period')),
          createdAt: createdDate.toLocaleDateString()
        };
        results.push(totpCode);
      }
      resultSet.close();
      return results;
    } catch (err) {
      return [];
    }
  }

  async deleteTotpCode(totpCode: TotpCode): Promise<void> {
    const database = await this.readyDatabase;

    const predicates = new relationalStore.RdbPredicates(TOTP_CODE_TABLE.tableName)
      .equalTo('id', totpCode.id);

    try {
      await database.delete(predicates);
      Logger.info(`Success delete operations`);
    } catch (err) {
      Logger.error(`Failed to delete rows. Code:${err.code}, message:${err.message}`);
    }
  }
}
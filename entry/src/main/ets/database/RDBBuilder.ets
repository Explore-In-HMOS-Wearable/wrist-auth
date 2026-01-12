import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { TOTP_CODE_TABLE } from './tables/TotpCodeTable';

export interface RDBBuilderParams {
  dbName: string;
}

export class RDBBuilder {
  private rdbName: string;

  constructor(options: RDBBuilderParams) {
    this.rdbName = options.dbName;
  }

  /**
   * Runs creation queries when the RDB version is 0 (initial version).
   * @param { relationalStore.RdbStore } store
   */
  private async runCreationQueries(store: relationalStore.RdbStore) {
    await store.executeSql(TOTP_CODE_TABLE.createQuery);
  }

  /**
   * Initialize RDB.
   * @param { Context } the application context.
   * @returns { Promise<relationalStore.RdbStore> } The RDB store {@link relationalStore.RdbStore}.
   */
  public async build(context: Context): Promise<relationalStore.RdbStore> {
    const store = await relationalStore.getRdbStore(context, {
      name: this.rdbName,
      securityLevel: relationalStore.SecurityLevel.S1
    });
    // Fresh DB? Run creation queries once (version 0)
    if (store.version === 0) {
      await this.runCreationQueries(store);
      store.version = 1;
    }
    return store;
  }
}

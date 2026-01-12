import { Constants } from '../constants/Constants';
import { TotpCode } from '../model/TotpCode';
import Injectable from '../registry/Injectable';
import { CodesMap, RemainingMap } from './TotpCommon';
import { TotpManager } from './TotpManager';

export default class TotpScheduler implements Injectable {
  // id -> last counter
  private lastCounter = new Map<number, number>();
  private handle: number | null = null;

  /**
   * Starts the scheduler loop for the given TOTP items.
   *
   * @param {TotpCode} items - List of TOTP definitions (secret, period, etc.)
   * @param {(remainingById: RemainingMap) => void} onTick - Called every tick with seconds remaining for each item
   * @param {(changed: CodesMap) => void} onCodes - Called when a code rolls over and needs to be refreshed
   * @returns {void}
   */
  start(
    items: TotpCode[],
    onTick: (remainingById: RemainingMap) => void,
    onCodes: (changed: CodesMap) => void,
  ) {
    this.stop();
    const tick = async () => {
      const nowMs = Date.now();
      const nowSec = Math.floor(nowMs / 1000);

      const remaining: RemainingMap = new Map();
      const changed: CodesMap = new Map();


      // Batch async code generations
      const jobs: Array<Promise<void>> = [];

      const defCodePeriod = Constants.DEFAULT_CODE_PERIOD;
      const defCodeDigits = Constants.DEFAULT_CODE_DIGITS;
      const defCodeAlgo = Constants.DEFAULT_CODE_ALGO;
      for (const it of items) {
        const period = it.period ?? defCodePeriod;
        const digits = it.digits ?? defCodeDigits;
        const algo = it.algorithm ?? defCodeAlgo;

        // counter + rollover detect
        const counter = Math.floor(nowSec / period);
        if (this.lastCounter.get(it.id) !== counter) {
          jobs.push((async () => {
            const code = await TotpManager.generateTOTPCodeString(it.secret, nowMs, {
              digits: digits,
              interval: period,
              algo: algo
            });
            this.lastCounter.set(it.id, counter);
            changed.set(it.id, code);
          })());
        }

        // seconds remaining for UI
        const remSec = (period - (nowSec % period)) % period;
        remaining.set(it.id, remSec || period); // show full period at boundary if you prefer
      }

      await Promise.all(jobs);

      onTick(remaining);
      if (changed.size) {
        onCodes(changed);
      }

      // schedule next EXACT boundary (the soonest among all periods)
      const nextMs = this.msToSoonestBoundary(items, nowMs);
      this.handle = setTimeout(tick, nextMs);
    };

    // first run immediately
    tick();
  }

  /**
   * Stops the scheduler loop and clears any pending timeouts.
   *
   * @returns {void}
   */
  stop() {
    if (this.handle) {
      clearTimeout(this.handle);
    }
    this.handle = null;
    this.lastCounter.clear();
  }

  /**
   * Calculates how many milliseconds remain until the soonest TOTP boundary
   * across all provided items.
   *
   * @param {TotpCode} items - List of TOTP definitions
   * @param {number} nowMs - Current time in milliseconds (UTC epoch)
   * @returns {number} Milliseconds until the next boundary
   */
  private msToSoonestBoundary(items: TotpCode[], nowMs: number): number {
    let best = Infinity;
    const defCodePeriod = Constants.DEFAULT_CODE_PERIOD;
    for (const it of items) {
      const periodMs = (it.period ?? defCodePeriod) * 1000;
      const remMs = (periodMs - (nowMs % periodMs)) % periodMs;
      // tiny epsilon to avoid landing *before* boundary due to clock jitter
      const wait = remMs === 0 ? 1 : remMs;
      if (wait < best) {
        best = wait;
      }
    }
    // clamp to avoid >1s waits when you only need per-second UI updates
    return Math.max(1, Math.min(best, 1000));
  }

  onDispose(): void {
    this.stop();
  }
}

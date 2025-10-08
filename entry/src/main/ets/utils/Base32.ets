export class Base32 {
  static isValid(input: string): boolean {
    const regex = /^[A-Z2-7=]+$/i; // RFC4648 standard
    return regex.test(input);
  }

  /**
   * Takes in a Base32 string and decodes it back to a Uint8Array
   */
  static decode(base32: string): Uint8Array {
    if (!base32 || base32.length === 0) {
      return new Uint8Array(0);
    }

    base32 = Base32.pad(base32);

    if (!Base32.isValid(base32)) {
      throw new Error('Invalid Base32 characters');
    }

    const decodeMap = Base32.getDecodeMap();
    let length = base32.indexOf('=');
    if (length === -1) {
      length = base32.length;
    }

    let i = 0;
    const count = (length >> 3) << 3; // largest multiple of 8 <= length
    const bytes: number[] = [];

    while (i < count) {
      const v1 = decodeMap.get(base32[i++]) ?? 0;
      const v2 = decodeMap.get(base32[i++]) ?? 0;
      const v3 = decodeMap.get(base32[i++]) ?? 0;
      const v4 = decodeMap.get(base32[i++]) ?? 0;
      const v5 = decodeMap.get(base32[i++]) ?? 0;
      const v6 = decodeMap.get(base32[i++]) ?? 0;
      const v7 = decodeMap.get(base32[i++]) ?? 0;
      const v8 = decodeMap.get(base32[i++]) ?? 0;

      bytes.push(((v1 << 3) | (v2 >> 2)) & 0xff);
      bytes.push(((v2 << 6) | (v3 << 1) | (v4 >> 4)) & 0xff);
      bytes.push(((v4 << 4) | (v5 >> 1)) & 0xff);
      bytes.push(((v5 << 7) | (v6 << 2) | (v7 >> 3)) & 0xff);
      bytes.push(((v7 << 5) | v8) & 0xff);
    }

    const remain = length - count;
    if (remain === 2) {
      const v1 = decodeMap.get(base32[i++]) ?? 0;
      const v2 = decodeMap.get(base32[i++]) ?? 0;
      bytes.push(((v1 << 3) | (v2 >> 2)) & 0xff);
    } else if (remain === 4) {
      const v1 = decodeMap.get(base32[i++]) ?? 0;
      const v2 = decodeMap.get(base32[i++]) ?? 0;
      const v3 = decodeMap.get(base32[i++]) ?? 0;
      const v4 = decodeMap.get(base32[i++]) ?? 0;
      bytes.push(((v1 << 3) | (v2 >> 2)) & 0xff);
      bytes.push(((v2 << 6) | (v3 << 1) | (v4 >> 4)) & 0xff);
    } else if (remain === 5) {
      const v1 = decodeMap.get(base32[i++]) ?? 0;
      const v2 = decodeMap.get(base32[i++]) ?? 0;
      const v3 = decodeMap.get(base32[i++]) ?? 0;
      const v4 = decodeMap.get(base32[i++]) ?? 0;
      const v5 = decodeMap.get(base32[i++]) ?? 0;
      bytes.push(((v1 << 3) | (v2 >> 2)) & 0xff);
      bytes.push(((v2 << 6) | (v3 << 1) | (v4 >> 4)) & 0xff);
      bytes.push(((v4 << 4) | (v5 >> 1)) & 0xff);
    } else if (remain === 7) {
      const v1 = decodeMap.get(base32[i++]) ?? 0;
      const v2 = decodeMap.get(base32[i++]) ?? 0;
      const v3 = decodeMap.get(base32[i++]) ?? 0;
      const v4 = decodeMap.get(base32[i++]) ?? 0;
      const v5 = decodeMap.get(base32[i++]) ?? 0;
      const v6 = decodeMap.get(base32[i++]) ?? 0;
      const v7 = decodeMap.get(base32[i++]) ?? 0;
      bytes.push(((v1 << 3) | (v2 >> 2)) & 0xff);
      bytes.push(((v2 << 6) | (v3 << 1) | (v4 >> 4)) & 0xff);
      bytes.push(((v4 << 4) | (v5 >> 1)) & 0xff);
      bytes.push(((v5 << 7) | (v6 << 2) | (v7 >> 3)) & 0xff);
    }

    return new Uint8Array(bytes);
  }

  private static pad(input: string): string {
    const neededPadding = (8 - (input.length % 8)) % 8;
    return input + '='.repeat(neededPadding);
  }

  private static getDecodeMap(): Map<string, number> {
    const map = new Map<string, number>();
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    for (let i = 0; i < alphabet.length; i++) {
      map.set(alphabet.charAt(i), i);
    }
    return map;
  }
}

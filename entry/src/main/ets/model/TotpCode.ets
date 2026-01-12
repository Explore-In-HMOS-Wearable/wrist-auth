export interface TotpCode {
  id: number,
  issuer: string;
  issuerColor?: ResourceColor,
  issuerBGColor?: ResourceColor,
  label: string,
  secret: string,
  algorithm: string,
  digits: number,
  period: number,
  createdAt: string
}
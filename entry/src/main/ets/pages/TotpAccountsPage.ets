import {
  UIContext,
  LengthMetrics,
  ArcList,
  ArcListItem,
  ArcListAttribute,
  ArcListItemAttribute,
  ComponentContent,
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics
} from '@kit.ArkUI';
import { AccountDetailsCard } from '../components/AccountDetailsCard';
import { SizeConstants } from '../constants/SizeConstants';
import { TotpCode } from '../model/TotpCode';
import AccountsViewModel from '../viewmodel/AccountsViewModel';
import { ADD_TOTP_ACCOUNT_PAGE } from './AddTotpAccountPage';

export const TOTP_ACCOUNTS_PAGE = 'TotpAccountsPage';

@Builder
export function TotpAccountsPageBuilder() {
  TotpAccountsPage();
}

@Builder
function buildHeader() {
  Text($r('app.string.totp_accounts'))
    .fontSize($r('app.float.list_header_font_size'))
    .fontWeight(FontWeight.Bold)
    .fontColor($r('app.color.on_primary_color'))
    .textAlign(TextAlign.Center)
    .width(SizeConstants.FULL_PERCENT)
    .margin({ top: $r('app.float.margin_6') })
}

@Component
struct TotpAccountsPage {
  @Consume('NavPathStack') private pageStack: NavPathStack;
  @State
  private viewModel: AccountsViewModel = new AccountsViewModel();
  private context: UIContext = this.getUIContext();
  private headerComponent: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildHeader));
  private bottomOptions = new ArcButtonOptions({
    label: $r('app.string.new_account'),
    styleMode: ArcButtonStyleMode.CUSTOM,
    fontSize: LengthMetrics.resource($r('app.float.list_header_font_size')),
    shadowEnabled: true,
    backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
    fontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    pressedFontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    shadowColor: ColorMetrics.resourceColor($r('app.color.background_color')),
    onClick: () => {
      this.pageStack.pushPathByName(ADD_TOTP_ACCOUNT_PAGE, null, () => {
        this.viewModel.loadAccounts();
      });
    }
  });

  aboutToAppear(): void {
    this.viewModel.loadAccounts()
  }

  aboutToDisappear() {
    this.viewModel.dispose();
  }

  @Builder
  private itemEnd(totpCode: TotpCode) {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize($r('app.float.list_header_font_size'))
          .fontColor([$r('app.color.on_brand_color')])
      }
      .padding($r('app.float.margin_6'))
      .backgroundColor($r('app.color.brand_color'))
      .type(ButtonType.Circle)
      .fontColor($r('app.color.on_brand_color'))
      .margin($r('app.float.margin_4'))
      .onClick(() => {
        this.viewModel.deleteTotpAccount(totpCode);
      })
    }
    .padding($r('app.float.margin_4'))
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    Stack() {
      ArcList({ header: this.headerComponent }) {
        if (this.viewModel.isEmptyData) {
          ArcListItem() {
            Text($r('app.string.empty_accounts_message'))
              .fontSize($r('app.float.empty_list_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_primary_color'))
              .textAlign(TextAlign.Center)
              .width(SizeConstants.PERCENT_80)
          }
        }

        LazyForEach(this.viewModel.datasource, (totpCode: TotpCode) => {
          ArcListItem() {
            AccountDetailsCard({
              label: totpCode.label,
              issuer: totpCode.issuer,
              issuerColor: totpCode.issuerColor,
              issuerBGColor: totpCode.issuerBGColor,
              counter: this.viewModel.remaining.get(totpCode.id),
              period: totpCode.period,
              code: this.viewModel.codes.get(totpCode.id)
            })
          }
          .width(SizeConstants.PERCENT_86)
          .swipeAction({
            end: {
              builder: () => this.itemEnd(totpCode),
              onAction: () => {
                this.context.animateTo({ duration: 1000 }, () => {
                  this.viewModel.deleteTotpAccount(totpCode);
                })
              },
              actionAreaDistance: 56
            }
          })
        }, (totpCode: TotpCode, index: number) => `${totpCode.id}-${index}`)

      }
      .space(LengthMetrics.resource($r('app.float.margin_8')))
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)

      ArcButton({
        options: this.bottomOptions
      }).align(Alignment.Bottom)
    }
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .alignContent(Alignment.Bottom)
  }
}
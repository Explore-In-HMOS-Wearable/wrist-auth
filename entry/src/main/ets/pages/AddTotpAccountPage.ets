import {
  LengthMetrics,
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
  SymbolGlyphModifier,
} from '@kit.ArkUI';
import { OptionBuilder } from '../components/OptionBuilder';
import { SizeConstants } from '../constants/SizeConstants';
import { copyLabelOption, LabelOption } from '../model/LabelOption';
import { Base32 } from '../utils/Base32';
import AddTotpAccountViewModel from '../viewmodel/AddTotpAccountViewModel';

export const ADD_TOTP_ACCOUNT_PAGE = 'AddTotpAccountPage';

@Builder
export function AddTotpAccountPageBuilder() {
  AddTotpAccountPage();
}

@Component
struct AddTotpAccountPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  private viewModel: AddTotpAccountViewModel = new AddTotpAccountViewModel();
  private context: UIContext = this.getUIContext();
  @State private secretKey: string = '';
  private symbolModifier: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.xmark_circle')).fontSize(16).fontWeight(FontWeight.Regular);
  @State private issuerOptions: LabelOption[] = this.viewModel.getIssuerOptions;
  @State private labelOptions: LabelOption[] = this.viewModel.getLabelOptions;
  private bottomOptions = new ArcButtonOptions({
    label: $r('app.string.add_account'),
    styleMode: ArcButtonStyleMode.CUSTOM,
    fontSize: LengthMetrics.resource($r('app.float.list_header_font_size')),
    shadowEnabled: true,
    backgroundColor: ColorMetrics.resourceColor($r('app.color.brand_color')),
    fontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    pressedFontColor: ColorMetrics.resourceColor($r('app.color.on_brand_color')),
    shadowColor: ColorMetrics.resourceColor($r('app.color.background_color')),
    onClick: async () => {
      const selectedIssuer = this.issuerOptions.find((opt) => opt.selected);
      const selectedLabel = this.labelOptions.find((opt) => opt.selected);
      const isValidSecretKey = this.secretKey && Base32.isValid(this.secretKey);

      if (this.secretKey.length <= 0) {
        this.showToastMsg($r('app.string.empty_secret_key'));
        return;
      }

      if (!isValidSecretKey) {
        this.showToastMsg($r('app.string.invalid_secret_key'));
        return;
      }

      if (!selectedIssuer) {
        this.showToastMsg($r('app.string.select_issuer'));
        return;
      }
      if (!selectedLabel) {
        this.showToastMsg($r('app.string.select_label'));
        return;
      }

      if (selectedIssuer && selectedLabel && isValidSecretKey) {
        await this.viewModel.addAccount(this.secretKey, selectedIssuer, selectedLabel);
        this.pageStack.pop({ result: true });
      }
    }
  });

  private showToastMsg(message: Resource) {
    this.context.getPromptAction().showToast({ message: message });
  }

  @Builder
  private labeledOptionsBuilder() {
    Column({ space: LengthMetrics.resource($r('app.float.margin_4')).value }) {
      TextInput({ placeholder: $r('app.string.enter_your_key'), text: `${this.secretKey}` })
        .inputFilter('[a-zA-Z2-7=]')
        .cancelButton({ icon: this.symbolModifier })
        .onChange((val: string) => this.secretKey = val.toUpperCase())

      Text($r('app.string.totp_issuer'))
        .fontSize($r('app.float.list_item_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Start)
        .width(SizeConstants.FULL_PERCENT)
        .margin({ left: $r('app.float.margin_4') })

      Flex({
        wrap: FlexWrap.Wrap, space: {
          main: LengthMetrics.resource($r('app.float.margin_4')),
          cross: LengthMetrics.resource($r('app.float.margin_2'))
        }
      }) {
        ForEach(this.issuerOptions, (option: LabelOption) => {
          OptionBuilder({
            labelOption: option,
            onClick: () => {
              this.issuerOptions = this.issuerOptions.map((opt) => {
                return copyLabelOption(opt, {
                  selected: opt.label === option.label ? !opt.selected : false,
                });
              });
            }
          })
        }, (option: LabelOption) => `${option.label}-${option.selected}`)
      }

      Text($r('app.string.totp_label'))
        .fontSize($r('app.float.list_item_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_primary_color'))
        .textAlign(TextAlign.Start)
        .width(SizeConstants.FULL_PERCENT)
        .margin({ top: $r('app.float.margin_4'), left: $r('app.float.margin_4') })

      Flex({
        wrap: FlexWrap.Wrap, space: {
          main: LengthMetrics.resource($r('app.float.margin_4')),
          cross: LengthMetrics.resource($r('app.float.margin_2'))
        }
      }) {
        ForEach(this.labelOptions, (option: LabelOption) => {
          OptionBuilder({
            labelOption: option,
            onClick: () => {
              this.labelOptions = this.labelOptions.map((opt) => {
                return copyLabelOption(opt, {
                  selected: opt.label === option.label ? !opt.selected : false,
                });
              });
            }
          })
        }, (option: LabelOption) => `${option.label}-${option.selected}`)
      }
    }
    .width(SizeConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .padding($r('app.float.margin_10'))
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column() {
            Text($r('app.string.new_account_title'))
              .fontSize($r('app.float.list_header_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_primary_color'))
              .textAlign(TextAlign.Center)
              .width(SizeConstants.FULL_PERCENT)


            this.labeledOptionsBuilder()
          }
          .margin({ bottom: $r('app.float.margin_24'), top: $r('app.float.margin_16') })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
        }
        .width(SizeConstants.FULL_PERCENT)
        .height(SizeConstants.FULL_PERCENT)
        .padding($r('app.float.margin_16'))

        ArcButton({
          options: this.bottomOptions
        }).align(Alignment.Bottom)
      }
      .width(SizeConstants.FULL_PERCENT)
      .height(SizeConstants.FULL_PERCENT)
      .alignContent(Alignment.Bottom)
    }
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
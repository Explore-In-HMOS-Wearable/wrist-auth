import { SizeConstants } from '../constants/SizeConstants';

@Component
export struct AccountDetailsCard {
  @Prop
  @Require
  label: string;
  @Prop
  @Require
  issuer: string;
  @Prop
  @Require
  issuerColor: ResourceColor;
  @Prop
  @Require
  issuerBGColor: ResourceColor;
  @Prop
  @Require
  counter: number;
  @Prop
  @Require
  period: number;
  @Prop
  @Require
  code: string;

  private formatTotpCode(code: string): string {
    // group digits in chunks of 3 and join with space
    return code.replace(/(\d{3})(?=\d)/g, '$1 ');
  }

  build() {
    Row() {
      Column() {
        Row() {
          Text(`${this.label}:`)
            .fontSize($r('app.float.list_item_title_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_primary_color'))
            .textAlign(TextAlign.Start)
          Blank().width($r('app.float.margin_2'))
          Text(this.issuer)
            .fontSize($r('app.float.list_item_desc_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_primary_color'))
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width(SizeConstants.FULL_PERCENT)

        Text(this.formatTotpCode(this.code))
          .fontSize($r('app.float.list_header_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_primary_color'))
          .textAlign(TextAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      Stack() {
        Progress({ value: this.counter, total: this.period, type: ProgressType.Ring })
          .width(34)
          .style({ strokeWidth: 5 })
          .color(this.issuerColor ?? Color.Blue)
          .backgroundColor(this.issuerBGColor ?? Color.Gray)
        Text(`${this.counter}`)
          .fontSize($r('app.float.list_item_desc_font_size'))
          .fontColor($r('app.color.on_primary_color'))
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

      }
      .alignContent(Alignment.Center)
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('app.color.primary_color'))
    .borderRadius($r('app.float.margin_16'))
    .padding({
      left: $r('app.float.margin_12'),
      top: $r('app.float.margin_8'),
      right: $r('app.float.margin_12'),
      bottom: $r('app.float.margin_8')
    })
    .align(Alignment.Start)
  }
}
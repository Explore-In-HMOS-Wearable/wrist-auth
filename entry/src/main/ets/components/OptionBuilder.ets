import { LabelOption } from '../model/LabelOption';

interface OptionBuilderParam {
  readonly labelOption: LabelOption,
  readonly fontSize?: number | string | Resource | undefined,
  readonly onClick: Callback<void>
}

@Builder
export function OptionBuilder(options: OptionBuilderParam) {
  Button() {
    Text(`${options.labelOption.label}`)
      .fontSize(options.fontSize ?? $r('app.float.list_item_title_font_size'))
      .fontColor(options.labelOption.selected ? $r('app.color.on_primary_color') : $r('app.color.on_brand_color'))
      .textAlign(TextAlign.Center)
  }
  .constraintSize({ minWidth: $r('app.float.min_chip_button_width') })
  .padding($r('app.float.margin_10'))
  .backgroundColor(options.labelOption.selected ?
    (options.labelOption.selectedColor ?? $r('app.color.brand_color')) :
    (options.labelOption.color ?? $r('app.color.primary_color')))
  .type(ButtonType.Capsule)
  .onClick(() => {
    options.onClick();
  })
}
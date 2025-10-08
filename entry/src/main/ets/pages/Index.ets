import { AddTotpAccountPageBuilder, ADD_TOTP_ACCOUNT_PAGE } from './AddTotpAccountPage';
import { TotpAccountsPageBuilder, TOTP_ACCOUNTS_PAGE } from './TotpAccountsPage';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === TOTP_ACCOUNTS_PAGE) {
      TotpAccountsPageBuilder();
    } else if (name === ADD_TOTP_ACCOUNT_PAGE) {
      AddTotpAccountPageBuilder();
    }
  }

  build() {
    Navigation(this.pageStack) {
      TotpAccountsPageBuilder()
    }
    .width($r('app.float.px_watch_size'))
    .height($r('app.float.px_watch_size'))
    .borderRadius($r('app.float.px_watch_radius'))
    .backgroundColor($r('app.color.background_color'))
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .ignoreLayoutSafeArea()
    .navDestination(this.PageMap)
  }
}
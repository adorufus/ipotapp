import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @welcomeToIpot.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ipot'**
  String get welcomeToIpot;

  /// No description provided for @tableTitle.
  ///
  /// In en, this message translates to:
  /// **'Table {tableId}'**
  String tableTitle(String tableId);

  /// No description provided for @backTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backTooltip;

  /// No description provided for @infoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTooltip;

  /// No description provided for @infoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Info coming soon'**
  String get infoComingSoon;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageMenuTooltip;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @offlineBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check Wi‑Fi or mobile data.'**
  String get offlineBannerMessage;

  /// No description provided for @readyToOrder.
  ///
  /// In en, this message translates to:
  /// **'Ready to order?'**
  String get readyToOrder;

  /// No description provided for @scanTableInstruction.
  ///
  /// In en, this message translates to:
  /// **'Scan the code on your table to browse our menu.'**
  String get scanTableInstruction;

  /// No description provided for @scanToOrder.
  ///
  /// In en, this message translates to:
  /// **'Scan to Order'**
  String get scanToOrder;

  /// No description provided for @bypassQrTableT001.
  ///
  /// In en, this message translates to:
  /// **'Bypass QR (Table T001)'**
  String get bypassQrTableT001;

  /// No description provided for @activeTableConnection.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TABLE CONNECTION'**
  String get activeTableConnection;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 items} one{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get noItemsFound;

  /// No description provided for @failedToLoadMenu.
  ///
  /// In en, this message translates to:
  /// **'Failed to load menu.\n{error}'**
  String failedToLoadMenu(String error);

  /// No description provided for @loadingMenuSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading menu'**
  String get loadingMenuSemantics;

  /// No description provided for @loadingMenu.
  ///
  /// In en, this message translates to:
  /// **'Loading menu…'**
  String get loadingMenu;

  /// No description provided for @searchMenuSemantics.
  ///
  /// In en, this message translates to:
  /// **'Search menu'**
  String get searchMenuSemantics;

  /// No description provided for @searchMenuHint.
  ///
  /// In en, this message translates to:
  /// **'Search for your favorite flavors…'**
  String get searchMenuHint;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @customizationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get customizationRequired;

  /// No description provided for @chooseUpTo.
  ///
  /// In en, this message translates to:
  /// **'Choose up to {max}'**
  String chooseUpTo(int max);

  /// No description provided for @priceAddModifier.
  ///
  /// In en, this message translates to:
  /// **'+\${delta}'**
  String priceAddModifier(String delta);

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addToCartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add {name} to cart'**
  String addToCartTooltip(String name);

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get cartEmpty;

  /// No description provided for @itemNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Item #{id}'**
  String itemNumberFallback(int id);

  /// No description provided for @decreaseQuantityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Decrease {name} quantity'**
  String decreaseQuantityTooltip(String name);

  /// No description provided for @increaseQuantityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Increase {name} quantity'**
  String increaseQuantityTooltip(String name);

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get clearCart;

  /// No description provided for @totalLine.
  ///
  /// In en, this message translates to:
  /// **'Total: \${total}'**
  String totalLine(String total);

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @placingOrderEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Placing order…'**
  String get placingOrderEllipsis;

  /// No description provided for @connectTableFirstSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Connect to a table and wait for the menu to load.'**
  String get connectTableFirstSnackbar;

  /// No description provided for @orderQueuedOffline.
  ///
  /// In en, this message translates to:
  /// **'Order saved on this device ({id}). It will send when you are back online.'**
  String orderQueuedOffline(String id);

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order {id} placed'**
  String orderPlaced(String id);

  /// No description provided for @optionNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Option #{id}'**
  String optionNumberFallback(int id);

  /// No description provided for @optionWithQuantity.
  ///
  /// In en, this message translates to:
  /// **'{name} ×{quantity}'**
  String optionWithQuantity(String name, int quantity);

  /// No description provided for @placingOrderSemantics.
  ///
  /// In en, this message translates to:
  /// **'Placing order'**
  String get placingOrderSemantics;

  /// No description provided for @dismissTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissTooltip;

  /// No description provided for @couldNotLoadPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Could not load pending orders: {error}'**
  String couldNotLoadPendingOrders(String error);

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you check out from the cart, your order will show up here.'**
  String get noOrdersYetSubtitle;

  /// No description provided for @waitingToSend.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send'**
  String get waitingToSend;

  /// No description provided for @latestOrder.
  ///
  /// In en, this message translates to:
  /// **'Latest order'**
  String get latestOrder;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistory;

  /// No description provided for @orderHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load order history: {error}'**
  String orderHistoryLoadFailed(String error);

  /// No description provided for @pendingQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item • will send when you are online} other{{count} items • will send when you are online}}'**
  String pendingQueueSubtitle(int count);

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// No description provided for @orderTotalLine.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}{currency}'**
  String orderTotalLine(String amount, String currency);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @orderUpdatedFromServer.
  ///
  /// In en, this message translates to:
  /// **'Order updated from server'**
  String get orderUpdatedFromServer;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel order?'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrderBody.
  ///
  /// In en, this message translates to:
  /// **'This asks the restaurant system to remove the order. You can\'t undo this from the app.'**
  String get cancelOrderBody;

  /// No description provided for @keepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get keepOrder;

  /// No description provided for @cancelOrderAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrderAction;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orderStatusReady;

  /// No description provided for @orderStatusServed.
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get orderStatusServed;

  /// No description provided for @scanQrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCodeTitle;

  /// No description provided for @toggleFlashTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get toggleFlashTooltip;

  /// No description provided for @pointCameraAtQr.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the QR code.'**
  String get pointCameraAtQr;

  /// No description provided for @tapCameraToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the camera to start scanning.'**
  String get tapCameraToStart;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @invalidTableQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a valid table code. Use a code like ipot://table/T001.'**
  String get invalidTableQr;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

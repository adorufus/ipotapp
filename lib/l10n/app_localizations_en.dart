// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navMenu => 'Menu';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get welcomeToIpot => 'Welcome to Ipot';

  @override
  String tableTitle(String tableId) {
    return 'Table $tableId';
  }

  @override
  String get backTooltip => 'Back';

  @override
  String get infoTooltip => 'Info';

  @override
  String get infoComingSoon => 'Info coming soon';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageSystem => 'System default';

  @override
  String get offlineBannerMessage =>
      'You\'re offline. Check Wi‑Fi or mobile data.';

  @override
  String get readyToOrder => 'Ready to order?';

  @override
  String get scanTableInstruction =>
      'Scan the code on your table to browse our menu.';

  @override
  String get scanToOrder => 'Scan to Order';

  @override
  String get bypassQrTableT001 => 'Bypass QR (Table T001)';

  @override
  String get activeTableConnection => 'ACTIVE TABLE CONNECTION';

  @override
  String get viewCart => 'View Cart';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: '0 items',
    );
    return '$_temp0';
  }

  @override
  String get noItemsFound => 'No items found.';

  @override
  String failedToLoadMenu(String error) {
    return 'Failed to load menu.\n$error';
  }

  @override
  String get loadingMenuSemantics => 'Loading menu';

  @override
  String get loadingMenu => 'Loading menu…';

  @override
  String get searchMenuSemantics => 'Search menu';

  @override
  String get searchMenuHint => 'Search for your favorite flavors…';

  @override
  String get customize => 'Customize';

  @override
  String get customizationRequired => 'Required';

  @override
  String chooseUpTo(int max) {
    return 'Choose up to $max';
  }

  @override
  String priceAddModifier(String delta) {
    return '+\$$delta';
  }

  @override
  String get addToCart => 'Add to cart';

  @override
  String get cancel => 'Cancel';

  @override
  String addToCartTooltip(String name) {
    return 'Add $name to cart';
  }

  @override
  String get cartEmpty => 'Your cart is empty.';

  @override
  String itemNumberFallback(int id) {
    return 'Item #$id';
  }

  @override
  String decreaseQuantityTooltip(String name) {
    return 'Decrease $name quantity';
  }

  @override
  String increaseQuantityTooltip(String name) {
    return 'Increase $name quantity';
  }

  @override
  String get clearCart => 'Clear cart';

  @override
  String totalLine(String total) {
    return 'Total: \$$total';
  }

  @override
  String get checkout => 'Checkout';

  @override
  String get placingOrderEllipsis => 'Placing order…';

  @override
  String get connectTableFirstSnackbar =>
      'Connect to a table and wait for the menu to load.';

  @override
  String orderQueuedOffline(String id) {
    return 'Order saved on this device ($id). It will send when you are back online.';
  }

  @override
  String orderPlaced(String id) {
    return 'Order $id placed';
  }

  @override
  String optionNumberFallback(int id) {
    return 'Option #$id';
  }

  @override
  String optionWithQuantity(String name, int quantity) {
    return '$name ×$quantity';
  }

  @override
  String get placingOrderSemantics => 'Placing order';

  @override
  String get dismissTooltip => 'Dismiss';

  @override
  String couldNotLoadPendingOrders(String error) {
    return 'Could not load pending orders: $error';
  }

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get noOrdersYetSubtitle =>
      'When you check out from the cart, your order will show up here.';

  @override
  String get waitingToSend => 'Waiting to send';

  @override
  String get latestOrder => 'Latest order';

  @override
  String pendingQueueSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items • will send when you are online',
      one: '1 item • will send when you are online',
    );
    return '$_temp0';
  }

  @override
  String get pendingSync => 'Pending sync';

  @override
  String orderTotalLine(String amount, String currency) {
    return 'Total: $amount$currency';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get orderUpdatedFromServer => 'Order updated from server';

  @override
  String get cancelOrderTitle => 'Cancel order?';

  @override
  String get cancelOrderBody =>
      'This asks the restaurant system to remove the order. You can\'t undo this from the app.';

  @override
  String get keepOrder => 'Keep order';

  @override
  String get cancelOrderAction => 'Cancel order';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusServed => 'Served';

  @override
  String get scanQrCodeTitle => 'Scan QR Code';

  @override
  String get toggleFlashTooltip => 'Toggle flash';

  @override
  String get pointCameraAtQr => 'Point your camera at the QR code.';

  @override
  String get tapCameraToStart => 'Tap the camera to start scanning.';

  @override
  String get scan => 'Scan';

  @override
  String get invalidTableQr =>
      'This QR code is not a valid table code. Use a code like ipot://table/T001.';
}

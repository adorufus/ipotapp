// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navMenu => '菜单';

  @override
  String get navCart => '购物车';

  @override
  String get navOrders => '订单';

  @override
  String get welcomeToIpot => '欢迎使用 Ipot';

  @override
  String tableTitle(String tableId) {
    return '$tableId 桌';
  }

  @override
  String get backTooltip => '返回';

  @override
  String get infoTooltip => '信息';

  @override
  String get infoComingSoon => '信息功能即将推出';

  @override
  String get languageMenuTooltip => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get offlineBannerMessage => '当前离线。请检查 Wi‑Fi 或移动数据。';

  @override
  String get readyToOrder => '准备点餐了吗？';

  @override
  String get scanTableInstruction => '扫描桌上的二维码即可浏览菜单。';

  @override
  String get scanToOrder => '扫码点餐';

  @override
  String get bypassQrTableT001 => '跳过扫码（T001 桌）';

  @override
  String get activeTableConnection => '桌台已连接';

  @override
  String get viewCart => '查看购物车';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$_temp0';
  }

  @override
  String get noItemsFound => '未找到菜品。';

  @override
  String failedToLoadMenu(String error) {
    return '菜单加载失败。\n$error';
  }

  @override
  String get loadingMenuSemantics => '正在加载菜单';

  @override
  String get loadingMenu => '正在加载菜单…';

  @override
  String get searchMenuSemantics => '搜索菜单';

  @override
  String get searchMenuHint => '搜索你喜欢的口味…';

  @override
  String get customize => '定制';

  @override
  String get customizationRequired => '必选';

  @override
  String chooseUpTo(int max) {
    return '最多选 $max 项';
  }

  @override
  String priceAddModifier(String delta) {
    return '+\$$delta';
  }

  @override
  String get addToCart => '加入购物车';

  @override
  String get cancel => '取消';

  @override
  String addToCartTooltip(String name) {
    return '将 $name 加入购物车';
  }

  @override
  String get cartEmpty => '购物车是空的。';

  @override
  String itemNumberFallback(int id) {
    return '菜品 #$id';
  }

  @override
  String decreaseQuantityTooltip(String name) {
    return '减少 $name 数量';
  }

  @override
  String increaseQuantityTooltip(String name) {
    return '增加 $name 数量';
  }

  @override
  String get clearCart => '清空购物车';

  @override
  String totalLine(String total) {
    return '合计：\$$total';
  }

  @override
  String get checkout => '去结算';

  @override
  String get placingOrderEllipsis => '正在下单…';

  @override
  String get connectTableFirstSnackbar => '请先连接桌台并等待菜单加载完成。';

  @override
  String orderQueuedOffline(String id) {
    return '订单已保存在本机（$id）。联网后将自动发送。';
  }

  @override
  String orderPlaced(String id) {
    return '订单 $id 已提交';
  }

  @override
  String optionNumberFallback(int id) {
    return '选项 #$id';
  }

  @override
  String optionWithQuantity(String name, int quantity) {
    return '$name ×$quantity';
  }

  @override
  String get placingOrderSemantics => '正在下单';

  @override
  String get dismissTooltip => '关闭';

  @override
  String couldNotLoadPendingOrders(String error) {
    return '无法加载待发送订单：$error';
  }

  @override
  String get noOrdersYet => '暂无订单';

  @override
  String get noOrdersYetSubtitle => '在购物车结算后，订单会显示在这里。';

  @override
  String get waitingToSend => '等待发送';

  @override
  String get latestOrder => '最近订单';

  @override
  String pendingQueueSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件 · 联网后发送',
    );
    return '$_temp0';
  }

  @override
  String get pendingSync => '等待同步';

  @override
  String orderTotalLine(String amount, String currency) {
    return '合计：$amount$currency';
  }

  @override
  String get refresh => '刷新';

  @override
  String get orderUpdatedFromServer => '已从服务器更新订单';

  @override
  String get cancelOrderTitle => '取消订单？';

  @override
  String get cancelOrderBody => '将向餐厅系统请求取消该订单。应用内无法撤销此操作。';

  @override
  String get keepOrder => '保留订单';

  @override
  String get cancelOrderAction => '取消订单';

  @override
  String get orderCancelled => '订单已取消';

  @override
  String get orderStatusPending => '待处理';

  @override
  String get orderStatusConfirmed => '已确认';

  @override
  String get orderStatusPreparing => '制作中';

  @override
  String get orderStatusReady => '可取餐';

  @override
  String get orderStatusServed => '已上菜';

  @override
  String get scanQrCodeTitle => '扫描二维码';

  @override
  String get toggleFlashTooltip => '开关闪光灯';

  @override
  String get pointCameraAtQr => '将相机对准二维码。';

  @override
  String get tapCameraToStart => '点击相机开始扫描。';

  @override
  String get scan => '扫描';
}

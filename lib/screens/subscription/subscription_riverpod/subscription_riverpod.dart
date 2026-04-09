import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_notifier.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_state.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/widgets/pop_up_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

import '../../../common/app_manger/app_cache.dart';
import '../../../repositories/account/account_api.dart';

const String _paymentMethod = 'Payment Method';
const String _shortDateFormat = 'MMM dd, yy';

class SubscriptionRiverpod extends ConsumerStatefulWidget {
  Map<String, dynamic> listData;
  SubscriptionRiverpod({super.key, required this.listData});

  @override
  ConsumerState<SubscriptionRiverpod> createState() =>
      _SubscriptionRiverpodState();
}

class _SubscriptionRiverpodState extends ConsumerState<SubscriptionRiverpod> {
  Map<String, dynamic> mapData = {};
  List<Map<String, dynamic>> allTransactions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subscriptionProvider.notifier).init(widget.listData);
    });
    getPaymentData();
  }

  int get _remainingDays {
    final ends = mapData['ends'];
    if (ends == null) return 0;
    final endDate = DateTime.fromMillisecondsSinceEpoch(ends * 1000);
    if (endDate.isBefore(DateTime.now())) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  Future<void> getPaymentData() async {
    // 1. Try cache for current subscription data
    Map<String, dynamic> map =
        await AppCache().getSubscriptionCacheData() ?? {};
    var data = map['listData'] ?? widget.listData;

    // 2. Fetch full payment list from API (for all transactions)
    try {
      final response = await AccountApi().paymentList({});
      final resp = response.data ?? {};
      if (resp['success'] == true &&
          resp['data']?['paymentList'] != null &&
          (resp['data']['paymentList'] as List).isNotEmpty) {
        final list = (resp['data']['paymentList'] as List)
            .cast<Map<String, dynamic>>();
        // If cache/extras were empty, use the first item as current subscription
        if (data is Map && data.isEmpty) {
          data = list[0];
          AppCache().setSubscriptionCacheData({'listData': data});
          if (mounted) {
            ref
                .read(subscriptionProvider.notifier)
                .init(
                  data is Map<String, dynamic>
                      ? data
                      : Map<String, dynamic>.from(data),
                );
          }
        }
        if (mounted) {
          setState(() {
            mapData = data is Map<String, dynamic> ? data : {};
            allTransactions = list;
          });
          return;
        }
      }
    } catch (e) {
      printLog("getPaymentData API error", e);
    }

    // 3. Fallback: use cache/extras data with single transaction
    printLog("mapData", data);
    if (mounted) {
      setState(() {
        mapData = data is Map<String, dynamic> ? data : {};
        if (mapData.isNotEmpty) {
          allTransactions = [mapData];
        }
      });
    }
  }

  String _getStatus(int currentTimestamp, int nextTimestamp) {
    DateTime nextDate = DateTime.fromMillisecondsSinceEpoch(
      nextTimestamp * 1000,
    );
    if (nextDate.isAfter(DateTime.now())) {
      return 'Active';
    } else {
      return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isDesktop = AppBreakpoints.isDesktopLayout(context);
    final subState = ref.watch(subscriptionProvider);
    final subNotifier = ref.read(subscriptionProvider.notifier);

    // Push route — must include title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShellLayout.of(context)?.setAppBarConfig(
          AppBarConfig(
            title: isDesktop ? 'Subscription' : 'Billing Details',
            hideUpgradeBanner: true,
          ),
        );
      }
    });

    return Scaffold(
      body: DelayedLoadingOverlay(
        isLoading: subState.isLoading || mapData.isEmpty,
        child: mapData.isEmpty
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.colors.outlineVariant,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusM,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                              child: isMobile
                                  ? _buildMobileRow(subState, subNotifier)
                                  : _buildDesktopRow(
                                      subState,
                                      subNotifier,
                                      isTablet,
                                    ),
                            ),
                            const Divider(),
                            Padding(
                              padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                              child: _buildFeaturesAndDetails(
                                isMobile,
                                subState,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 16.0 : 20.0,
                        ),
                        child: Text(
                          "Transaction Details",
                          textAlign: TextAlign.left,
                          style: AppTypography.black20(context),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 700) {
                            return _buildMobileTransaction();
                          }
                          return _buildDesktopTransaction(
                            context,
                            constraints.maxWidth,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMobileRow(
    SubscriptionState subState,
    SubscriptionNotifier subNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              mapData['plan']['title'] ?? '',
              style: AppTypography.black22(context),
            ),
            Text(
              '\$${mapData['charge']}',
              style: AppTypography.blackBold20(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$_remainingDays Days Remaining',
          style: AppTypography.redMedium15(context),
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: _ChangePaymentButton()),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _ChangeSubscriptionOrCancelButtonRiverpod(listData: mapData),
        ),
      ],
    );
  }

  Widget _buildDesktopRow(
    SubscriptionState subState,
    SubscriptionNotifier subNotifier,
    bool isTablet,
  ) {
    return Row(
      children: [
        Expanded(
          flex: isTablet ? 2 : 1,
          child: SizedBox(
            height: 50,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                Text(
                  mapData['plan']?['title'] ?? '',
                  style: AppTypography.black22(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    '\$${mapData['charge']}',
                    style: AppTypography.blackBold20(context),
                  ),
                ),
                Text(
                  '$_remainingDays Days Remaining',
                  style: AppTypography.redMedium15(context),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: isTablet ? 2 : 1,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChangePaymentButton(),
              _ChangeSubscriptionOrCancelButtonRiverpod(listData: mapData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesAndDetails(bool isMobile, subState) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Features', style: AppTypography.titleTxt(context)),
          const SizedBox(height: 8),
          for (var item in mapData['plan']['features'])
            if (item != '') _buildFeatureItem(item),
          const SizedBox(height: 16),
          _buildMobileDetailsGrid(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Features', style: AppTypography.titleTxt(context)),
              if (mapData['plan'] != null &&
                  mapData['plan']['features'] != null)
                for (var item in mapData['plan']['features'])
                  if (item != '') _buildFeatureItem(item),
            ],
          ),
        ),
        _buildDesktopDetailColumn(
          'Start Date',
          CommonService().formatUnixTimestamp(mapData['start'], dayFormate),
        ),
        _buildDesktopDetailColumn(
          'End Date',
          CommonService().formatUnixTimestamp(mapData['ends'], dayFormate),
        ),
        _buildDesktopDetailColumn(_paymentMethod, 'Card'),
        _buildDesktopDetailColumn('Amount', '\$${mapData['charge']}'),
      ],
    );
  }

  Widget _buildFeatureItem(String item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            _getStatus(mapData['start'], mapData['ends']) == "Active"
                ? svgRightGreen
                : svgRightGray,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item,
              style: AppTypography.titleTxt2(context),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDetailsGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildMobileDetailItem(
              'Start Date',
              CommonService().formatUnixTimestamp(mapData['start'], dayFormate),
            ),
            _buildMobileDetailItem(
              'End Date',
              CommonService().formatUnixTimestamp(mapData['ends'], dayFormate),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMobileDetailItem(_paymentMethod, 'Card'),
            _buildMobileDetailItem('Amount', '\$${mapData['charge']}'),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileDetailItem(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleTxt(context)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.inboxSubTitle2(context)),
        ],
      ),
    );
  }

  Widget _buildDesktopDetailColumn(String title, String value) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleTxt(context)),
          Text(value, style: AppTypography.inboxSubTitle2(context)),
        ],
      ),
    );
  }

  Widget _buildMobileTransaction() {
    return Column(
      children: [
        for (final tx in allTransactions) ...[
          _buildMobileTransactionCard(tx),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildMobileTransactionCard(Map<String, dynamic> tx) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tx['plan']?['title'] ?? '',
              style: AppTypography.transactionDetails(context),
            ),
            const SizedBox(height: 4),
            Text(
              tx['plan']?['description'] ?? '',
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
            const Divider(height: 24),
            Row(
              children: [
                _buildTransactionSmallInfo(
                  'Transaction Date',
                  CommonService().formatUnixTimestamp(tx['start'], dayFormate),
                ),
                _buildTransactionSmallInfo(
                  'Amount',
                  '\$${tx['charge']}',
                  isBold: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTransactionLargeInfo(
              'Service Period',
              "${CommonService().formatUnixTimestamp(tx['start'], _shortDateFormat)} - ${CommonService().formatUnixTimestamp(tx['ends'], _shortDateFormat)}",
            ),
            const SizedBox(height: 12),
            _buildTransactionLargeInfo(
              'Payment Method',
              '**** **** **** ${tx['last4']}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSmallInfo(
    String title,
    String value, {
    bool isBold = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption(
              context,
            ).copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionLargeInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.caption(
            context,
          ).copyWith(color: context.colors.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  Widget _buildDesktopTransaction(BuildContext context, double availableWidth) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.3),
        4: FixedColumnWidth(90.0),
      },
      border: TableBorder.all(
        color: context.colors.outlineVariant,
        width: 1.0,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      children: [
        _buildTableHeader(),
        for (int i = 0; i < allTransactions.length; i++)
          _buildTableRow(i, allTransactions[i]),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      children: const [
        _TableHeaderCell('Transaction'),
        _TableHeaderCell('Transaction Date'),
        _TableHeaderCell('Service Period'),
        _TableHeaderCell(_paymentMethod),
        _TableHeaderCell('Amount'),
      ],
    );
  }

  TableRow _buildTableRow(int index, Map<String, dynamic> tx) {
    return TableRow(
      children: [
        _TableCellColumn([
          Text(
            tx['plan']?['title'] ?? '',
            style: AppTypography.transactionDetails(context),
          ),
          const SizedBox(height: 4),
          Text(
            tx['plan']?['description'] ?? '',
            style: AppTypography.caption(
              context,
            ).copyWith(color: context.colors.onSurfaceVariant),
          ),
        ]),
        _TableCell(
          CommonService().formatUnixTimestamp(tx['start'], dayFormate),
        ),
        _TableCell(
          "${CommonService().formatUnixTimestamp(tx['start'], _shortDateFormat)} - ${CommonService().formatUnixTimestamp(tx['ends'], _shortDateFormat)}",
        ),
        _TableCell('**** **** **** ${tx['last4']}'),
        _TableCell('\$${tx['charge']}', isBold: true),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);
  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Text(
          text,
          style: AppTypography.titleSmall(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isBold;
  const _TableCell(this.text, {this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.top,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Text(
          text,
          style: AppTypography.bodySmall(
            context,
          ).copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
        ),
      ),
    );
  }
}

class _TableCellColumn extends StatelessWidget {
  final List<Widget> children;
  const _TableCellColumn(this.children);
  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.top,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _ChangePaymentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await context.push(AppRoutes.paymentMethod);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(context.appColors.accent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Change Payment Method",
          style: AppTypography.minMed14White(context),
        ),
      ),
    );
  }
}

class _ChangeSubscriptionOrCancelButtonRiverpod extends ConsumerStatefulWidget {
  final Map<String, dynamic> listData;
  const _ChangeSubscriptionOrCancelButtonRiverpod({required this.listData});
  @override
  ConsumerState<_ChangeSubscriptionOrCancelButtonRiverpod> createState() =>
      _ChangeSubscriptionOrCancelButtonRiverpodState();
}

class _ChangeSubscriptionOrCancelButtonRiverpodState
    extends ConsumerState<_ChangeSubscriptionOrCancelButtonRiverpod> {
  bool _isFreeUser = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = ref.read(authProvider).userData;
      if (!mounted) return;
      if (data != null && data['user'] != null) {
        setState(() {
          _isFreeUser = data['user']['isFreeUser'] == true;
        });
      }
    } catch (_) {}
  }

  Widget _buildChangeSubscriptionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            context.appColors.appBarGradient ??
            const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff121e57), Color(0xff2748c3)],
            ),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: TextButton(
        onPressed: () => context.push(AppRoutes.changeSubscription),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Change Subscription',
            style: AppTypography.minMed14White(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelMembershipButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomPopupModal(
              icon: svgInfo,
              title: cancelMembership,
              subtitle: cancelMembershipText,
              onPressedButton1: () => context.pop(),
              onPressedButton2: () async {
                context.pop();
                await ref
                    .read(subscriptionProvider.notifier)
                    .cancelMembership();
              },
              textButton1: 'No',
              textButton2: 'Yes',
            );
          },
        );
      },
      style: ButtonStyle(
        side: WidgetStateProperty.all(
          BorderSide(color: context.colors.outlineVariant, width: 1.0),
        ),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cancel Membership',
              style: AppTypography.minMed14Black(context),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SvgPicture.asset(svgInfo),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFreeUser) {
      return _buildChangeSubscriptionButton(context);
    }

    // Paid user: show both Change Subscription and Cancel Membership
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChangeSubscriptionButton(context),
        _buildCancelMembershipButton(context),
      ],
    );
  }
}

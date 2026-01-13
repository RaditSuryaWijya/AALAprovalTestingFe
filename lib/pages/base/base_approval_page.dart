import 'package:flutter/material.dart';
import '../../components/approval_card.dart';

abstract class BaseApprovalPageState<T extends StatefulWidget> extends State<T> {
  static const String fontFamily = 'mgopenmodata';
  static const Color backgroundColor = Colors.white;
  static const Color appBarBackgroundColor = Colors.grey;
  static const Color appBarForegroundColor = Colors.black;
  static const double appBarElevation = 0.0;
  static const double listPadding = 16.0;

  static const EdgeInsets approvalCardMargin = EdgeInsets.only(bottom: 1.0);
  static const double approvalCardPadding = 5.0;
  static const double approvalCardBorderRadius = 5.0;
  static const double approvalCardSpacing = 1.0;

  Color get appBarBgColor => Colors.grey.shade300;

  Widget buildApprovalCard({
    required Widget content,
    required VoidCallback onApprove,
    required VoidCallback onReject,
    required VoidCallback onDetail,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? approvalCardMargin,
      child: ApprovalCard(
        content: content,
        onApprove: onApprove,
        onReject: onReject,
        onDetail: onDetail,
      ),
    );
  }

  bool get isLoading;
  bool get isEmpty;
  String get emptyMessage;
  IconData get emptyIcon;

  String get pageTitle;
  Future<void> loadData();
  Widget buildCardItem(int index);
  int get itemCount;

  String? get customEmptyMessage => null;
  IconData? get customEmptyIcon => null;

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: Text(
        pageTitle,
        style: const TextStyle(
          fontFamily: fontFamily,
        ),
      ),
      backgroundColor: appBarBgColor,
      foregroundColor: appBarForegroundColor,
      elevation: appBarElevation,
    );
  }

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            customEmptyIcon ?? emptyIcon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            customEmptyMessage ?? emptyMessage,
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontFamily: fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListBody() {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(listPadding),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return buildCardItem(index);
        },
      ),
    );
  }

  Widget buildMainBody() {
    if (isLoading) {
      return buildLoadingState();
    }

    if (isEmpty) {
      return buildEmptyState();
    }

    return buildListBody();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildAppBar(),
      body: buildMainBody(),
    );
  }
}

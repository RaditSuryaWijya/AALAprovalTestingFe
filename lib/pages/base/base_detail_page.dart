import 'package:flutter/material.dart';

abstract class BaseDetailPageState<T extends StatefulWidget> extends State<T> {

  static const String fontFamily = 'mgopenmodata';
  static const Color backgroundColor = Colors.white;
  static const Color appBarBackgroundColor = Colors.grey;
  static const Color appBarForegroundColor = Colors.black;
  static const double appBarElevation = 0.0;
  static const double contentPadding = 7.0;

  Color get appBarBgColor => Colors.grey.shade300;


  static const double labelFontSize = 12.0;
  static const double valueFontSize = 16.0;
  static const double titleFontSize = 18.0;

  bool get isLoading;
  bool get isNotFound;


  String get pageTitle;
  Widget buildContent();

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
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildNotFoundState() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildAppBar(),
      body: const Center(
        child: Text(
          'Data tidak ditemukan',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(
      String label,
      String value, {
        bool isMultiline = false,
        bool isReject = false,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isMultiline ? FontWeight.normal : FontWeight.w500,
              color: valueColor ?? (isReject ? Colors.red : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusChip(String status, Color statusColor) {
    return Center(
      child: Chip(
        label: Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        backgroundColor: statusColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget buildInfoCard(Widget content) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0), // Ubah angka 16 sesuai keinginan
      ),
      child: Padding(
        padding: const EdgeInsets.all(contentPadding),
        child: content,
      ),
    );
  }

  Widget buildTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: titleFontSize,
        fontFamily: fontFamily,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildLoadingState();
    }

    if (isNotFound) {
      return buildNotFoundState();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(contentPadding),
        child: buildContent(),
      ),
    );
  }
}

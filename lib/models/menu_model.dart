import 'package:flutter/material.dart';

class MenuModel {
  final int id;
  final String label;
  final String icon;
  final String menuLink;
  final int index;

  MenuModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.menuLink,
    required this.index,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] ?? 0,
      label: json['label']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      menuLink: json['menu_link']?.toString() ?? '',
      index: json['index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon,
      'menu_link': menuLink,
      'index': index,
    };
  }

  // Helper untuk get icon dari string
  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard;
      case 'access_time':
        return Icons.access_time;
      case 'add_circle':
        return Icons.add_circle;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'add':
        return Icons.add;
      case 'rule':
        return Icons.rule;
      default:
        return Icons.menu;
    }
  }
}

class MenuResponseModel {
  final List<MenuModel> menus;
  final String jabatan;
  final String department;
  final bool isITDepartment;

  MenuResponseModel({
    required this.menus,
    required this.jabatan,
    required this.department,
    required this.isITDepartment,
  });

  factory MenuResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final menusList = data['menus'] ?? [];
    final userData = data['user'] ?? {};

    return MenuResponseModel(
      menus: (menusList as List)
          .map((item) => MenuModel.fromJson(item))
          .toList()
        ..sort((a, b) => a.index.compareTo(b.index)),
      jabatan: userData['jabatan']?.toString() ?? '',
      department: userData['department']?.toString() ?? '',
      isITDepartment: userData['isITDepartment'] ?? false,
    );
  }
}


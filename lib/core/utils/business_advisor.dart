import 'package:flutter/material.dart';
import 'package:needlix/features/dashboard/models/dashboard_data.dart';

class BusinessAdvice {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  BusinessAdvice({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

class BusinessAdvisor {
  static List<BusinessAdvice> getAdvice(DashboardData data) {
    final List<BusinessAdvice> adviceList = [];

    // Revenue Advice
    if (data.weeklyRevenue == 0) {
      adviceList.add(BusinessAdvice(
        title: 'Boost Your Revenue',
        message: 'You haven\'t recorded any payments this week. Try following up on pending invoices!',
        icon: Icons.trending_up,
        color: Colors.orange,
      ));
    } else if (data.weeklyRevenue > 0 && data.activeOrders > 5) {
      adviceList.add(BusinessAdvice(
        title: 'Busy Season',
        message: 'You have many active orders. Consider setting clear delivery dates to manage customer expectations.',
        icon: Icons.event_available,
        color: Colors.blue,
      ));
    }

    // Customer Growth Advice
    if (data.newCustomers == 0) {
      adviceList.add(BusinessAdvice(
        title: 'Find New Clients',
        message: 'No new customers this week. Share your recent work on social media or the Community tab!',
        icon: Icons.person_add_outlined,
        color: Colors.purple,
      ));
    } else {
       adviceList.add(BusinessAdvice(
        title: 'Great Growth!',
        message: 'You added ${data.newCustomers} new customers this week. Personalized thank-you notes can build long-term loyalty.',
        icon: Icons.star_border,
        color: Colors.green,
      ));
    }

    // Inquiry Advice
    if (data.inquiryCount > 0) {
      adviceList.add(BusinessAdvice(
        title: 'Turn Chats into Orders',
        message: 'You have ${data.inquiryCount} marketplace inquiries. Responding within 2 hours increases conversion by 50%!',
        icon: Icons.chat_bubble_outline,
        color: Colors.teal,
      ));
    }

    // General Tips
    adviceList.add(BusinessAdvice(
      title: 'Pro Tip: Photos Matter',
      message: 'Orders with high-quality photos get 3x more repeat business. Use good lighting for your finished works.',
      icon: Icons.camera_alt_outlined,
      color: Colors.grey,
    ));

    return adviceList;
  }
}

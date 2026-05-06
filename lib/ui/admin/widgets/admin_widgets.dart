import 'package:flutter/material.dart';

class AdminFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const AdminFilterChip({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFB11A23) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class AdminReportCard extends StatelessWidget {
  final String severity;
  final String category;
  final String time;
  final String title;
  final String seller;
  final String reporter;
  final String description;
  final String status;

  const AdminReportCard({
    super.key,
    required this.severity,
    required this.category,
    required this.time,
    required this.title,
    required this.seller,
    required this.reporter,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    if (severity == 'CRITICAL') {
      severityColor = const Color(0xFFB11A23);
    } else if (severity == 'HIGH') {
      severityColor = Colors.amber.shade600;
    } else {
      severityColor = Colors.orange; // MEDIUM
    }

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    if (status == 'pending') {
      statusColor = Colors.amber.shade700;
      statusBgColor = Colors.orange.shade50;
      statusIcon = Icons.access_time;
    } else if (status == 'under review') {
      statusColor = Colors.blue.shade700;
      statusBgColor = Colors.blue.shade50;
      statusIcon = Icons.trending_up;
    } else {
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade50;
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severity == 'CRITICAL' ? const Color(0xFFB11A23) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: severityColor, borderRadius: BorderRadius.circular(4)),
                child: Text(severity, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(category, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
              ),
              const Spacer(),
              Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Seller: $seller • Reporter: $reporter', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 12),
                const SizedBox(width: 4),
                Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminVerificationCard extends StatelessWidget {
  final String statusBadge; // PENDING, APPROVED, REJECTED
  final String course;
  final String time;
  final String name;
  final String email;
  final String studentId;
  final String statusText;
  final String bottomBadgeStatus;

  const AdminVerificationCard({
    super.key,
    required this.statusBadge,
    required this.course,
    required this.time,
    required this.name,
    required this.email,
    required this.studentId,
    required this.statusText,
    required this.bottomBadgeStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor = Colors.white;
    if (statusBadge == 'PENDING') {
      badgeColor = Colors.amber.shade400;
      badgeTextColor = Colors.black87;
    } else if (statusBadge == 'APPROVED') {
      badgeColor = Colors.grey.shade300;
      badgeTextColor = Colors.white;
    } else {
      badgeColor = Colors.grey.shade300;
      badgeTextColor = Colors.white;
    }

    Color bottomBadgeColor;
    Color bottomBadgeBgColor;
    if (bottomBadgeStatus == 'pending') {
      bottomBadgeColor = Colors.amber.shade700;
      bottomBadgeBgColor = Colors.amber.shade50;
    } else if (bottomBadgeStatus == 'approved') {
      bottomBadgeColor = Colors.green.shade700;
      bottomBadgeBgColor = Colors.green.shade50;
    } else {
      bottomBadgeColor = Colors.green.shade700;
      bottomBadgeBgColor = Colors.green.shade50; // Use green styling for rejected in the design image? Actually rejected is grey in the original screens, let's use green for positive or red for negative, wait in the third image, 'rejected' is green text.
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusBadge == 'PENDING' ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusBadge == 'PENDING' ? Colors.amber.shade400 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                child: Text(statusBadge, style: TextStyle(color: badgeTextColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(course, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
              ),
              const Spacer(),
              Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Email: $email • Student ID: $studentId', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
          const SizedBox(height: 8),
          Text(statusText, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bottomBadgeBgColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bottomBadgeStatus == 'pending')
                  Icon(Icons.access_time, color: bottomBadgeColor, size: 12),
                const SizedBox(width: 4),
                Text(bottomBadgeStatus, style: TextStyle(color: bottomBadgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color bgColor;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}

class AdminQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color iconColor;
  final Color bgColor;

  const AdminQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87))),
          Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: iconColor)),
        ],
      ),
    );
  }
}

class AdminActivityItem extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String time;

  const AdminActivityItem({
    super.key,
    required this.dotColor,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminRevenueCard extends StatelessWidget {
  final Color bgColor;
  final IconData leadingIcon;
  final String amount;
  final String title;
  final String subtitle;
  final IconData trailingIcon;

  const AdminRevenueCard({
    super.key,
    required this.bgColor,
    required this.leadingIcon,
    required this.amount,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(leadingIcon, color: Colors.white, size: 24),
              Icon(trailingIcon, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class AdminCommissionRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;

  const AdminCommissionRow({
    super.key,
    required this.dotColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class AdminTransactionCard extends StatelessWidget {
  final String statusBadge; // COMPLETED, PENDING
  final String itemCategory;
  final String time;
  final String title;
  final String amount;
  final String fee;
  final String paymentMethod;
  final String bottomBadgeStatus; // completed, pending

  const AdminTransactionCard({
    super.key,
    required this.statusBadge,
    required this.itemCategory,
    required this.time,
    required this.title,
    required this.amount,
    required this.fee,
    required this.paymentMethod,
    required this.bottomBadgeStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor = Colors.white;
    if (statusBadge == 'PENDING') {
      badgeColor = Colors.amber.shade400;
      badgeTextColor = Colors.black87;
    } else {
      badgeColor = Colors.grey.shade300;
      badgeTextColor = Colors.white;
    }

    Color bottomBadgeColor;
    Color bottomBadgeBgColor;
    if (bottomBadgeStatus == 'pending') {
      bottomBadgeColor = Colors.amber.shade700;
      bottomBadgeBgColor = Colors.amber.shade50;
    } else {
      bottomBadgeColor = Colors.green.shade700;
      bottomBadgeBgColor = Colors.green.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusBadge == 'PENDING' ? Colors.amber.shade400 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                child: Text(statusBadge, style: TextStyle(color: badgeTextColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(itemCategory, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
              ),
              const Spacer(),
              Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text('Amount: $amount • Fee: $fee', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 8),
          Text('Payment Method: $paymentMethod', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bottomBadgeBgColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bottomBadgeStatus == 'pending')
                  Icon(Icons.access_time, color: bottomBadgeColor, size: 12),
                const SizedBox(width: 4),
                Text(bottomBadgeStatus, style: TextStyle(color: bottomBadgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

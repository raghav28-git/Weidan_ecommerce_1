import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../utils/responsive.dart';

class ViewOrdersScreen extends StatelessWidget {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.hPadding(context);
    final bottomPad = Responsive.navBarClearance(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 3));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.grey[200], shape: BoxShape.circle),
                    child: Icon(Icons.receipt_long,
                        size: 60, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 24),
                  Text('No Orders Yet',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hp),
                    child: Text(
                      'Orders will appear here once customers start placing them',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding:
                EdgeInsets.fromLTRB(hp, 16, hp, bottomPad),
            itemCount: orders.length,
            itemBuilder: (context, index) =>
                _OrderCard(order: orders[index], orderService: _orderService),
          );
        },
      ),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const _OrderCard({required this.order, required this.orderService});

  static const _statusMeta = {
    'pending': _StatusMeta(Colors.orange, Icons.schedule),
    'processing': _StatusMeta(Colors.blue, Icons.sync),
    'shipped': _StatusMeta(Colors.purple, Icons.local_shipping),
    'delivered': _StatusMeta(Colors.green, Icons.check_circle),
    'cancelled': _StatusMeta(Colors.red, Icons.cancel),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta[order.status.toLowerCase()] ??
        const _StatusMeta(Colors.grey, Icons.help);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.receipt_long,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                          '${order.date.day}/${order.date.month}/${order.date.year}',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showStatusDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                        color: meta.color,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(meta.icon, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(order.status.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit,
                            color: Colors.white, size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Customer
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text('Customer: ${order.userId.substring(0, 8)}',
                      style: TextStyle(
                          color: Colors.grey[700], fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Items (${order.items.length})',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Items
            ...order.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.shopping_bag,
                            color: Colors.grey[600], size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            if (item.size != null)
                              Text('Size: ${item.size}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Text('x${item.quantity}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(width: 10),
                      Text(
                          '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
            const SizedBox(height: 14),
            // Total
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('₹${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context) {
    final statuses = [
      {'name': 'pending', 'color': Colors.orange, 'icon': Icons.schedule},
      {'name': 'processing', 'color': Colors.blue, 'icon': Icons.sync},
      {
        'name': 'shipped',
        'color': Colors.purple,
        'icon': Icons.local_shipping
      },
      {
        'name': 'delivered',
        'color': Colors.green,
        'icon': Icons.check_circle
      },
      {'name': 'cancelled', 'color': Colors.red, 'icon': Icons.cancel},
    ];

    showDialog(
      context: context,
      builder: (_) => Responsive.responsiveDialog(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Order Status',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Order #${order.id.substring(0, 8)}',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 20),
            ...statuses.map((s) {
              final isSelected = order.status == s['name'];
              final color = s['color'] as Color;
              return GestureDetector(
                onTap: () async {
                  await orderService.updateOrderStatus(
                      order.id, s['name'] as String);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected
                            ? color
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                        child: Icon(s['icon'] as IconData,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          (s['name'] as String).toUpperCase(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? color
                                  : Colors.black),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: color, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text('Cancel',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700]))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMeta {
  final Color color;
  final IconData icon;
  const _StatusMeta(this.color, this.icon);
}

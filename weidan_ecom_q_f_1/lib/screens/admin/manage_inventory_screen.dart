import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../utils/responsive.dart';

class ManageInventoryScreen extends StatelessWidget {
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    final hp = Responsive.hPadding(context);
    final bottomPad = Responsive.navBarClearance(context);

    return StreamBuilder<List<ProductModel>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                  child: Icon(Icons.inventory_2, size: 60, color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                Text('No Products in Inventory',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('Add products to manage inventory',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
          );
        }
        final products = snapshot.data!;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hp, 16, hp, 0),
                child: _StatsBar(products: products),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 16, hp, bottomPad),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _InventoryCard(
                    product: products[index],
                    productService: _productService,
                  ),
                  childCount: products.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Stats Bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final List<ProductModel> products;
  const _StatsBar({required this.products});

  @override
  Widget build(BuildContext context) {
    final total = products.length;
    final lowStock = products.where((p) => p.stock > 0 && p.stock < 10).length;
    final outOfStock = products.where((p) => p.stock == 0).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _statItem('$total', 'Total'),
          Container(width: 1, height: 36, color: Colors.grey[600]),
          _statItem('$lowStock', 'Low Stock'),
          Container(width: 1, height: 36, color: Colors.grey[600]),
          _statItem('$outOfStock', 'Out of Stock'),
        ],
      ),
    );
  }

  Widget _statItem(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(number,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[300]),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Inventory Card ────────────────────────────────────────────────────────────

class _InventoryCard extends StatelessWidget {
  final ProductModel product;
  final ProductService productService;

  const _InventoryCard(
      {required this.product, required this.productService});

  @override
  Widget build(BuildContext context) {
    final Color stockColor;
    final IconData stockIcon;
    final String stockStatus;

    if (product.stock == 0) {
      stockColor = Colors.red;
      stockIcon = Icons.error;
      stockStatus = 'Out of Stock';
    } else if (product.stock < 10) {
      stockColor = Colors.orange;
      stockIcon = Icons.warning;
      stockStatus = 'Low Stock';
    } else {
      stockColor = Colors.green;
      stockIcon = Icons.check_circle;
      stockStatus = 'In Stock';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: Responsive.isTablet(context) ? 88 : 72,
                    height: Responsive.isTablet(context) ? 88 : 72,
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imgPlaceholder())
                        : _imgPlaceholder(),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(product.category,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 11)),
                      ),
                      const SizedBox(height: 6),
                      Text('₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                  ),
                ),
                // Stock badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stockColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(stockIcon, color: stockColor, size: 14),
                      const SizedBox(width: 5),
                      Text(stockStatus,
                          style: TextStyle(
                              color: stockColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stock row
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.inventory,
                      color: Colors.grey[600], size: 18),
                  const SizedBox(width: 8),
                  Text('Stock: ${product.stock}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        _showUpdateStockDialog(context, product),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('Update',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: Colors.grey[100],
        child: Center(
            child: Icon(Icons.inventory_2,
                size: 32, color: Colors.grey[400])),
      );

  void _showUpdateStockDialog(
      BuildContext context, ProductModel product) {
    final controller =
        TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (_) => Responsive.responsiveDialog(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.inventory,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 14),
            const Text('Update Stock',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(product.name,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Colors.black, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final newStock =
                          int.tryParse(controller.text);
                      if (newStock != null && newStock >= 0) {
                        await productService.updateStock(
                            product.id, newStock);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Stock updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a valid number'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                          child: Text('Update',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

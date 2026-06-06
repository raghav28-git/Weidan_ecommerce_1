import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive.dart';

class ManageProductsScreen extends StatefulWidget {
  @override
  _ManageProductsScreenState createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ProductService _productService = ProductService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<ProductModel> _filtered(List<ProductModel> products) {
    return products.where((p) {
      final matchCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

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
          return _buildEmpty();
        }
        final products = _filtered(snapshot.data!);
        return Column(
          children: [
            _buildControls(snapshot.data!.length, hp),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text('No products match your search.',
                          style: TextStyle(color: Colors.grey[500])))
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(hp, 16, hp, bottomPad),
                      gridDelegate: Responsive.productGridDelegate(context),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _ProductCard(
                        product: products[index],
                        onEdit: () => _showProductDialog(product: products[index]),
                        onDelete: () => _deleteProduct(products[index].id),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(int total, double hp) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hp, 16, hp, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Products',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('$total products',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              _AddButton(onTap: () => _showProductDialog()),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search products…',
              prefixIcon:
                  const Icon(Icons.search, color: Colors.grey, size: 20),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.categoriesWithAll.map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.black
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                color: Colors.grey[200], shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag,
                size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text('No Products Available',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Add your first product to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          _AddButton(onTap: () => _showProductDialog()),
        ],
      ),
    );
  }

  void _showProductDialog({ProductModel? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => ProductDialog(
        product: product,
        onSave: (p) async {
          if (product == null) {
            await _productService.addProduct(p);
          } else {
            await _productService.updateProduct(p);
          }
        },
      ),
    );
  }

  void _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(),
    );
    if (confirm == true) {
      await _productService.deleteProduct(productId);
    }
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text('Add Product',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard(
      {required this.product,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(product.imageUrl,
                      width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12)),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.circular(6)),
                            child: const Center(
                                child: Icon(Icons.edit,
                                    color: Colors.white, size: 13)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius:
                                  BorderRadius.circular(6)),
                          child: const Icon(Icons.delete,
                              color: Colors.red, size: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[100],
        child: Center(
            child: Icon(Icons.shopping_bag,
                size: 36, color: Colors.grey[400])),
      );
}

class _ConfirmDeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Responsive.responsiveDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.red[50], shape: BoxShape.circle),
            child:
                const Icon(Icons.delete, color: Colors.red, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Delete Product',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Are you sure? This action cannot be undone.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _DialogBtn(
                  label: 'Cancel',
                  color: Colors.grey[200]!,
                  textColor: Colors.grey[700]!,
                  onTap: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogBtn(
                  label: 'Delete',
                  color: Colors.red,
                  textColor: Colors.white,
                  onTap: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogBtn(
      {required this.label,
      required this.color,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor))),
      ),
    );
  }
}

// ── ProductDialog ─────────────────────────────────────────────────────────────

class ProductDialog extends StatefulWidget {
  final ProductModel? product;
  final Function(ProductModel) onSave;

  const ProductDialog({this.product, required this.onSave});

  @override
  _ProductDialogState createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _sizesController = TextEditingController();

  String _selectedCategory = AppConstants.categories.first;
  File? _imageFile;
  String _imageUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toString();
      _stockController.text = p.stock.toString();
      _selectedCategory = p.category;
      _imageUrl = p.imageUrl;
      _sizesController.text = p.sizes.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _sizesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDec(String label, {String? hint, String? prefix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        prefixStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC6F135), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );

  static const _bg = Color(0xFF111111);

  // ── responsive helpers ──────────────────────────────────────────────────────
  static double _sheetWidth(double screenW) =>
      screenW > 720 ? 600.0 : screenW > 480 ? screenW * 0.92 : screenW;

  static double _sheetMaxHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.size.height - mq.padding.top - 24;
  }

  @override
  Widget build(BuildContext context) {
    final mq        = MediaQuery.of(context);
    final screenW   = mq.size.width;
    final sheetW    = _sheetWidth(screenW);
    final maxH      = _sheetMaxHeight(context);
    final kbInset   = mq.viewInsets.bottom;
    final isTablet  = screenW > 600;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:  sheetW,
          maxHeight: maxH,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFC6F135).withOpacity(0.3),
                            width: 1),
                      ),
                      child: const Icon(Icons.inventory_2_rounded,
                          color: Color(0xFFC6F135), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              widget.product == null
                                  ? 'New Product'
                                  : 'Edit Product',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3)),
                          Text(
                              widget.product == null
                                  ? 'Add a new item to your catalog'
                                  : 'Update product information',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.4),
                                  letterSpacing: 0.1)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.close_rounded,
                            color: Colors.white.withOpacity(0.55), size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDec('Product Name'),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _inputDec('Category'),
                          dropdownColor: const Color(0xFF1E1E1E),
                          style: const TextStyle(color: Colors.white),
                          items: AppConstants.categories
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _priceController,
                          decoration: _inputDec('Price', prefix: '₹ '),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDec('Description'),
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _stockController,
                          decoration: _inputDec('Stock Quantity'),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _sizesController,
                          decoration: _inputDec('Sizes',
                              hint: 'S, M, L, XL or 7, 8, 9'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        // Image upload section
                        _ImageUploadCard(
                          imageFile: _imageFile,
                          imageUrl: _imageUrl,
                          onTap: _pickImage,
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
              // Actions — sticky, keyboard-aware
              Container(
                padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 24,
                    16,
                    isTablet ? 32 : 24,
                    24 + kbInset + mq.padding.bottom),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.07))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Center(
                            child: Text('Cancel',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Colors.white.withOpacity(0.7))),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _saveProduct,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _isLoading
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFC6F135),
                            boxShadow: _isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFFC6F135)
                                          .withOpacity(0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    )
                                  ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black))
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_rounded,
                                          color: Colors.black, size: 18),
                                      SizedBox(width: 8),
                                      Text('Save Product',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                              letterSpacing: 0.2)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageFile = File(image.path));
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      String imageUrl = _imageUrl;
      if (_imageFile != null) {
        imageUrl = await ProductService().uploadImage(_imageFile!);
      }
      final sizes = _sizesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await widget.onSave(ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: imageUrl,
        stock: int.parse(_stockController.text),
        sizes: sizes,
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isLoading = false);
  }
}

// ── Image Upload Card ─────────────────────────────────────────────────────────

class _ImageUploadCard extends StatelessWidget {
  final File? imageFile;
  final String imageUrl;
  final VoidCallback onTap;

  const _ImageUploadCard({
    required this.imageFile,
    required this.imageUrl,
    required this.onTap,
  });

  bool get _hasImage => imageFile != null || imageUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Image',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 0.3)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: _hasImage ? 180 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hasImage
                    ? const Color(0xFFC6F135).withOpacity(0.4)
                    : Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: _hasImage ? _preview() : _placeholder(),
          ),
        ),
      ],
    );
  }

  Widget _preview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageFile != null
              ? Image.file(imageFile!, fit: BoxFit.cover)
              : Image.network(imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder()),
          // Overlay change button
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFC6F135).withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded,
                      color: Color(0xFFC6F135), size: 13),
                  SizedBox(width: 5),
                  Text('Change',
                      style: TextStyle(
                          color: Color(0xFFC6F135),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.cloud_upload_rounded,
              color: Colors.white.withOpacity(0.35), size: 22),
        ),
        const SizedBox(height: 10),
        Text('Tap to upload image',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('PNG, JPG supported',
            style: TextStyle(
                color: Colors.white.withOpacity(0.2), fontSize: 11)),
      ],
    );
  }
}

import sys
sys.stdout.reconfigure(encoding='utf-8')

path = r'c:\Users\DELL\Desktop\weidan_git\weidan_ecom_q_f_1\lib\screens\user\product_detail_screen.dart'

with open(path, 'r', encoding='utf-8') as f:
    src = f.read()

fixes = []

# Fix 1a: add isSmall/sw/vs vars after hPad in _buildInfoCard
fixes.append((
    "    final hPad = Responsive.hPadding(context);\n"
    "\n"
    "    return Container(\n"
    "      margin: EdgeInsets.fromLTRB(hPad * 0.7, 16, hPad * 0.7, 0),",
    "    final hPad    = Responsive.hPadding(context);\n"
    "    final isSmall = Responsive.isSmallPhone(context);\n"
    "    final sw      = MediaQuery.of(context).size.width;\n"
    "    final vs      = Responsive.vSpacing(context);\n"
    "\n"
    "    return Container(\n"
    "      margin: EdgeInsets.fromLTRB(hPad * 0.7, 16, hPad * 0.7, 0),",
))

# Fix 1b: inner padding (already applied, keep for idempotency)
fixes.append((
    "        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 20),",
    "        padding: EdgeInsets.fromLTRB(hPad, isSmall ? 16 : 20, hPad, isSmall ? 16 : 20),",
))

# Fix 1c: badge->name gap + name font min clamp
fixes.append((
    "          const SizedBox(height: 14),\n"
    "\n"
    "          // \u2500\u2500 Product name \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          Text(\n"
    "            p.name,\n"
    "            maxLines: 3,\n"
    "            overflow: TextOverflow.ellipsis,\n"
    "            style: TextStyle(\n"
    "              fontSize: (sw * 0.065).clamp(20.0, 28.0),",
    "          SizedBox(height: isSmall ? 10 : 14),\n"
    "\n"
    "          Text(\n"
    "            p.name,\n"
    "            maxLines: 3,\n"
    "            overflow: TextOverflow.ellipsis,\n"
    "            style: TextStyle(\n"
    "              fontSize: (sw * 0.065).clamp(18.0, 28.0),",
))

# Fix 1d: name->price, price->social, social->divider gaps
fixes.append((
    "          const SizedBox(height: 18),\n"
    "\n"
    "          // \u2500\u2500 Price block \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          _buildPriceBlock(p.price, p.originalPrice, hasDiscount, discountPct),\n"
    "\n"
    "          const SizedBox(height: 16),\n"
    "\n"
    "          // \u2500\u2500 Rating + social proof row \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          _buildSocialRow(p.soldCount),\n"
    "\n"
    "          const SizedBox(height: 24),\n"
    "          _divider(),\n"
    "          const SizedBox(height: 20),\n"
    "\n"
    "          // \u2500\u2500 Size selector \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n",
    "          SizedBox(height: isSmall ? 12 : 18),\n"
    "\n"
    "          _buildPriceBlock(p.price, p.originalPrice, hasDiscount, discountPct),\n"
    "\n"
    "          SizedBox(height: isSmall ? 12 : 16),\n"
    "\n"
    "          _buildSocialRow(p.soldCount),\n"
    "\n"
    "          SizedBox(height: isSmall ? 16 : 24),\n"
    "          _divider(),\n"
    "          SizedBox(height: vs),\n"
    "\n",
))

# Fix 1e: size selector label fonts
fixes.append((
    "                const Text('Select Size',\n"
    "                    style: TextStyle(\n"
    "                        fontSize: 15,\n"
    "                        fontWeight: FontWeight.w600,\n"
    "                        fontFamily: 'Poppins',\n"
    "                        color: Color(0xFF111111))),\n"
    "                const Spacer(),\n"
    "                GestureDetector(\n"
    "                  onTap: () {},\n"
    "                  child: const Text('Size Guide \u2192',\n"
    "                      style: TextStyle(\n"
    "                          fontSize: 13,\n"
    "                          color: Color(0xFF757575),\n"
    "                          fontFamily: 'Poppins')),\n"
    "                ),\n",
    "                Text('Select Size',\n"
    "                    style: TextStyle(\n"
    "                        fontSize: isSmall ? 13.0 : 15.0,\n"
    "                        fontWeight: FontWeight.w600,\n"
    "                        fontFamily: 'Poppins',\n"
    "                        color: const Color(0xFF111111))),\n"
    "                const Spacer(),\n"
    "                GestureDetector(\n"
    "                  onTap: () {},\n"
    "                  child: Text('Size Guide \u2192',\n"
    "                      style: TextStyle(\n"
    "                          fontSize: isSmall ? 11.0 : 13.0,\n"
    "                          color: const Color(0xFF757575),\n"
    "                          fontFamily: 'Poppins')),\n"
    "                ),\n",
))

# Fix 1f: size chip gap + wrap spacing
fixes.append((
    "            const SizedBox(height: 12),\n"
    "            Wrap(\n"
    "              spacing: 10,\n"
    "              runSpacing: 10,\n",
    "            SizedBox(height: isSmall ? 8 : 12),\n"
    "            Wrap(\n"
    "              spacing: isSmall ? 8 : 10,\n"
    "              runSpacing: isSmall ? 8 : 10,\n",
))

# Fix 1g: size chip padding
fixes.append((
    "                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),\n",
    "                    padding: EdgeInsets.symmetric(\n"
    "                      horizontal: isSmall ? 16 : 22,\n"
    "                      vertical: isSmall ? 9 : 12,\n"
    "                    ),\n",
))

# Fix 1h: size chip font
fixes.append((
    "                        fontSize: 14,\n"
    "                        fontWeight: FontWeight.w600,\n"
    "                        fontFamily: 'Poppins',\n"
    "                        color: selected ? Colors.white : const Color(0xFF424242),\n",
    "                        fontSize: isSmall ? 12.0 : 14.0,\n"
    "                        fontWeight: FontWeight.w600,\n"
    "                        fontFamily: 'Poppins',\n"
    "                        color: selected ? Colors.white : const Color(0xFF424242),\n",
))

# Fix 1i: section gaps after size selector through related products
fixes.append((
    "            const SizedBox(height: 20),\n"
    "            _divider(),\n"
    "            const SizedBox(height: 20),\n"
    "          ],\n"
    "\n"
    "          // \u2500\u2500 Accordion sections \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          _buildAccordionBlock(p.description, p.category),\n"
    "\n"
    "          const SizedBox(height: 20),\n"
    "          _divider(),\n"
    "          const SizedBox(height: 20),\n"
    "\n"
    "          // \u2500\u2500 Product features \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          _buildFeaturesSection(p.category),\n"
    "\n"
    "          const SizedBox(height: 20),\n"
    "          _divider(),\n"
    "          const SizedBox(height: 20),\n"
    "\n"
    "          // \u2500\u2500 Delivery & Offers card \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          _buildDeliverySection(widget.product.stock),\n"
    "\n"
    "          const SizedBox(height: 20),\n"
    "          _divider(),\n"
    "          const SizedBox(height: 20),\n"
    "\n"
    "          // \u2500\u2500 Customer reviews \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          _buildReviewsSection(),\n"
    "\n"
    "          const SizedBox(height: 20),\n"
    "          _divider(),\n"
    "          const SizedBox(height: 20),\n"
    "\n"
    "          // \u2500\u2500 Related products \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n"
    "          _buildRelatedProductsBlock(),\n",
    "            SizedBox(height: vs),\n"
    "            _divider(),\n"
    "            SizedBox(height: vs),\n"
    "          ],\n"
    "\n"
    "          _buildAccordionBlock(p.description, p.category),\n"
    "\n"
    "          SizedBox(height: vs),\n"
    "          _divider(),\n"
    "          SizedBox(height: vs),\n"
    "\n"
    "          _buildFeaturesSection(p.category),\n"
    "\n"
    "          SizedBox(height: vs),\n"
    "          _divider(),\n"
    "          SizedBox(height: vs),\n"
    "\n"
    "          _buildDeliverySection(widget.product.stock),\n"
    "\n"
    "          SizedBox(height: vs),\n"
    "          _divider(),\n"
    "          SizedBox(height: vs),\n"
    "\n"
    "          _buildReviewsSection(),\n"
    "\n"
    "          SizedBox(height: vs),\n"
    "          _divider(),\n"
    "          SizedBox(height: vs),\n"
    "\n"
    "          _buildRelatedProductsBlock(),\n",
))

# Fix 2a: remove unused btnGap
fixes.append((
    "    final btnGap    = isSmall ? 6.0 : 8.0;\n",
    "",
))

# Fix 2b: adaptive gap + wire onTap on Buy Now
fixes.append((
    "            const SizedBox(height: 8),\n"
    "            GestureDetector(\n"
    "              child: AnimatedContainer(\n",
    "            SizedBox(height: isSmall ? 6 : 8),\n"
    "            GestureDetector(\n"
    "              onTap: inStock ? _onBuyNow : null,\n"
    "              child: AnimatedContainer(\n",
))

# Fix 3: accordion body padding
fixes.append((
    "                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),\n",
    "                  padding: EdgeInsets.fromLTRB(Responsive.hPadding(context), 14, Responsive.hPadding(context), 16),\n",
))

results = []
for old, new in fixes:
    if old in src:
        src = src.replace(old, new, 1)
        results.append('OK')
    else:
        results.append('NOT FOUND: ' + repr(old[:80]))

with open(path, 'w', encoding='utf-8') as f:
    f.write(src)

for r in results:
    print(r)

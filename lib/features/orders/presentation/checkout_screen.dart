import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final shippingAddressCtrl = TextEditingController();
  final shippingCityCtrl = TextEditingController();
  final shippingDistrictCtrl = TextEditingController();
  final shippingPostalCtrl = TextEditingController();

  final billingAddressCtrl = TextEditingController();
  final billingCityCtrl = TextEditingController();
  final billingDistrictCtrl = TextEditingController();
  final billingPostalCtrl = TextEditingController();

  final notesCtrl = TextEditingController();

  bool sameAsShipping = false;
  String paymentMethod = "cod";

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    shippingAddressCtrl.dispose();
    shippingCityCtrl.dispose();
    shippingDistrictCtrl.dispose();
    shippingPostalCtrl.dispose();
    billingAddressCtrl.dispose();
    billingCityCtrl.dispose();
    billingDistrictCtrl.dispose();
    billingPostalCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  double _getFinalPrice(Map<String, dynamic> product) {
    final double price = double.tryParse(product["price"].toString()) ?? 0.0;
    final double discount = double.tryParse(product["discount"].toString()) ?? 0.0;

    if (discount > 0) {
      if (discount < 100) {
        return price - (price * discount / 100);
      } else {
        return price - discount;
      }
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authState = ref.watch(authStateProvider).value;
    final email = authState?["user"]?["email"] ?? "";
    emailCtrl.text = email;

    final cartItems = ref.watch(userCartProvider);

    final double subtotal = cartItems.fold<double>(0.0, (sum, item) {
      final finalPrice = _getFinalPrice(item.product);
      return sum + (finalPrice * item.quantity);
    });

    const double shipping = 350.0;
    const double tax = 100.0;
    final double total = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF3A3A3A), const Color(0xFF2C2C2C)]
                  : [const Color(0xFFE9AFB1), const Color(0xFFEACCCF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section("Personal Information", isDark),
              _row2(
                _field("Full Name", nameCtrl, required: true, isDark: isDark),
                _field("Email", emailCtrl, readOnly: true, isDark: isDark),
              ),
              _field("Phone Number", phoneCtrl,
                  keyboard: TextInputType.phone, required: true, isDark: isDark),
              const SizedBox(height: 16),

              _section("Shipping Address", isDark),
              _field("Address", shippingAddressCtrl, required: true, isDark: isDark),
              _row2(
                _field("City", shippingCityCtrl, required: true, isDark: isDark),
                _field("District", shippingDistrictCtrl, required: true, isDark: isDark),
              ),
              _field("Postal Code", shippingPostalCtrl,
                  keyboard: TextInputType.number, required: true, isDark: isDark),
              const SizedBox(height: 16),

              _section("Payment Method", isDark),
              Row(
                children: [
                  Radio<String>(
                    value: "cod",
                    groupValue: paymentMethod,
                    onChanged: (v) => setState(() => paymentMethod = v!),
                    activeColor: const Color(0xFFA4161A),
                  ),
                  Text("Cash on Delivery",
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: "card",
                    groupValue: paymentMethod,
                    onChanged: (v) => setState(() => paymentMethod = v!),
                    activeColor: const Color(0xFFA4161A),
                  ),
                  Text("Card Payment",
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                ],
              ),
              const SizedBox(height: 16),

              _section("Billing Address", isDark),
              CheckboxListTile(
                value: sameAsShipping,
                onChanged: (v) {
                  setState(() => sameAsShipping = v ?? false);
                  if (v == true) {
                    billingAddressCtrl.text = shippingAddressCtrl.text;
                    billingCityCtrl.text = shippingCityCtrl.text;
                    billingDistrictCtrl.text = shippingDistrictCtrl.text;
                    billingPostalCtrl.text = shippingPostalCtrl.text;
                  } else {
                    billingAddressCtrl.clear();
                    billingCityCtrl.clear();
                    billingDistrictCtrl.clear();
                    billingPostalCtrl.clear();
                  }
                },
                title: Text(
                  "Same as Shipping Address",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFA4161A),
              ),
              _field("Address", billingAddressCtrl, isDark: isDark),
              _row2(
                _field("City", billingCityCtrl, isDark: isDark),
                _field("District", billingDistrictCtrl, isDark: isDark),
              ),
              _field("Postal Code", billingPostalCtrl,
                  keyboard: TextInputType.number, isDark: isDark),
              const SizedBox(height: 16),

              _section("Additional Requirements", isDark),
              _field("Notes", notesCtrl, maxLines: 3, isDark: isDark),
              const SizedBox(height: 16),

              _section("Order Summary", isDark),
              Card(
                color: isDark ? Colors.grey[900] : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: isDark ? 0 : 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      _summaryRow("Subtotal", subtotal, isDark: isDark),
                      _summaryRow("Shipping", shipping, isDark: isDark),
                      _summaryRow("Tax", tax, isDark: isDark),
                      const Divider(),
                      _summaryRow("Total", total,
                          bold: true,
                          color: const Color(0xFFA4161A),
                          isDark: isDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final items = cartItems.map((i) {
                      final finalPrice = _getFinalPrice(i.product);
                      return {
                        "id": i.product["id"] ?? i.product["_id"],
                        "name": i.product["name"],
                        "price": finalPrice,
                        "quantity": i.quantity,
                      };
                    }).toList();

                    final orderData = {
                      "name": nameCtrl.text,
                      "email": emailCtrl.text,
                      "phone": phoneCtrl.text,
                      "shipping_address": shippingAddressCtrl.text,
                      "shipping_city": shippingCityCtrl.text,
                      "shipping_district": shippingDistrictCtrl.text,
                      "shipping_postal": shippingPostalCtrl.text,
                      "billing_address": billingAddressCtrl.text,
                      "billing_city": billingCityCtrl.text,
                      "billing_district": billingDistrictCtrl.text,
                      "billing_postal": billingPostalCtrl.text,
                      "payment_method": paymentMethod,
                      "notes": notesCtrl.text,
                      "items": items,
                      "subtotal": subtotal,
                      "shipping": shipping,
                      "tax": tax,
                      "total": total,
                    };

                    try {
                      await ref.read(placeOrderProvider(orderData).future);

                      ref.read(cartProvider.notifier).clearUserCart(email);
                      ref.invalidate(orderProvider(email));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("✅ Order placed successfully")),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ Failed to place order: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4161A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Place Order",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, bool isDark) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black)),
      );

  Widget _row2(Widget left, Widget right) => Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 10),
          Expanded(child: right),
        ],
      );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    bool isDark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? "Required" : null
            : null,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: isDark ? Colors.white24 : Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color(0xFFA4161A), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value,
      {bool bold = false, Color? color, bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87)),
          Text("Rs.${value.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: color ??
                      (isDark ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }
}

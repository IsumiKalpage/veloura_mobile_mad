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
    final double price =
        double.tryParse(product["price"].toString()) ?? 0.0;
    final double discount =
        double.tryParse(product["discount"].toString()) ?? 0.0;

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
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE9AFB1), Color(0xFFEACCCF)],
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
              _section("Personal Information"),
              _row2(
                _field("Full Name", nameCtrl, required: true),
                _field("Email", emailCtrl, readOnly: true),
              ),
              _field("Phone Number", phoneCtrl,
                  keyboard: TextInputType.phone, required: true),
              const SizedBox(height: 16),

              _section("Shipping Address"),
              _field("Address", shippingAddressCtrl, required: true),
              _row2(
                _field("City", shippingCityCtrl, required: true),
                _field("District", shippingDistrictCtrl, required: true),
              ),
              _field("Postal Code", shippingPostalCtrl,
                  keyboard: TextInputType.number, required: true),
              const SizedBox(height: 16),

              _section("Payment Method"),
              Row(
                children: [
                  Radio<String>(
                    value: "cod",
                    groupValue: paymentMethod,
                    onChanged: (v) => setState(() => paymentMethod = v!),
                  ),
                  const Text("Cash on Delivery"),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: "card",
                    groupValue: paymentMethod,
                    onChanged: (v) => setState(() => paymentMethod = v!),
                  ),
                  const Text("Card Payment"),
                ],
              ),
              const SizedBox(height: 16),

              _section("Billing Address"),
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
                title: const Text("Same as Shipping Address"),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              _field("Address", billingAddressCtrl),
              _row2(
                _field("City", billingCityCtrl),
                _field("District", billingDistrictCtrl),
              ),
              _field("Postal Code", billingPostalCtrl,
                  keyboard: TextInputType.number),
              const SizedBox(height: 16),

              _section("Additional Requirements"),
              _field("Notes", notesCtrl, maxLines: 3),
              const SizedBox(height: 16),

              _section("Order Summary"),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      _summaryRow("Subtotal", subtotal),
                      _summaryRow("Shipping", shipping),
                      _summaryRow("Tax", tax),
                      const Divider(),
                      _summaryRow("Total", total,
                          bold: true, color: const Color(0xFFA4161A)),
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

                      // ✅ Clear cart after order success
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

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
          Text("Rs.${value.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}

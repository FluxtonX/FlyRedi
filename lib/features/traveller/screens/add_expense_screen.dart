import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String _selectedCategory = '';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _receiptUploaded = false;

  bool get _isFormValid {
    return _selectedCategory.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _amountController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expenses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel('Category'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCategoryChip('Food')),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryChip('Transport')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCategoryChip('Accommodation')),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryChip('Other')),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('Description'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              hint: 'e.g., Airport meal',
            ),
            const SizedBox(height: 24),

            _buildLabel('Amount'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _amountController,
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),

            _buildLabel('Receipt (Optional)'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _receiptUploaded = !_receiptUploaded;
                });
              },
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C162A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _receiptUploaded
                        ? const Color(0xFFFFC229).withOpacity(0.5) // Yellow dashed-like border
                        : Colors.white.withOpacity(0.08),
                    style: BorderStyle.solid,
                  ),
                ),
                alignment: Alignment.center,
                child: _receiptUploaded
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: Color(0xFFFFC229), size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Receipt uploaded',
                            style: TextStyle(
                              color: const Color(0xFFFFC229).withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_outlined, color: Colors.white.withOpacity(0.4), size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to upload receipt',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Add Expense Button
            GestureDetector(
              onTap: _isFormValid
                  ? () {
                      Navigator.pop(context);
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _isFormValid
                      ? const Color(0xFFFFC229)
                      : const Color(0xFFFFC229).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isFormValid
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFC229).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Add Expense',
                  style: TextStyle(
                     color: _isFormValid ? Colors.black : Colors.black.withOpacity(0.5),
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 2), // Resolution tab
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFC229) : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

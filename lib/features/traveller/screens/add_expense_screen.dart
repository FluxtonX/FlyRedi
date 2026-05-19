import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/expenses_header.dart';
import '../widgets/expense_category_selector.dart';
import '../widgets/expense_text_field.dart';
import '../widgets/receipt_upload_area.dart';
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
  bool _isReceiptUploaded = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update state when text changes to enable/disable button
    _descriptionController.addListener(_updateState);
    _amountController.addListener(_updateState);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {}); // Trigger rebuild to update button color
  }

  bool get _isFormValid {
    return _selectedCategory.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _amountController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ExpensesHeader(showAddIcon: false),
                      const SizedBox(height: 32),
                      
                      ExpenseCategorySelector(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      ExpenseTextField(
                        label: 'Description',
                        hintText: 'e.g., Airport meal',
                        controller: _descriptionController,
                      ),
                      const SizedBox(height: 24),
                      
                      ExpenseTextField(
                        label: 'Amount',
                        hintText: '0.00',
                        controller: _amountController,
                      ),
                      const SizedBox(height: 32),
                      
                      ReceiptUploadArea(
                        isUploaded: _isReceiptUploaded,
                        onTap: () {
                          setState(() {
                            _isReceiptUploaded = !_isReceiptUploaded; // Toggle for demo purposes
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _isFormValid ? const Color(0xFFFFC229) : const Color(0xFF8B6B22), // Bright yellow if valid, dark brown if not
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Add Expense',
                  style: TextStyle(
                    color: _isFormValid ? Colors.black : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(),
    );
  }
}

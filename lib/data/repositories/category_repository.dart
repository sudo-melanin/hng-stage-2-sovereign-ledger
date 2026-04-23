import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:sovereign_ledger/core/constants/hive_boxes.dart';
import 'package:sovereign_ledger/core/enums/category_type.dart';
import 'package:sovereign_ledger/data/models/category_model.dart';

/// Handles all category-related storage operations.
/// Keeps Hive access out of the UI and provider layers.
class CategoryRepository {
  final Box<CategoryModel> _categoryBox =
      Hive.box<CategoryModel>(HiveBoxes.categories);

  final Uuid _uuid = const Uuid();

  /// Returns every stored category.
  List<CategoryModel> getAllCategories() {
    return _categoryBox.values.toList();
  }

  /// Returns categories that match the requested type.
  /// Shared categories marked as "both" are also included.
  List<CategoryModel> getCategoriesByType(CategoryType type) {
    return _categoryBox.values.where((category) {
      return category.categoryType == type ||
          category.categoryType == CategoryType.both;
    }).toList();
  }

  /// Adds a single category to local storage.
  Future<void> addCategory({
    required String name,
    required int colorValue,
    required String iconKey,
    required CategoryType categoryType,
  }) async {
    final category = CategoryModel(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      iconKey: iconKey,
      categoryType: categoryType,
    );

    await _categoryBox.put(category.id, category);
  }

  /// Seeds default categories on first launch only.
  /// This prevents the app from starting with an empty category state.
  Future<void> seedDefaultCategories() async {
    if (_categoryBox.isNotEmpty) return;

    final defaultCategories = [
      CategoryModel(
        id: _uuid.v4(),
        name: 'Food',
        colorValue: 0xFFFF7043,
        iconKey: 'restaurant',
        categoryType: CategoryType.expense,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Transport',
        colorValue: 0xFF42A5F5,
        iconKey: 'directions_car',
        categoryType: CategoryType.expense,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Groceries',
        colorValue: 0xFF66BB6A,
        iconKey: 'shopping_cart',
        categoryType: CategoryType.expense,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Utilities',
        colorValue: 0xFFAB47BC,
        iconKey: 'bolt',
        categoryType: CategoryType.expense,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Shopping',
        colorValue: 0xFFEC407A,
        iconKey: 'shopping_bag',
        categoryType: CategoryType.expense,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Entertainment',
        colorValue: 0xFFFFCA28,
        iconKey: 'movie',
        categoryType: CategoryType.expense,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Housing',
        colorValue: 0xFF8D6E63,
        iconKey: 'home',
        categoryType: CategoryType.expense,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Salary',
        colorValue: 0xFF26A69A,
        iconKey: 'payments',
        categoryType: CategoryType.income,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Freelance',
        colorValue: 0xFF5C6BC0,
        iconKey: 'work',
        categoryType: CategoryType.income,
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Gift',
        colorValue: 0xFFFFA726,
        iconKey: 'card_giftcard',
        categoryType: CategoryType.income,
      ),
    ];

    for (final category in defaultCategories) {
      await _categoryBox.put(category.id, category);
    }
  }
}
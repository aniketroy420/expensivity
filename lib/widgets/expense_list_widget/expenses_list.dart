import 'package:flutter/material.dart';
import 'package:expensivity_u/widgets/expense_list_widget/expense_item.dart';
import 'package:expensivity_u/models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) => Dismissible(
        background: Container(
          //color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          margin: EdgeInsets.symmetric(
              horizontal: Theme.of(context).cardTheme.margin!.horizontal),
          child: const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 24, 8, 24),
              child: Icon(
                Icons.delete,
                size: 40,
                color: Color.fromARGB(255, 202, 82, 82),
              ),
            ),
          ),
        ),
        key: ValueKey(expenses[index]),
        onDismissed: (direction) {
          onRemoveExpense(expenses[index]);
        },
        child: ExpenseItem(expenses[index]),
      ),
    );
  }
}

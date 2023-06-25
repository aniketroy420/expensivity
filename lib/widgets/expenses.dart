import 'dart:convert';

import 'package:expensivity_u/widgets/chart/chart.dart';
import 'package:expensivity_u/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:expensivity_u/widgets/expense_list_widget/expenses_list.dart';
import 'package:expensivity_u/models/expense.dart';
import 'package:http/http.dart' as http;

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems();
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    final url = Uri.https('expensivity-9664b-default-rtdb.firebaseio.com', 'expense-list/${expense.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Optional: Show error message
      setState(() {
        _registeredExpenses.insert(expenseIndex, expense);
      });
    }





    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: const Duration(seconds: 5),
          content: const Text('Expense deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _registeredExpenses.insert(expenseIndex, expense);
              });
            },
          )),
    );
//Create a dedicated permanent undo button
  }

  void loadItems() async {
    final url = Uri.https(
        'expensivity-9664b-default-rtdb.firebaseio.com', 'expense-list.json');
    final response = await http.get(url);
    final Map<dynamic, dynamic> listData = json.decode(response.body);

    final List<Expense> expenseList = [];
    for (final item in listData.entries) {
      expenseList.add(
        Expense(id: item.key,
          title: item.value['title'],
          amount: double.parse(item.value['amount']
              .toString()), //12.0,//double.parse(item.value['amount']),
          date: DateTime.parse(item.value['date']),
          category: Category.values
              .firstWhere((element) => element.name == item.value['category']),
        ),
      );

    }

    setState(() {
      _registeredExpenses = expenseList;

    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Column(
        children:[

             Text("Waiting for your Expenses"),

          SizedBox(height: 16),
          CircularProgressIndicator(),
        ] ,
      ),
    );



    if (_registeredExpenses.isNotEmpty) {

      mainContent = ExpensesList(
          expenses: _registeredExpenses, onRemoveExpense: _removeExpense);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Expensivity: Expense Tracker'),
          actions: [
            IconButton(
              onPressed: _openAddExpenseOverlay,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: width < 600
            ? Column(
                children: [
                  Chart(expenses: _registeredExpenses),
                  Expanded(
                    child: mainContent,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: Chart(expenses: _registeredExpenses)),
                  Expanded(
                    child: mainContent,
                  ),
                ],
              ));
  }
}

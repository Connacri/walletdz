import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyTransferPage extends StatefulWidget {
  final String fromAccount; // Compte d'origine
  final String toAccount; // Compte de destination

  const MoneyTransferPage(
      {Key? key, required this.fromAccount, required this.toAccount})
      : super(key: key);

  @override
  _MoneyTransferPageState createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _transferMoney(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final fromDocRef = FirebaseFirestore.instance
            .collection('accounts')
            .doc(widget.fromAccount);
        final toDocRef = FirebaseFirestore.instance
            .collection('accounts')
            .doc(widget.toAccount);

        final fromDocSnapshot = await transaction.get(fromDocRef);
        final toDocSnapshot = await transaction.get(toDocRef);

        if (!fromDocSnapshot.exists || !toDocSnapshot.exists) {
          throw Exception("Un ou plusieurs comptes n'existent pas.");
        }

        final fromBalance = fromDocSnapshot['balance'];
        final toBalance = toDocSnapshot['balance'];

        if (fromBalance < amount) {
          throw Exception("Solde insuffisant sur le compte d'origine.");
        }

        transaction.update(fromDocRef, {'balance': fromBalance - amount});
        transaction.update(toDocRef, {'balance': toBalance + amount});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Transféré $amount € à ${widget.toAccount}"),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfert d'argent"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transfert de ${widget.fromAccount} à ${widget.toAccount}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Montant à transférer",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un montant";
                  }
                  final parsedValue = double.tryParse(value);
                  if (parsedValue == null || parsedValue <= 0) {
                    return "Veuillez entrer un montant valide";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _transferMoney(context),
                  child: Text("Confirmer le transfert"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

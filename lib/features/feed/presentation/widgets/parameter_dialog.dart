import 'package:flutter/material.dart';

class ParameterDialog extends StatelessWidget {
  final List<String> missingParams;

  const ParameterDialog({super.key, required this.missingParams});

  @override
  Widget build(BuildContext context) {
    final controllers = <String, TextEditingController>{};
    final formKey = GlobalKey<FormState>();

    for (var param in missingParams) {
      controllers[param] = TextEditingController();
    }

    return AlertDialog(
      title: const Text('Enter Missing Parameters'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: missingParams.map((param) {
            return TextFormField(
              controller: controllers[param],
              decoration: InputDecoration(
                labelText: param,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field cannot be empty';
                }
                return null;
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final parameters = {
                for (var param in missingParams) param: controllers[param]!.text
              };
              Navigator.of(context).pop(parameters);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

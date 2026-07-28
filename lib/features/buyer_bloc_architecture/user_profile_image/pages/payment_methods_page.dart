import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../PaymentMethodsPage/PaymentMethods_Bloc.dart';
import '../../PaymentMethodsPage/PaymentMethods_Event.dart';
import '../../PaymentMethodsPage/PaymentMethods_UI.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentMethodsBloc(PaymentMethodsRepository())
        ..add(LoadPaymentMethods()),
      child: const PaymentMethodsUI(),
    );
  }
}

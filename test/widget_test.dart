import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesi_ira/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sesi_ira/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('login flow shows role selector then admin form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('Selamat datang di Sesi Ira'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Psikolog'), findsOneWidget);

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Login sebagai Admin'), findsOneWidget);
    expect(find.text('Email Admin'), findsOneWidget);
    expect(find.text('Masuk sebagai Admin'), findsOneWidget);
  });
}

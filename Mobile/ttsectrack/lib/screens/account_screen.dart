import 'package:flutter/material.dart';
import 'package:ttsectrack/repositories/account_repository.dart';
import 'package:ttsectrack/screens/register_screen.dart';
import 'package:ttsectrack/screens/landing_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ttsectrack/services/account_service.dart';
import 'package:sqflite/sqflite.dart';
import '../blocs/account_bloc.dart';
import '../blocs/account_event.dart';
import '../blocs/account_state.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<Database> _getDb() async {
    return openDatabase(
      'app.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT,
            profileImage TEXT
          )
        ''');
      },
    );
  }

  void _login(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    BlocProvider.of<AccountBloc>(context).add(
      LoginEvent(_emailController.text.trim(), _passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Database>(
      future: _getDb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final db = snapshot.data!;
        return BlocProvider(
          create: (context) => AccountBloc(AccountService(AccountRepository(db))),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Account Login'),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocConsumer<AccountBloc, AccountState>(
                    listener: (context, state) async {
                      if (state is AccountLoginSuccess) {
                        Future.delayed(const Duration(seconds: 2), () {
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LandingScreen(),
                              ),
                            );
                          }
                        });
                      }
                    },
                    builder: (context, state) {
                  bool isLoading = state is AccountLoading;
                  String? errorMessage;
                  if (state is AccountLoginFailure) errorMessage = state.error;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: (state is AccountLoginSuccess)
                        ? AnimatedContainer(
                            key: const ValueKey('login_success'),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            height: 220,
                            width: 340,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.green.shade100, blurRadius: 12)],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle, color: Colors.green, size: 48),
                                SizedBox(height: 16),
                                Text('Login Successful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : Card(
                            key: const ValueKey('login_form'),
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundImage: const AssetImage('lib/assets/images/MobitraLogo.png'),
                                            backgroundColor: Colors.white,
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.person, color: Colors.blueAccent, size: 32),
                                              SizedBox(width: 12),
                                              Text('Sign In', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    if (errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.error_outline, color: Colors.red, size: 20),
                                            SizedBox(width: 8),
                                          ],
                                        ),
                                      ),
                                    if (errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text(
                                          errorMessage,
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.login, color: Colors.white),
                                        onPressed: isLoading ? null : () => _login(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        label: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                            : const Text('Login', style: TextStyle(fontSize: 18)),
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    Center(
                                      child: TextButton(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text("Don't have an account? ", style: TextStyle(color: Colors.black87)),
                                            Text('Register', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    );
                },
              ),
            ),
          ),
        ),
      ),
    );
            },
          );
        }
      }

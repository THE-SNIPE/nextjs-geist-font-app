import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum AuthMode { Login, Register }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;

  String _email = '';
  String _password = '';
  String _name = '';
  String _phone = '';
  String _location = '';
  String _role = 'Farmer';

  bool _isLoading = false;
  String? _errorMessage;

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.Login ? AuthMode.Register : AuthMode.Login;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      if (_authMode == AuthMode.Login) {
        await authService.signInWithEmailAndPassword(_email, _password);
      } else {
        final user = await authService.createUserWithEmailAndPassword(_email, _password);
        if (user != null) {
          // Save additional user info (name, phone, location, role) to Firestore
          final firestoreService = FirestoreService();
          await firestoreService.createUserProfile(
            uid: user.uid,
            name: _name,
            email: _email,
            phone: _phone,
            location: _location,
            role: _role,
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VetJirani - ${_authMode == AuthMode.Login ? 'Login' : 'Register'}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_authMode == AuthMode.Register)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onSaved: (value) => _name = value?.trim() ?? '',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value?.trim() ?? '',
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => _password = value ?? '',
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (_authMode == AuthMode.Register) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _phone = value?.trim() ?? '',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  onSaved: (value) => _location = value?.trim() ?? '',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: ['Farmer', 'Vet'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _role = value ?? 'Farmer';
                    });
                  },
                ),
              ],
              SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_authMode == AuthMode.Login ? 'Login' : 'Register'),
                ),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(_authMode == AuthMode.Login
                    ? 'Create new account'
                    : 'I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

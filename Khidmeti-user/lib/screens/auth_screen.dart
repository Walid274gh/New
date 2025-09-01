import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isEmailMode = false;
  bool _isSignUp = false;
  bool _isPasswordVisible = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final phoneNumber = '+213${_phoneController.text}';
      
      final success = await authService.signInWithPhone(phoneNumber);
      if (success) {
        setState(() {
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code de vérification envoyé'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Erreur lors de l\'envoi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length == 6) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.verifyOTP(_verificationId!, _otpController.text);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Code incorrect'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signInWithGoogle();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion Google réussie'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      if (authService.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Erreur lors de la connexion'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _signUpWithEmail() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _displayNameController.text.trim(),
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Erreur lors de l\'inscription'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre email'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.resetPassword(_emailController.text.trim());
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de réinitialisation envoyé'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? 'Erreur lors de l\'envoi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _toggleEmailMode() {
    setState(() {
      _isEmailMode = !_isEmailMode;
      _isSignUp = false;
      _isOtpSent = false;
      _emailController.clear();
      _passwordController.clear();
      _displayNameController.clear();
    });
  }
  
  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.work,
                      size: 50,
                      color: AppColors.primaryEnd,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Bienvenue sur Khidmeti',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Connectez-vous pour continuer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Toggle Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isEmailMode ? null : () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEmailMode ? Colors.white.withOpacity(0.2) : Colors.white,
                            foregroundColor: _isEmailMode ? Colors.white70 : AppColors.primaryEnd,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Téléphone',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isEmailMode ? () {} : _toggleEmailMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEmailMode ? Colors.white : Colors.white.withOpacity(0.2),
                            foregroundColor: _isEmailMode ? AppColors.primaryEnd : Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),

                  // Phone Number Input
                  if (!_isEmailMode && !_isOtpSent) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '+213',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Numéro de téléphone',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColors.textLight),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre numéro';
                                }
                                if (value.length < 9) {
                                  return 'Numéro invalide';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return ElevatedButton(
                            onPressed: authService.isLoading ? null : _sendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryEnd,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: authService.isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Envoyer le code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    
                    // Divider
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Google Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return OutlinedButton.icon(
                            onPressed: authService.isLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: Colors.white, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Image.network(
                              'https://developers.google.com/identity/images/g-logo.png',
                              height: 20,
                              width: 20,
                            ),
                            label: authService.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'Continuer avec Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],

                  // OTP Input
                  if (_isOtpSent) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          hintText: 'Code de vérification',
                          border: InputBorder.none,
                          counterText: '',
                          hintStyle: TextStyle(color: AppColors.textLight),
                        ),
                        onChanged: (value) {
                          if (value.length == 6) {
                            _verifyOTP();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return ElevatedButton(
                            onPressed: authService.isLoading ? null : _verifyOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryEnd,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: authService.isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Vérifier',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isOtpSent = false;
                          _otpController.clear();
                        });
                      },
                      child: const Text(
                        'Changer de numéro',
                        style: TextStyle(color: Colors.white70),
                      ),
                                         ),
                   ],
                   
                   // Email Authentication
                   if (_isEmailMode) ...[
                     // Display Name Input (for sign up)
                     if (_isSignUp) ...[
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 16),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.1),
                               blurRadius: 10,
                               offset: const Offset(0, 5),
                             ),
                           ],
                         ),
                         child: TextFormField(
                           controller: _displayNameController,
                           decoration: const InputDecoration(
                             hintText: 'Nom complet',
                             border: InputBorder.none,
                             hintStyle: TextStyle(color: AppColors.textLight),
                             icon: Icon(Icons.person, color: AppColors.textLight),
                           ),
                           validator: (value) {
                             if (_isSignUp && (value == null || value.isEmpty)) {
                               return 'Veuillez entrer votre nom';
                             }
                             return null;
                           },
                         ),
                       ),
                       const SizedBox(height: 16),
                     ],
                     
                     // Email Input
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 10,
                             offset: const Offset(0, 5),
                           ),
                         ],
                       ),
                       child: TextFormField(
                         controller: _emailController,
                         keyboardType: TextInputType.emailAddress,
                         decoration: const InputDecoration(
                           hintText: 'Adresse email',
                           border: InputBorder.none,
                           hintStyle: TextStyle(color: AppColors.textLight),
                           icon: Icon(Icons.email, color: AppColors.textLight),
                         ),
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return 'Veuillez entrer votre email';
                           }
                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                             return 'Email invalide';
                           }
                           return null;
                         },
                       ),
                     ),
                     const SizedBox(height: 16),
                     
                     // Password Input
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 10,
                             offset: const Offset(0, 5),
                           ),
                         ],
                       ),
                       child: TextFormField(
                         controller: _passwordController,
                         obscureText: !_isPasswordVisible,
                         decoration: InputDecoration(
                           hintText: 'Mot de passe',
                           border: InputBorder.none,
                           hintStyle: const TextStyle(color: AppColors.textLight),
                           icon: const Icon(Icons.lock, color: AppColors.textLight),
                           suffixIcon: IconButton(
                             icon: Icon(
                               _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                               color: AppColors.textLight,
                             ),
                             onPressed: () {
                               setState(() {
                                 _isPasswordVisible = !_isPasswordVisible;
                               });
                             },
                           ),
                         ),
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return 'Veuillez entrer votre mot de passe';
                           }
                           if (_isSignUp && value.length < 6) {
                             return 'Le mot de passe doit contenir au moins 6 caractères';
                           }
                           return null;
                         },
                       ),
                     ),
                     const SizedBox(height: 24),
                     
                     // Action Buttons
                     Row(
                       children: [
                         Expanded(
                           child: SizedBox(
                             height: 50,
                             child: Consumer<AuthService>(
                               builder: (context, authService, child) {
                                 return ElevatedButton(
                                   onPressed: authService.isLoading ? null : (_isSignUp ? _signUpWithEmail : _signInWithEmail),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: Colors.white,
                                     foregroundColor: AppColors.primaryEnd,
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(12),
                                     ),
                                     elevation: 0,
                                   ),
                                   child: authService.isLoading
                                       ? const SizedBox(
                                           height: 20,
                                           width: 20,
                                           child: CircularProgressIndicator(strokeWidth: 2),
                                         )
                                       : Text(
                                           _isSignUp ? 'S\'inscrire' : 'Se connecter',
                                           style: const TextStyle(
                                             fontSize: 16,
                                             fontWeight: FontWeight.w600,
                                           ),
                                         ),
                                 );
                               },
                             ),
                           ),
                         ),
                         const SizedBox(width: 12),
                         SizedBox(
                           height: 50,
                           child: OutlinedButton(
                             onPressed: _toggleSignUp,
                             style: OutlinedButton.styleFrom(
                               backgroundColor: Colors.transparent,
                               foregroundColor: Colors.white,
                               side: const BorderSide(color: Colors.white, width: 1),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                             ),
                             child: Text(
                               _isSignUp ? 'Déjà inscrit ?' : 'Nouveau compte ?',
                               style: const TextStyle(
                                 fontSize: 14,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                     
                     // Forgot Password
                     if (!_isSignUp) ...[
                       const SizedBox(height: 16),
                       TextButton(
                         onPressed: _resetPassword,
                         child: const Text(
                           'Mot de passe oublié ?',
                           style: TextStyle(color: Colors.white70),
                         ),
                       ),
                     ],
                   ],
                 ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
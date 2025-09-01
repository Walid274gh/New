import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
  
  Future<bool> signInWithPhone(String phoneNumber) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _errorMessage = e.message;
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId for later use
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _errorMessage = 'Code de vérification expiré';
          _isLoading = false;
          notifyListeners();
        },
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        // Create or update user document
        await _createUserDocument(result.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> _createUserDocument(User user) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);
      DocumentSnapshot userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        // Créer un nouveau document utilisateur
        Map<String, dynamic> userData = {
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isActive': true,
          'authProvider': user.providerData.isNotEmpty ? user.providerData.first.providerId : 'unknown',
        };
        
        // Ajouter les informations spécifiques au provider
        if (user.providerData.isNotEmpty) {
          final providerData = user.providerData.first;
          if (providerData.providerId == 'google.com') {
            userData['email'] = user.email;
            userData['displayName'] = user.displayName;
            userData['photoURL'] = user.photoURL;
          } else if (providerData.providerId == 'phone') {
            userData['phoneNumber'] = user.phoneNumber;
          }
        }
        
        await userRef.set(userData);
      } else {
        // Mettre à jour le document existant
        Map<String, dynamic> updateData = {
          'lastSeen': FieldValue.serverTimestamp(),
        };
        
        // Mettre à jour les informations si elles ont changé
        if (user.providerData.isNotEmpty) {
          final providerData = user.providerData.first;
          if (providerData.providerId == 'google.com') {
            updateData['email'] = user.email;
            updateData['displayName'] = user.displayName;
            updateData['photoURL'] = user.photoURL;
          }
        }
        
        await userRef.update(updateData);
      }
    } catch (e) {
      print('Error creating user document: $e');
    }
  }
  
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Déclencher le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // L'utilisateur a annulé la connexion
      }
      
      // Obtenir les détails d'authentification de la requête
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Créer une nouvelle credential pour Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Se connecter à Firebase avec la credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Créer ou mettre à jour le document utilisateur
        await _createUserDocument(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Créer l'utilisateur avec email et mot de passe
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Mettre à jour le nom d'affichage
        await userCredential.user!.updateDisplayName(displayName);
        
        // Créer le document utilisateur
        await _createUserDocument(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Se connecter avec email et mot de passe
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Mettre à jour le document utilisateur
        await _createUserDocument(userCredential.user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé';
        case 'weak-password':
          return 'Le mot de passe est trop faible';
        case 'invalid-email':
          return 'Email invalide';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez plus tard';
        default:
          return error.message ?? 'Une erreur est survenue';
      }
    }
    return error.toString();
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // Déconnexion Google également
      _user = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
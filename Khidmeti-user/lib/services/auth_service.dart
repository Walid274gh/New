import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
        await userRef.set({
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      } else {
        await userRef.update({
          'lastSeen': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
    } catch (e) {
      print('Error creating user document: $e');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
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
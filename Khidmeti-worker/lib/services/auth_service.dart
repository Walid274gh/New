import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  int _verificationStep = 0; // 0: phone, 1: document, 2: face, 3: complete
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  int get verificationStep => _verificationStep;
  
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _checkVerificationStatus();
      }
      notifyListeners();
    });
  }
  
  Future<void> _checkVerificationStatus() async {
    try {
      DocumentSnapshot workerDoc = await _firestore
          .collection('workers')
          .doc(_user!.uid)
          .get();
      
      if (workerDoc.exists) {
        Map<String, dynamic> data = workerDoc.data() as Map<String, dynamic>;
        _verificationStep = data['verificationStep'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error checking verification status: $e');
    }
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
        await _createWorkerDocument(result.user!);
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
  
  Future<void> _createWorkerDocument(User user) async {
    try {
      DocumentReference workerRef = _firestore.collection('workers').doc(user.uid);
      DocumentSnapshot workerDoc = await workerRef.get();
      
      if (!workerDoc.exists) {
        await workerRef.set({
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isActive': false,
          'verificationStep': 0,
          'isVerified': false,
          'subscriptionStatus': 'trial', // trial, active, expired
          'subscriptionEndDate': FieldValue.serverTimestamp(),
        });
      } else {
        await workerRef.update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating worker document: $e');
    }
  }
  
  Future<bool> uploadDocument(File documentImage, String documentType) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      String fileName = '${_user!.uid}_${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('documents/$fileName');
      
      UploadTask uploadTask = storageRef.putFile(documentImage);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update worker document
      await _firestore.collection('workers').doc(_user!.uid).update({
        'documentUrl': downloadUrl,
        'documentType': documentType,
        'verificationStep': 1,
        'documentUploadedAt': FieldValue.serverTimestamp(),
      });
      
      _verificationStep = 1;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> uploadSelfie(File selfieImage) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      String fileName = '${_user!.uid}_selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('selfies/$fileName');
      
      UploadTask uploadTask = storageRef.putFile(selfieImage);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update worker document
      await _firestore.collection('workers').doc(_user!.uid).update({
        'selfieUrl': downloadUrl,
        'verificationStep': 2,
        'selfieUploadedAt': FieldValue.serverTimestamp(),
      });
      
      _verificationStep = 2;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> completeProfile({
    required String firstName,
    required String lastName,
    required String profession,
    required String experience,
    required double hourlyRate,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firestore.collection('workers').doc(_user!.uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'profession': profession,
        'experience': experience,
        'hourlyRate': hourlyRate,
        'verificationStep': 3,
        'isVerified': true,
        'profileCompletedAt': FieldValue.serverTimestamp(),
      });
      
      _verificationStep = 3;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _verificationStep = 0;
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
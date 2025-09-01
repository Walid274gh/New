# 📧 Configuration Authentification Email pour Khidmeti User

## 📋 Vue d'ensemble

L'application Khidmeti User propose maintenant **trois méthodes d'authentification** :

1. **📱 Téléphone + OTP** : Authentification traditionnelle
2. **🔐 Google Sign-In** : Connexion rapide avec profil Google
3. **📧 Email + Mot de passe** : Authentification classique

## 🚀 Configuration Firebase

### Étape 1: Activer Email/Password
1. Aller dans [Firebase Console](https://console.firebase.google.com/)
2. Sélectionner votre projet
3. Aller dans **Authentication** > **Sign-in method**
4. Activer **Email/Password** comme provider
5. Optionnellement, activer **Email link (passwordless sign-in)**

### Étape 2: Règles de Sécurité
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🔧 Fonctionnalités Implémentées

### ✅ Inscription (Sign Up)
- **Champs requis** :
  - Nom complet
  - Adresse email
  - Mot de passe (minimum 6 caractères)
- **Validation** :
  - Format email valide
  - Force du mot de passe
  - Nom non vide
- **Création automatique** du document utilisateur dans Firestore

### ✅ Connexion (Sign In)
- **Champs requis** :
  - Adresse email
  - Mot de passe
- **Validation** :
  - Email et mot de passe non vides
  - Format email valide
- **Gestion des erreurs** :
  - Utilisateur non trouvé
  - Mot de passe incorrect
  - Trop de tentatives

### ✅ Récupération de Mot de Passe
- **Fonctionnalité** : Envoi d'email de réinitialisation
- **Champ requis** : Adresse email
- **Validation** : Format email valide
- **Feedback** : Confirmation d'envoi

## 🎨 Interface Utilisateur

### **Boutons de Basculement**
```
┌─────────────┬─────────────┐
│  Téléphone │    Email    │
│   (Actif)  │  (Inactif)  │
└─────────────┴─────────────┘
```

### **Mode Email - Connexion**
```
┌─────────────────────────────┐
│        Adresse email        │
│        Mot de passe         │
│                             │
│  [Se connecter] [Nouveau?] │
│                             │
│    Mot de passe oublié ?   │
└─────────────────────────────┘
```

### **Mode Email - Inscription**
```
┌─────────────────────────────┐
│        Nom complet          │
│        Adresse email        │
│        Mot de passe         │
│                             │
│  [S'inscrire] [Déjà inscrit]│
└─────────────────────────────┘
```

## 📱 Utilisation dans le Code

### **Service d'Authentification**
```dart
class AuthService extends ChangeNotifier {
  // Inscription
  Future<bool> signUpWithEmail(String email, String password, String displayName)
  
  // Connexion
  Future<bool> signInWithEmail(String email, String password)
  
  // Récupération mot de passe
  Future<bool> resetPassword(String email)
  
  // Gestion des erreurs
  String _getAuthErrorMessage(dynamic error)
}
```

### **Écran d'Authentification**
```dart
class AuthScreen extends StatefulWidget {
  // États
  bool _isEmailMode = false;      // Mode email vs téléphone
  bool _isSignUp = false;         // Inscription vs connexion
  bool _isPasswordVisible = false; // Visibilité du mot de passe
  
  // Méthodes
  void _toggleEmailMode()         // Basculer entre téléphone/email
  void _toggleSignUp()            // Basculer entre connexion/inscription
  Future<void> _signInWithEmail() // Connexion email
  Future<void> _signUpWithEmail() // Inscription email
  Future<void> _resetPassword()   // Récupération mot de passe
}
```

## 🔒 Sécurité

### **Validation des Données**
- **Email** : Regex de validation standard
- **Mot de passe** : Minimum 6 caractères
- **Nom** : Non vide et nettoyé

### **Gestion des Erreurs**
- **Messages utilisateur** : Erreurs en français
- **Codes d'erreur Firebase** : Traduits automatiquement
- **Validation côté client** : Feedback immédiat

### **Sécurité Firebase**
- **Authentification** : Gérée par Firebase Auth
- **Base de données** : Règles de sécurité Firestore
- **Mots de passe** : Hashés et sécurisés par Firebase

## 🧪 Tests

### **Test d'Inscription**
1. Basculer en mode Email
2. Cliquer sur "Nouveau compte ?"
3. Remplir les champs
4. Valider l'inscription
5. Vérifier dans Firestore

### **Test de Connexion**
1. Basculer en mode Email
2. Remplir email et mot de passe
3. Se connecter
4. Vérifier la redirection

### **Test de Récupération**
1. Mode Email > Connexion
2. Cliquer "Mot de passe oublié ?"
3. Entrer un email valide
4. Vérifier l'envoi

## 🚨 Dépannage

### **Erreur "Email déjà utilisé"**
- L'utilisateur existe déjà
- Utiliser la connexion au lieu de l'inscription

### **Erreur "Mot de passe trop faible"**
- Le mot de passe doit contenir au moins 6 caractères
- Ajouter des caractères spéciaux si nécessaire

### **Erreur "Email invalide"**
- Vérifier le format de l'email
- S'assurer qu'il n'y a pas d'espaces

### **Problème de validation**
- Vérifier que tous les champs requis sont remplis
- S'assurer que le formulaire est valide

## 📚 Ressources

- [Documentation Firebase Auth](https://firebase.flutter.dev/docs/auth/overview/)
- [Firebase Email/Password](https://firebase.google.com/docs/auth/flutter/password-auth)
- [Validation des formulaires Flutter](https://docs.flutter.dev/cookbook/forms/validation)

## ✅ Checklist de Configuration

- [ ] Email/Password activé dans Firebase
- [ ] Règles Firestore configurés
- [ ] Interface utilisateur testée
- [ ] Inscription fonctionnelle
- [ ] Connexion fonctionnelle
- [ ] Récupération mot de passe fonctionnelle
- [ ] Gestion des erreurs testée
- [ ] Validation des formulaires testée

---

**Statut** : ✅ Implémenté et testé  
**Prochaine étape** : 🚀 Core Navigation & User Interface
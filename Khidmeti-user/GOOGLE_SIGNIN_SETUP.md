# 🔐 Configuration Google Sign-In pour Khidmeti User

## 📋 Prérequis

### 1. Projet Firebase
- Avoir un projet Firebase configuré
- Activer l'authentification Google dans Firebase Console

### 2. Google Cloud Console
- Créer un projet Google Cloud (ou utiliser le même que Firebase)
- Activer l'API Google Sign-In

## 🚀 Configuration Firebase

### Étape 1: Activer Google Sign-In
1. Aller dans [Firebase Console](https://console.firebase.google.com/)
2. Sélectionner votre projet
3. Aller dans **Authentication** > **Sign-in method**
4. Activer **Google** comme provider
5. Configurer le support email et le nom du projet

### Étape 2: Récupérer la Web Client ID
1. Dans Firebase Console, aller dans **Project Settings**
2. Onglet **General**
3. Section **Your apps** > **Web app**
4. Copier la **Web client ID**

## 📱 Configuration Android

### Étape 1: Mettre à jour strings.xml
```xml
<!-- android/app/src/main/res/values/strings.xml -->
<string name="default_web_client_id">VOTRE_WEB_CLIENT_ID_ICI</string>
```

### Étape 2: Vérifier build.gradle
```gradle
// android/app/build.gradle
dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

### Étape 3: SHA-1 Fingerprint
1. Obtenir le SHA-1 de votre keystore de debug :
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

2. Ajouter le SHA-1 dans Firebase Console > Project Settings > Your apps > Android app

## 🍎 Configuration iOS

### Étape 1: Info.plist
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>VOTRE_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### Étape 2: GoogleService-Info.plist
- Télécharger le fichier depuis Firebase Console
- Placer dans `ios/Runner/GoogleService-Info.plist`

## 🔧 Configuration du Code

### Étape 1: Initialisation
Le service est déjà configuré dans `lib/services/auth_service.dart`

### Étape 2: Utilisation
```dart
// Dans votre écran d'authentification
ElevatedButton(
  onPressed: () async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signInWithGoogle();
    if (success) {
      // Connexion réussie
    }
  },
  child: Text('Se connecter avec Google'),
)
```

## 🧪 Test

### Test de Connexion
1. Lancer l'application
2. Aller sur l'écran d'authentification
3. Cliquer sur "Continuer avec Google"
4. Sélectionner un compte Google
5. Vérifier la connexion dans Firebase Console

### Vérification des Données
- Vérifier dans Firestore que l'utilisateur est créé
- Vérifier que les informations Google sont bien stockées

## 🚨 Dépannage

### Erreur "Sign in failed"
- Vérifier que Google Sign-In est activé dans Firebase
- Vérifier la Web Client ID
- Vérifier les SHA-1 fingerprints

### Erreur "Network error"
- Vérifier la connexion internet
- Vérifier les permissions dans le manifeste Android

### Erreur "Invalid client"
- Vérifier que l'application est bien configurée dans Google Cloud Console
- Vérifier que les OAuth 2.0 sont configurés

## 📚 Ressources

- [Documentation Firebase Auth](https://firebase.flutter.dev/docs/auth/overview/)
- [Documentation Google Sign-In](https://developers.google.com/identity/sign-in/android)
- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/)

## ✅ Checklist de Configuration

- [ ] Projet Firebase créé
- [ ] Google Sign-In activé dans Firebase
- [ ] Web Client ID récupéré
- [ ] strings.xml mis à jour
- [ ] SHA-1 ajouté dans Firebase
- [ ] build.gradle vérifié
- [ ] Test de connexion réussi
- [ ] Données utilisateur créées dans Firestore
# Firestore — reglas sugeridas (FluidLearn)

En **Firebase Console → Firestore Database → Reglas**, puedes usar algo como:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Ajusta según políticas de la universidad (lecturas públicas, administradores, etc.).

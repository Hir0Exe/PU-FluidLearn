# Firestore — reglas sugeridas (FluidLearn)

## Por qué aparece `permission-denied` al completar una actividad

La app escribe **solo en `users/{tuUid}`**: progreso, racha, `completedTaskIds` y las notificaciones en el campo **`feedItems`** (array en ese mismo documento).  
No hace falta regla aparte para subcolecciones: con permitir **create/update** del propio documento de usuario suele bastar.

Aun así debes **publicar reglas** que permitan al usuario autenticado leer y escribir **su** `users/{userId}`.

## Reglas (copiar en Firebase Console)

El archivo **`firestore.rules`** en la raíz del repo contiene lo mismo. En **Firebase Console → Firestore Database → Reglas**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create, update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Pulsa **Publicar**. Sin publicar, la app seguirá recibiendo `permission-denied`.

## Desplegar reglas con Firebase CLI

En la raíz del repo ya existe **`firestore.rules`** y **`firebase.json`** apunta a ese archivo.

1. Instala la [Firebase CLI](https://firebase.google.com/docs/cli) si aún no la tienes.
2. Inicia sesión: `firebase login`
3. Asocia el proyecto (si hace falta): `firebase use pu-fluidlearn`
4. Sube solo las reglas:

```bash
firebase deploy --only firestore:rules
```

Ajusta según políticas de la universidad (lecturas públicas, administradores, etc.).

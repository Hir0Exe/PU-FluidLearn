# FluidLearn

Aplicación móvil Flutter para la **validación de niveles de inglés** orientada a estudiantes de la **Universidad Simón Bolívar (USB)**.

---

## Requisitos previos

| Herramienta | Versión mínima | Verificar con |
|---|---|---|
| **Flutter SDK** | 3.9.2+ (canal stable) | `flutter --version` |
| **Dart SDK** | Incluido con Flutter | `dart --version` |
| **Android SDK** | API 36 + Build-Tools 36.x | `flutter doctor` |
| **Java JDK** | 11 o 17 | `java -version` |
| **Git** | Cualquiera reciente | `git --version` |
| **Cuenta Google** | Con acceso a Firebase Console | — |

---

## 1. Instalar Flutter

1. Descarga el SDK desde [flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install).
2. Descomprime en una ruta sin espacios, por ejemplo `C:\Users\<tu_usuario>\flutter`.
3. Agrega `<ruta_flutter>\bin` al **PATH** de tu sistema.
   - **Windows:** Variables de entorno → Path (Usuario) → Agregar la ruta.
4. Reinicia la terminal y comprueba:

```bash
flutter --version
flutter doctor
```

---

## 2. Instalar Android SDK

### Opción A — Con Android Studio (recomendado)

1. Descarga [Android Studio](https://developer.android.com/studio).
2. Ábrelo, sigue el asistente **Standard** y deja que descargue el SDK.
3. En **File → Settings → Languages & Frameworks → Android SDK**:
   - Instala **Android SDK Platform 36** y **Build-Tools 36.x**.
   - Anota la ruta del SDK (por ejemplo `D:\Android\sdk`).

### Opción B — Solo línea de comandos

1. Descarga **Command line tools only** desde la misma página de Android Studio.
2. Descomprime en `<tu_ruta_sdk>\cmdline-tools\latest\`.
3. Instala paquetes:

```bash
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

### Variables de entorno

Configura de forma permanente (Variables de entorno de Windows o `~/.bashrc` en Linux/Mac):

```
ANDROID_HOME = <tu_ruta_sdk>        (ej. D:\Android\sdk)
JAVA_HOME    = <ruta_al_jdk>        (ej. C:\Program Files\Java\jdk-17)
```

Agrega al **PATH**:

```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\cmdline-tools\latest\bin
```

Acepta licencias:

```bash
flutter doctor --android-licenses
```

---

## 3. Clonar el repositorio

```bash
git clone <url_del_repositorio>
cd PU-FluidLearn
```

---

## 4. Configurar Firebase (desde cero)

### 4.1 Crear proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/).
2. **Agregar proyecto** → ponle un nombre (por ejemplo `pu-fluidlearn`).
3. Desactiva Google Analytics si no lo necesitas (opcional).
4. Espera a que se cree.

### 4.2 Activar Authentication

1. En la consola del proyecto, ve a **Authentication → Sign-in method**.
2. Activa **Correo electrónico/contraseña**.
3. Activa **Google** (te pedirá un correo de soporte; usa el tuyo).

### 4.3 Crear base de datos Firestore

1. Ve a **Firestore Database → Crear base de datos**.
2. Elige la ubicación más cercana.
3. Selecciona **modo de prueba** para desarrollo (las reglas expiran en 30 días; luego endurecerlas).
4. Una vez creada, ve a **Reglas** y pega las reglas de `FIREBASE_RULES.md`:

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

### 4.4 Registrar la app Android

1. En **Configuración del proyecto** (engranaje) → **Tus apps** → **Agregar app** → **Android**.
2. **Nombre del paquete Android:** `ve.usb.fluidlearn` (debe coincidir con `applicationId` en `android/app/build.gradle.kts`).
3. Apodo de la app: `FluidLearn` (opcional).
4. **No descargues `google-services.json` todavía** — primero agrega el SHA-1 (paso siguiente).

### 4.5 Agregar huella SHA-1 (obligatorio para Google Sign-In)

1. En la terminal, dentro de la carpeta del proyecto:

```bash
cd android
./gradlew signingReport
```

> En Windows, si falla por JAVA_HOME, defínelo antes:
> ```powershell
> $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
> .\gradlew.bat signingReport
> ```

2. Copia el valor de **SHA1** del variant `debug` (algo como `A3:67:85:C8:...`).
3. En Firebase Console → **Configuración del proyecto** → tu app Android → **Agregar huella digital** → pega el SHA-1.
4. (Opcional pero recomendado) agrega también el **SHA-256**.

### 4.6 Descargar google-services.json

1. En la misma ficha de la app Android, pulsa **Descargar google-services.json**.
2. Copia el archivo a `android/app/google-services.json` (reemplaza el existente si hay uno).

### 4.7 Generar firebase_options.dart con FlutterFire CLI

1. Instala la CLI (una sola vez):

```bash
dart pub global activate flutterfire_cli
```

2. Desde la raíz del proyecto, ejecuta:

```bash
flutterfire configure --project=<tu_project_id>
```

Reemplaza `<tu_project_id>` por el ID del proyecto Firebase (visible en Configuración del proyecto, por ejemplo `pu-fluidlearn`).

3. Selecciona las plataformas que necesites (al menos **Android**).
4. Esto genera/actualiza `lib/firebase_options.dart` y `firebase.json`.

> **Nota:** `lib/firebase_options.dart` y `android/app/google-services.json` están en `.gitignore` porque contienen claves. Cada desarrollador debe generar los suyos con los pasos anteriores.

---

## 5. Instalar dependencias

```bash
cd <raiz_del_proyecto>
flutter pub get
```

---

## 6. Ejecutar la app

### En dispositivo físico (USB)

1. Activa **Opciones de desarrollador** y **Depuración USB** en el móvil.
2. En Xiaomi/MIUI, activa también **Instalar vía USB** y **Depuración USB (ajustes de seguridad)** en Opciones de desarrollador.
3. Conecta el cable USB y selecciona modo **Transferencia de archivos**.
4. Acepta el diálogo **"¿Permitir depuración USB?"** en el teléfono.
5. Verifica que Flutter ve el dispositivo:

```bash
flutter devices
```

6. Ejecuta:

```bash
flutter run
```

> La primera compilación puede tardar varios minutos (descarga NDK, plataformas, etc.).

### En navegador (Chrome)

```bash
flutter run -d chrome
```

### Atajos en ejecución

| Tecla | Acción |
|---|---|
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Salir |

---

## 7. Estructura del proyecto

```
lib/
├── app_state.dart                    # Instancia global del AuthController
├── firebase_options.dart             # Generado por FlutterFire CLI (no se sube a git)
├── main.dart                         # Punto de entrada y navegación por estado
├── controllers/
│   └── auth_controller.dart          # Singleton: escucha Firebase Auth + perfil
├── models/
│   └── user_model.dart               # Modelo de estudiante (nombre, carnet, etc.)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Inicio de sesión (email o Google)
│   │   ├── register_screen.dart      # Registro con datos de estudiante
│   │   └── complete_profile_screen.dart  # Completar perfil (tras Google)
│   └── home/
│       └── simple_home_screen.dart   # Pantalla principal (placeholder)
└── services/
    └── auth_service.dart             # Lógica de Firebase Auth + Firestore
```

---

## 8. Identificadores de la app

| Plataforma | Identificador |
|---|---|
| Android `applicationId` / `namespace` | `ve.usb.fluidlearn` |
| iOS / macOS `PRODUCT_BUNDLE_IDENTIFIER` | `ve.usb.fluidlearn` |
| Paquete Dart (`pubspec.yaml`) | `fluidlearn_app` |

---

## 9. Solución de problemas frecuentes

### `flutter` no se reconoce como comando

- Verifica que `<ruta_flutter>\bin` esté en el PATH.
- **Cierra y vuelve a abrir** la terminal tras editar variables de entorno.

### `ANDROID_HOME` no encontrado / Android SDK not found

- Define `ANDROID_HOME` apuntando a la carpeta del SDK.
- Ejecuta `flutter doctor` para confirmar.

### Google Sign-In falla con `ApiException: 10`

- Falta el **SHA-1** en Firebase Console para la app Android.
- Verifica que el **`package_name`** en `google-services.json` sea exactamente `ve.usb.fluidlearn`.
- Descarga de nuevo `google-services.json` **después** de agregar la huella.

### `INSTALL_FAILED_USER_RESTRICTED` al instalar en el móvil

- En Xiaomi/MIUI: activa **Instalar vía USB** y **Depuración USB (ajustes de seguridad)** en Opciones de desarrollador.
- Desbloquea la pantalla del teléfono durante la instalación.

### `JAVA_HOME is set to an invalid directory`

- Define `JAVA_HOME` apuntando a tu JDK (ejemplo: `C:\Program Files\Java\jdk-17`).

### Primera compilación muy lenta

- Es normal; Gradle descarga dependencias, NDK, plataformas, etc. Las siguientes compilaciones son mucho más rápidas.

---

## 10. Dependencias principales

| Paquete | Uso |
|---|---|
| `firebase_core` | Inicialización de Firebase |
| `firebase_auth` | Autenticación (email + Google) |
| `cloud_firestore` | Base de datos de perfiles de estudiante |
| `google_sign_in` | Flujo OAuth de Google |

---

## Licencia

MIT — ver archivo `LICENSE`.

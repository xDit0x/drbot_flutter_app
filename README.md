# Dr. Bot

## Descripción del Proyecto

## Estructura

## Comandos de funcionamiento y plataformas

### Requisitos

- Flutter y Dart compatibles con la versión del SDK indicada en `pubspec.yaml`.
- Una instalación de Android Studio/SDK para ejecutar en Android, o Xcode para iOS/macOS.
- Acceso al proyecto Firebase `drbot-app`. La configuración de Firebase para las plataformas está en `lib/firebase_options.dart` y en los archivos nativos correspondientes.

### Preparar y ejecutar

Desde la raíz del repositorio:

```bash
flutter pub get # Obtener configuración del archivo pubspec.yaml
flutter devices # Ver dispositivos disposibles para lanzar la aplicación
flutter run # Ejecutar la aplicación
```

Para elegir una plataforma o dispositivo concreto, consulta primero su identificador con `flutter devices` y ejecutar:

```bash
flutter run -d <device_id>
```

También se puede iniciar desde el botón **Run** de Android Studio o VS Code con la extensión de Flutter.

### Compilar

```bash
flutter build apk       # Android
flutter build appbundle # Android, publicación
flutter build ios       # iOS (requiere macOS y Xcode)
flutter build web       # Web
```

### Otros comandos
```bash
# Flutter
flutter pub add <dependencia>           # Añadir dependencias al proyecto, que se registran en el archivo pubspec.yaml
flutter emulators                       # Ver los dispositivos que podemos emular
flutter emulators --launch <device_id>  # Lanzar dispositivo en emulación
flutter clean                           # Borra toda la configuración en local que tengas del proyecto, menos la carpeta lib, para poderlo reconstruir con el comando `flutter pub get` y el archivo pubspec.yaml

# Firebase
firebase.cmd deploy --only storage --project drbot-app  # Lanzar las reglas de lectura y escritura en la base de datos en Firebase en el archivo firestore.rules

```

La aplicación inicializa Firebase al arrancar, comprueba la sesión y dirige al usuario a autenticación o al contenido principal. Las notificaciones push requieren tener configurado Firebase Messaging en la plataforma y conceder los permisos del dispositivo.

## Diagrama de casos de uso

El siguiente diagrama muestra los principales casos de uso de Dr. Bot para el paciente y el médico:

![Diagrama de casos de uso de Dr. Bot](docs/diagrams/diagrama-casos-uso.png)

## Casos de Uso

### Pedro

### Antonio

## 1. Consultar los centros médicos asignados

El usuario accede a la sección **Perfil** para consultar los centros médicos que tiene asignados.

Los centros médicos y hospitales incluidos en la aplicación están registrados en el [Registro General de centros, servicios y establecimientos sanitarios de España (REGCESS)](https://regcess.mscbs.es/regcessWeb/inicioBuscarCentrosAction.do).

#### 2. Solicitar un cambio de centro médico

Desde **Perfil → Clínico**, el usuario puede enviar un correo para solicitar un cambio del centro médico que tiene asignado.

#### 3. Consultar los informes médicos

El usuario accede a **Documentos médicos** para consultar los informes disponibles. El médico responsable registra el informe asociado a la cita, incluidas las enfermedades detectadas y los detalles del diagnóstico.

#### 4. Consultar el historial clínico

El usuario consulta la información de su historial clínico disponible en la aplicación, registrada tras la valoración del médico.

#### 5. Consultar las tarjetas sanitarias

El usuario consulta sus tarjetas sanitarias y la información de cobertura médica asociada. La aplicación contempla las siguientes opciones:

- Sanidad pública
- Seguros privados:
  - Sanitas
  - DKV
  - Adeslas
  - ASISA

#### 6. Ajustar las preferencias de la aplicación

El usuario modifica los ajustes disponibles para adaptar la aplicación a sus necesidades. Entre ellos se encuentran:

- **Autenticación biométrica:** permite proteger el acceso a la aplicación mediante la biometría del dispositivo.
- **Cambio de contraseña:** el usuario puede cambiarla desde los ajustes tras autenticarse. Si no ha iniciado sesión, puede solicitar un correo de recuperación desde la pantalla de inicio de sesión.
- **Eliminar la cuenta:** permite borrar la cuenta y los datos asociados tras confirmar la operación con la contraseña.
- **Compatibilidad con lectores de pantalla:** la aplicación es compatible con VoiceOver y TalkBack.
- **Tamaño del texto:** permite ajustar el tamaño de letra desde la aplicación.
- **Vibración:** permite activar o desactivar la respuesta por vibración.
- **Acerca de:** muestra la versión instalada de la aplicación.

#### 7. Enviar un reporte o sugerencia

Desde la parte inferior de la sección **Ayuda**, el usuario puede comunicar un problema de la aplicación o proponer una nueva funcionalidad.

#### 8. Consultar la medicación prescrita

El usuario consulta los medicamentos que le ha prescrito el médico. El médico determina qué medicamentos necesita el paciente y puede modificar la prescripción según su valoración.

La aplicación utiliza la información pública sobre medicamentos de la [API de CIMA de la AEMPS](https://sede.aemps.gob.es/docs/CIMA-REST-API_1_19.pdf).

#### 9. Descargar la receta virtual

Desde la sección **Medicamentos**, el usuario puede descargar un documento con la información de la receta para consultarla o presentarla en la farmacia. Este documento es informativo y no tiene validez legal.


## Base de Datos

La aplicación utiliza **Cloud Firestore**, la base de datos documental de Firebase, y **Firebase Authentication** para identificar a los usuarios. Los documentos de cada paciente se asocian al UID de Firebase Authentication. Las colecciones y subcolecciones principales que utiliza la aplicación son:

| Ruta / colección | Uso |
| --- | --- |
| `Users/{uid}` | Perfil, contacto, centro asignado y datos clínicos del paciente. |
| `Users/{uid}/appointments` | Citas del paciente, estado, check-in, firma y datos de la consulta. |
| `Users/{uid}/alerts` y `Users/{uid}/tokens` | Alertas guardadas y tokens para notificaciones push. |
| `Doctors` | Médicos, especialidad, centro y horarios. |
| `Slots` | Bloqueo y estado de las franjas horarias reservadas. |
| `Sessions` | Datos de sesión de consulta, como sala y fecha. |
| `Queues` | Contador y estado de la cola de espera por médico, centro y día. |
| `Prescriptions/{medicationId}/Users/{uid}/PatientPrescriptions` | Recetas asignadas al paciente. Cada receta puede tener subcolección `Dispensations` con las dispensaciones registradas. |

Las reservas, cancelaciones y el check-in usan transacciones de Firestore para mantener coherentes la cita, el horario y la cola. Los índices compuestos necesarios se declaran en `firestore.indexes.json`; las reglas se configuran en `firestore.rules`.

## Dependencias

Las dependencias se declaran en `pubspec.yaml`. Se utilizan para las siguientes funciones:

### Dependencias de la aplicación

| Paquete | Uso en el proyecto |
| --- | --- |
| `flutter` | SDK base para construir la interfaz y ejecutar la aplicación multiplataforma. |
| `cupertino_icons` | Proporciona iconos con estilo iOS para la interfaz. |
| `flutter_svg` | Carga y muestra los iconos e ilustraciones vectoriales SVG de la aplicación. |
| `flutter_bloc` | Gestiona estado y actualizaciones de interfaz con el patrón BLoC/Cubit, por ejemplo para el tema. |
| `hydrated_bloc` | Persiste y restaura el estado de Cubit/BLoC entre ejecuciones; se usa para conservar preferencias como el tema. |
| `path_provider` | Obtiene directorios de almacenamiento del dispositivo; se usa para inicializar el almacenamiento de `hydrated_bloc`. |
| `get_it` | Localizador de dependencias para registrar y recuperar servicios, repositorios y casos de uso. |
| `dartz` | Proporciona tipos funcionales como `Either` para devolver resultados o errores desde la capa de dominio y datos. |
| `firebase_core` | Inicializa Firebase y la configuración de cada plataforma al arrancar la aplicación. |
| `firebase_auth` | Gestiona el registro, inicio/cierre de sesión, recuperación de contraseña y la identidad del paciente. |
| `cloud_firestore` | Almacena y consulta perfiles, citas, médicos, horarios, recetas, alertas y colas de espera. |
| `firebase_messaging` | Recibe notificaciones push mediante Firebase Cloud Messaging y registra los tokens del dispositivo. |
| `flutter_local_notifications` | Muestra notificaciones locales en el dispositivo, incluidas las asociadas a mensajes recibidos. |
| `shared_preferences` | Guarda preferencias sencillas localmente, como el tamaño del texto y la activación del bloqueo biométrico. |
| `local_auth` | Solicita autenticación biométrica o del dispositivo para proteger el acceso a la aplicación. |
| `package_info_plus` | Lee los metadatos de la aplicación, como nombre y versión, mostrados en la pantalla “Acerca de”. |
| `url_launcher` | Abre enlaces externos o acciones del sistema desde las pantallas de ayuda e información del centro médico. |
| `table_calendar` | Presenta el calendario empleado para consultar y seleccionar fechas de citas. |
| `flutter_localizations` | Añade soporte de localización de Flutter; la aplicación configura el idioma español. |
| `pdf` | Genera documentos PDF para la documentación clínica y las recetas. |
| `printing` | Permite previsualizar, compartir o imprimir los PDF generados. |
| `signature` | Permite capturar la firma del paciente durante el check-in de una cita. |

### Dependencias de desarrollo

| Paquete | Uso en el proyecto |
| --- | --- |
| `flutter_test` | Herramientas de Flutter para pruebas automatizadas. |
| `flutter_lints` | Reglas de análisis estático para mantener un estilo y detectar problemas comunes en Dart. |
| `flutter_launcher_icons` | Genera los iconos de lanzamiento de Android e iOS a partir de las imágenes configuradas en `pubspec.yaml`. |

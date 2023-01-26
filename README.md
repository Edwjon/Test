# ITOSoftwareTest

Este proyecto iOS te permite ver tu localización en tiempo real utilizando la tecnología de apple de MapKit. Dentro de la aplicación podrás loguearte con tu cuenta de Google. 

## Features
- Inicio de sesión con cuenta de Google
- Localización en tiempo real
- Rastreo de localización en background
- Registro de información sobre las localizaciones del usuario
- Enviado de emails con registros en archivos .txt

## Technologies Used
- CocoaPods
- FirebaseAuth
- GoogleSignIn
- Firebase

## Installation
1. Clonar o descargar el proyecto desde el repositorio
2. Correr el comando 'pod install" en el directorio del proyecto para instalar las dependencias necesarias
3. Abrir el proyecto en Xcode y correrlo en un simulador o un dispositivo conectado

##Warnings
Si la aplicación presenta un crash al momento de entrar en background, se deberá de hacer lo siguiente:
1. En Xcode, en el menú superior, se navegará a Product -> Scheme -> Edit Sheme
2. En el menú lateral izquierdo, seleccionar Run/Debud
3. En el menú superior, seleccionar Diagnostics
4. Deseleccionar la opción "Metal/API Validation"

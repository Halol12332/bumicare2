import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: kIsWeb
      ? "535728154791-7ffioh2jrfvu07k0jc2s3cqj56dnkkmh.apps.googleusercontent.com"
      : null, // Untuk Android/iOS, null akan mengambil clientId dari konfigurasi Firebase
);

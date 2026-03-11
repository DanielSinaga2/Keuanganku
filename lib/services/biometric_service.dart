import 'package:local_auth/local_auth.dart';

class BiometricService {

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {

    try {

      bool canCheck = await auth.canCheckBiometrics;

      if (!canCheck) return false;

      bool authenticated = await auth.authenticate(

        localizedReason: "Login menggunakan fingerprint",

        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),

      );

      return authenticated;

    } catch (e) {

      return false;

    }

  }

}
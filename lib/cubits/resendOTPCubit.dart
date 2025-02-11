import '../../app/generalImports.dart';

abstract class ResendOtpState {}

class ResendOtpInitial extends ResendOtpState {}

class ResendOtpInProcess extends ResendOtpState {}

class ResendOtpSuccess extends ResendOtpState {}

class ResendOtpFail extends ResendOtpState {
  ResendOtpFail(this.error);

  final dynamic error;
}

class ResendOtpCubit extends Cubit<ResendOtpState> {
  ResendOtpCubit() : super(ResendOtpInitial());
  final AuthRepository authRepo = AuthRepository();

  Future<void> resendOtpUsingFirebase(
      {required String phoneNumber,
      required String phoneNumberWithoutCountryCode,
      required String countryCode,
      final VoidCallback? onOtpSent}) async {
    try {
      emit(ResendOtpInProcess());

      await authRepo.verifyPhoneNumber(
        phoneNumber,
        onError: (err) {
          emit(ResendOtpFail(err));
        },
        onCodeSent: () {
          onOtpSent?.call();
          emit(ResendOtpSuccess());
        },
      );
    } on FirebaseAuthException catch (error) {
      emit(ResendOtpFail(error.code.getFirebaseError()));
    } catch (error) {
      emit(ResendOtpFail(error.toString()));
    }
  }

  Future<void> resendOtpUsingSMSGateway(
      {required String phoneNumber,
      required String phoneNumberWithoutCountryCode,
      required String countryCode,
      final VoidCallback? onOtpSent}) async {
    try {
      emit(ResendOtpInProcess());

      final Map<String, dynamic> response = await authRepo.sendVerificationCodeUsingSMSGateway(
        phoneNumberWithoutCountryCode: phoneNumberWithoutCountryCode,
        countryCode: countryCode,
      );
      if (response["error"]) {
        emit(ResendOtpFail(response["message"]));
      } else {
        onOtpSent?.call();
        emit(ResendOtpSuccess());
      }
    } catch (error) {
      emit(ResendOtpFail(error.toString()));
    }
  }

  void setDefaultOtpState() {
    emit(ResendOtpInitial());
  }
}

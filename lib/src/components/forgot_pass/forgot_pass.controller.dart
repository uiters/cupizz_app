part of '../index.dart';

class ForgotController extends MomentumController<ForgotPassModel> {
  @override
  ForgotPassModel init() {
    return ForgotPassModel(
      this,
    );
  }

  Future sendOtp(String email) async {
    try {
      final service = getService<UserService>();
      model.update(email: email, isSendingOtp: true);
      final token = await service.forgotPassword(email);
      model.update(token: token);
    } catch (e) {
      await Fluttertoast.showToast(msg: e.toString());
      rethrow;
    } finally {
      model.update(isSendingOtp: false);
    }
  }

  Future verifyOtp(String otp) async {
    try {
      final service = getService<UserService>();
      model.update(isVerifingOtp: true);
      final data = await service.validateForgotPasswordToken(model.token, otp);
      model.update(data: data);
    } catch (e) {
      await Fluttertoast.showToast(msg: e.toString());
      rethrow;
    } finally {
      model.update(isVerifingOtp: false);
    }
  }

  Future changePass(String newPass) async {
    try {
      final service = getService<UserService>();
      model.update(isChangingPass: true);
      await service.changePasswordByForgotPasswordToken(
          model.data?.token, newPass);
      reset();
    } catch (e) {
      await Fluttertoast.showToast(msg: e.toString());
      rethrow;
    } finally {
      model.update(isChangingPass: false);
    }
  }
}

import 'package:flutter_learning/data/repository/appointments/appointment_repository_impl.dart';
import 'package:flutter_learning/data/repository/auth/auth_repository_impl.dart';
import 'package:flutter_learning/data/repository/contact/contact_repository_impl.dart';
import 'package:flutter_learning/data/sources/appointments/appointment_firebase_service.dart';
import 'package:flutter_learning/data/sources/contact/contact_firebase_service.dart';
import 'package:flutter_learning/domain/repository/appointments/appointment_repository.dart';
import 'package:flutter_learning/domain/repository/clinical/clinical_repository.dart';
import 'package:flutter_learning/data/repository/clinical/clinical_repository_impl.dart';
import 'package:flutter_learning/data/sources/auth/auth_firebase_service.dart';
import 'package:flutter_learning/data/sources/clinical/clinical_firebase_service.dart';
import 'package:flutter_learning/domain/repository/auth/auth.dart';
import 'package:flutter_learning/domain/repository/contact/contact_repository.dart';
import 'package:flutter_learning/domain/usecases/appointments/get_appointments.dart';
import 'package:flutter_learning/domain/usecases/appointments/remove_appointment.dart';
import 'package:flutter_learning/domain/usecases/auth/sendPasswordResetEmail.dart';
import 'package:flutter_learning/domain/usecases/auth/sign_in.dart';
import 'package:flutter_learning/domain/usecases/auth/sign_up.dart';
import 'package:flutter_learning/domain/usecases/clinical/get_clinical_info.dart';
import 'package:flutter_learning/domain/usecases/contact/get_contact_info.dart';
import 'package:flutter_learning/domain/usecases/contact/update_contact_info.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServieImpl());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  sl.registerSingleton<SignUpUseCase>(SignUpUseCase());

  sl.registerSingleton<SignInUseCase>(SignInUseCase());

  sl.registerSingleton<SendPasswordResetEmailUseCase>(
    SendPasswordResetEmailUseCase(),
  );

  sl.registerSingleton<ClinicalFirebaseService>(ClinicalFirebaseServiceImpl());

  sl.registerSingleton<ClinicalRepository>(ClinicalRepositoryImpl());

  sl.registerSingleton<GetClinicalInfoUseCase>(GetClinicalInfoUseCase());

  sl.registerSingleton<ContactFirebaseService>(ContactFirebaseServiceImpl());

  sl.registerSingleton<ContactRepository>(ContactRepositoryImpl());

  sl.registerSingleton<GetContactInfoUseCase>(GetContactInfoUseCase());

  sl.registerSingleton<UpdateContactInfoUseCase>(UpdateContactInfoUseCase());

  sl.registerSingleton<AppointmentRepository>(AppointmentRepositoryImpl());

  sl.registerSingleton<GetAppointmentsUseCase>(GetAppointmentsUseCase());

  sl.registerSingleton<RemoveAppointmentUseCase>(RemoveAppointmentUseCase());

  sl.registerSingleton<AppointmentFirebaseService>(
    AppointmentFirebaseServiceImpl(),
  );
}

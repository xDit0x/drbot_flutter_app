import 'package:dartz/dartz.dart' hide State;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/common/helpers/is_dark_mode.dart';
import 'package:flutter_learning/common/helpers/validators.dart';
import 'package:flutter_learning/core/configs/theme/app_colors.dart';
import 'package:flutter_learning/domain/models/contact/update_contact_request.dart';
import 'package:flutter_learning/domain/entities/contact/contact_info.dart';
import 'package:flutter_learning/domain/entities/contact/country_phone.dart';
import 'package:flutter_learning/domain/usecases/contact/get_contact_info.dart';
import 'package:flutter_learning/domain/usecases/contact/update_contact_info.dart';
import 'package:flutter_learning/presentation/profile/widgets/country_picker_sheet.dart';
import 'package:flutter_learning/presentation/profile/widgets/inline_editable_text.dart';
import 'package:flutter_learning/service_locator.dart';

class ContactInfoView extends StatefulWidget {
  const ContactInfoView({super.key});

  @override
  State<ContactInfoView> createState() => _ContactInfoViewState();
}

class _ContactInfoViewState extends State<ContactInfoView> {
  late Future<Either> _future;
  CountryPhone? _pendingCountry;

  Future<void> _saveEmail(String value, ContactInfo info) async {
    final country =
        _pendingCountry ?? info.countryPhone ?? CountryPhone.defaultCountry;
    final result = await sl<UpdateContactInfoUseCase>().call(
      params: UpdateContactRequest(
        email: info.email ?? FirebaseAuth.instance.currentUser?.email ?? '',
        phoneNumber: value,
        countryPhone: country, // ← efectivo,
      ),
    );
    if (!mounted) return;
    result.fold(
      (l) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      (r) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Icon(Icons.account_circle_rounded),
                      Text(
                        'Contacto actualizado',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _load());
      },
    );
  }

  Future<void> _savePhoneNumber(String value, ContactInfo info) async {
    final country =
        _pendingCountry ?? info.countryPhone ?? CountryPhone.defaultCountry;
    final result = await sl<UpdateContactInfoUseCase>().call(
      params: UpdateContactRequest(
        email: info.email ?? FirebaseAuth.instance.currentUser?.email ?? '',
        phoneNumber: value,
        countryPhone: country,
      ),
    );
    if (!mounted) return;
    result.fold(
      (l) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      },

      (r) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Icon(Icons.phone_rounded),
                      Text(
                        'Contacto actualizado',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _pendingCountry = null;
          _load();
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<GetContactInfoUseCase>().call();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 1.4,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error inesperado: ${snapshot.error}'));
        }
        return snapshot.data!.fold((l) => Center(child: Text(l.toString())), (
          r,
        ) {
          final info = r as ContactInfo;
          final effectiveCountry =
              _pendingCountry ??
              info.countryPhone ??
              CountryPhone.defaultCountry;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_2_rounded, size: 45),
                  SizedBox(height: 10),
                  Text(
                    info.fullName != null ? '${info.fullName}' : "Nombre no proporcionado, contacte con el administrador.",
                    style: TextStyle(
                      color: info.fullName != null
                          ? Theme.of(context).colorScheme.inverseSurface
                          : Colors.grey,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      decoration: info.fullName != null
                          ? null
                          : TextDecoration.underline,
                      decorationColor: context.isDarkMode
                          ? Colors.grey.withAlpha(100)
                          : const Color.fromARGB(
                              255,
                              74,
                              74,
                              74,
                            ).withAlpha(250),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  InlineEditableText(
                    textColor: context.isDarkMode
                        ? Colors.grey
                        : const Color.fromARGB(
                            255,
                            125,
                            125,
                            125,
                          ).withAlpha(250),
                    key: ValueKey('email:${info.email}'),
                    maxLenght: 100,
                    hintText: "No consta email de contacto",
                    initialValue: info.email ?? '',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                            .hasMatch((v ?? '').trim())
                        ? null
                        : 'Email no válido',
                    onSubmit: (String value) {
                      _saveEmail(value, info);
                    },
                  ),

                  SizedBox(height: 16),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () =>
                            _pickCountry(context, info, effectiveCountry),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainer,
                            boxShadow: List.filled(
                              1,
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                offset: Offset.fromDirection(1, 1),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.keyboard_arrow_down_rounded),
                              Text(
                                '${effectiveCountry.flag}${effectiveCountry.dialCode}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 2),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainer,
                            boxShadow: List.filled(
                              1,
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                offset: Offset.fromDirection(1, 1),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InlineEditableText(
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  key: ValueKey(
                                    'phone:${_pendingCountry?.name}:${info.phoneNumber}',
                                  ),
                                  initialValue:
                                      (_pendingCountry != null &&
                                          _pendingCountry != info.countryPhone)
                                      ? ''
                                      : (info.phoneNumber?.toString() ?? ''),
                                  maxLenght: (effectiveCountry).maxLenght,
                                  hintText: "Número no proporcionado",
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      validatePhoneNumber(v, effectiveCountry),
                                  onSubmit: (value) =>
                                      _savePhoneNumber(value, info),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _pickCountry(
    BuildContext context,
    ContactInfo info,
    CountryPhone effectiveCountry,
  ) async {
    final selected = await showModalBottomSheet<CountryPhone>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CountryPickerSheet(selected: effectiveCountry),
    );
    if (selected == null) return;
    setState(() {
      _pendingCountry = selected == info.countryPhone ? null : selected;
    });
  }
}

import 'package:crunch/screens/home_screen.dart';
import 'package:crunch/utils/constant.dart';
import 'package:crunch/utils/provider/projects_handler.dart';
import 'package:crunch/widgets/custom_animate_widget.dart';
import 'package:crunch/widgets/custom_divider.dart';
import 'package:crunch/widgets/custom_text_field.dart';
import 'package:crunch/widgets/editable_profile_image.dart';
import 'package:crunch/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:flutter/scheduler.dart' show timeDilation;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static String id = 'Authentication Screen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isConnected = false;
  bool isEmailButtonActive = false;
  bool isProcessing = false;
  bool isPasswordButtonActive = false;
  bool isAnExistingUser = false;
  String error = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final ValueNotifier<int> _textFieldIndex = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();

    Provider.of<ProjectsHandler>(context, listen: false)
        .connect()
        .then((value) => _isConnected = true);
  }

  bool isValidEmail() {
    String email = emailController.value.text;
    int len = email.length;
    int indexOfAt = email.indexOf('@');
    int indexOfPeriod = email.indexOf('.');
    int nAt = email.split('@').length - 1;
    int nPeriod = email.split('.').length - 1;
    if (nPeriod == 1 &&
            nAt == 1 &&
            indexOfAt <
                indexOfPeriod - 1 // . is after @ and . is not just next to @
            &&
            len - 1 >
                indexOfPeriod // ensuring that . is not the last and since . is after @ therefore @ cannot be last
        ) {
      return true;
    } else {
      return false;
    }
  }

  bool checkPasswordScreenValidity() {
    String username = usernameController.value.text;
    String password = passwordController.value.text;
    String confirmPassword = confirmPasswordController.value.text;
    if (username.isNotEmpty &&
        password.isNotEmpty &&
        password == confirmPassword) {
      return true;
    } else {
      return false;
    }
  }

  void resetTextEditingControllers() {
    passwordController.clear();
    confirmPasswordController.clear();
  }

  Column _getForm({
    required List<String> hintTexts,
    required List<TextEditingController> controllers,
    required List<void Function(String)> textFieldOnChanged,
    required List<InputType> inputTypes,
    required bool isButtonActive,
    bool showResetButton = false,
    required void Function() onButtonTap,
    required String buttonText,
    required bool isBackButtonVisible,
    bool addUserProfileOption = false,
    double gapBetweenEachField = 10,
  }) {
    List<Widget> children = [];

    if (addUserProfileOption == true) {
      children.add(EditableProfileImage());
      children.add(const SizedBox(height: 10));
    }

    /// Adding the text Fields
    for (int index = 0; index < hintTexts.length; index++) {
      children.add(
        CustomTextField(
          hintText: hintTexts[index],
          controller: controllers[index],
          autofocus: index == 0,
          inputType: inputTypes[index],
          onChanged: textFieldOnChanged[index],
        ),
      );
      children.add(SizedBox(height: gapBetweenEachField));
    }

    /// Adding the error message
    children.add(
      Visibility(
        /// Left it like this since error is global in this case
        visible: error.isNotEmpty,
        child: SizedBox(
          width: 300,
          child: Text(
            error,
            style: kTextStyleDefaultInactiveText.copyWith(
                color: Colors.red, fontSize: 8),
          ),
        ),
      ),
    );

    /// Adding the forgot reset button
    children.add(
      Visibility(
        visible: showResetButton,
        child: GestureDetector(
          onTap: () {
            setState(() {
              error = '';
              isProcessing = true;
            });
            Provider.of<ProjectsHandler>(context, listen: false)
                .sendResetPasswordLink(emailController.text)
                .listen((message) {
              setState(() {
                error = message;
                isProcessing = false;
              });
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 2 + 40),
            child: Text(
              'reset password',
              style: kTextStyleDefaultActiveText.copyWith(
                  color: kColorBlue, fontSize: 10),
            ),
          ),
        ),
      ),
    );

    /// Adding the space
    children.add(const SizedBox(height: 20));

    /// Adding the action button
    children.add(
      RoundedButton(
        height: 55,
        width: 300,
        isActive: isButtonActive,
        onTap: () {
          onButtonTap();

          resetTextEditingControllers();
        },
        child: Text(
          buttonText,
          style:
              kTextStyleDefaultActiveText.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );

    /// Adding the gap
    children.add(const SizedBox(height: 10));

    /// Adding the back button
    if (isBackButtonVisible) {
      children.add(
        GestureDetector(
          onTap: () => setState(() {
            _textFieldIndex.value = 0;
            error = '';
            resetTextEditingControllers();
          }),
          child: Text(
            'Back',
            style: kTextStyleDefaultActiveText.copyWith(
                fontSize: 15, color: kColorBlue),
          ),
        ),
      );
    }

    return Column(children: children);
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;
    if (Provider.of<ProjectsHandler>(context).getCurrentUser != null &&
        Provider.of<ProjectsHandler>(context).isUserEmailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamed(context, HomeScreen.id);
      });
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isProcessing ? 1 : 0,
                child: SizedBox(
                  height: 80,
                  child: Lottie.asset(
                    paths[Paths.lottieLoading]!,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Hero(
                  tag: 'App name',
                  child: Text(
                    'Crunch',
                    textAlign: TextAlign.center,
                    style: kTextStyleDefaultStylised.copyWith(fontSize: 50),
                  ),
                ),
              ),
              CustomAnimatedWidget(
                  boxHeight: 380,
                  currentVisibleChild: _textFieldIndex,
                  animDuration: const Duration(milliseconds: 400),
                  children: [
                    _getForm(
                        hintTexts: [
                          'email'
                        ],
                        controllers: [
                          emailController
                        ],
                        textFieldOnChanged: [
                          (input) {
                            setState(() {
                              if (isValidEmail()) {
                                isEmailButtonActive = true;
                              } else {
                                isEmailButtonActive = false;
                              }
                            });
                          }
                        ],
                        inputTypes: [
                          InputType.normal
                        ],
                        isButtonActive: isEmailButtonActive,
                        onButtonTap: () {
                          setState(() {
                            isProcessing = true;
                            FocusScope.of(context).unfocus();
                          });
                          Provider.of<ProjectsHandler>(context, listen: false)
                              .doesEmailExistsInFirebase(
                                  emailController.value.text)
                              .then((doesExist) {
                            setState(() {
                              _textFieldIndex.value = 1;
                              isProcessing = false;
                              isAnExistingUser = doesExist;
                            });
                          });
                        },
                        buttonText: 'Login/Signup',
                        isBackButtonVisible: false),
                    Stack(
                      children: [
                        Visibility(
                          visible: isAnExistingUser,
                          child: _getForm(
                              showResetButton: true,
                              hintTexts: ['password'],
                              controllers: [passwordController],
                              textFieldOnChanged: [
                                (pass) {
                                  setState(() {
                                    isPasswordButtonActive = passwordController
                                        .value.text.isNotEmpty;
                                  });
                                },
                              ],
                              inputTypes: [InputType.obscurePartial],
                              isButtonActive: isPasswordButtonActive,
                              onButtonTap: () {
                                setState(() {
                                  error = '';
                                  isProcessing = true;
                                });
                                Provider.of<ProjectsHandler>(context,
                                        listen: false)
                                    .login(emailController.value.text,
                                        passwordController.value.text)
                                    .then((response) {
                                  setState(() {
                                    error = response;
                                    isProcessing = false;
                                  });
                                });
                              },
                              buttonText: 'Login',
                              isBackButtonVisible: true),
                        ),
                        Visibility(
                          visible: !isAnExistingUser,
                          child: _getForm(
                              addUserProfileOption: true,
                              hintTexts: [
                                'username',
                                'password',
                                'confirm password'
                              ],
                              controllers: [
                                usernameController,
                                passwordController,
                                confirmPasswordController
                              ],
                              textFieldOnChanged: [
                                (name) {
                                  setState(() {
                                    isPasswordButtonActive =
                                        checkPasswordScreenValidity();
                                  });
                                },
                                (pass) {
                                  setState(() {
                                    isPasswordButtonActive =
                                        checkPasswordScreenValidity();
                                  });
                                },
                                (confirmPass) {
                                  setState(() {
                                    isPasswordButtonActive =
                                        checkPasswordScreenValidity();
                                  });
                                },
                              ],
                              inputTypes: [
                                InputType.normal,
                                InputType.obscurePartial,
                                InputType.obscureComplete
                              ],
                              isButtonActive: isPasswordButtonActive,
                              onButtonTap: () {
                                setState(() {
                                  error = '';
                                  isProcessing = true;
                                });
                                Provider.of<ProjectsHandler>(context,
                                        listen: false)
                                    .createUser(
                                        usernameController.value.text,
                                        emailController.value.text,
                                        passwordController.value.text)
                                    .then((response) {
                                  setState(() {
                                    error = response;
                                    isProcessing = false;
                                  });
                                });
                              },
                              buttonText: 'Signup',
                              isBackButtonVisible: true),
                        )
                      ],
                    ),
                  ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomDivider(
                      length: MediaQuery.of(context).size.width / 2 - 60),
                  Text(
                    'OR',
                    style: kTextStyleDefaultStylised.copyWith(fontSize: 20),
                  ),
                  CustomDivider(
                      length: MediaQuery.of(context).size.width / 2 - 60),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isProcessing = true;
                  });
                  await Provider.of<ProjectsHandler>(context, listen: false)
                      .googleSignIn();
                  isProcessing = false;
                },
                child: Container(
                    height: kSizeIconDefault * 3,
                    width: kSizeIconDefault * 3,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(kSizeIconDefault * 1.5),
                      border: Border.all(color: kColorBlack, width: 0.2),
                    ),
                    child: Image.asset(paths[Paths.googleLogo]!)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

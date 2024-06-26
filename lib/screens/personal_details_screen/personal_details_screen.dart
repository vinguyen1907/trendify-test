import 'package:ecommerce_app/blocs/user_bloc/user_bloc.dart';
import 'package:ecommerce_app/common_widgets/loading_manager.dart';
import 'package:ecommerce_app/common_widgets/my_app_bar.dart';
import 'package:ecommerce_app/common_widgets/my_button.dart';
import 'package:ecommerce_app/common_widgets/my_icon.dart';
import 'package:ecommerce_app/constants/app_assets.dart';
import 'package:ecommerce_app/constants/app_colors.dart';
import 'package:ecommerce_app/constants/app_dimensions.dart';
import 'package:ecommerce_app/constants/enums/gender.dart';
import 'package:ecommerce_app/extensions/extensions.dart';
import 'package:ecommerce_app/screens/personal_details_screen/widgets/gender_card.dart';
import 'package:ecommerce_app/screens/personal_details_screen/widgets/profile_details_information.dart';
import 'package:ecommerce_app/screens/personal_details_screen/widgets/profile_image.dart';
import 'package:ecommerce_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  static const String routeName = "/personal-details-screen";

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Gender gender;
  XFile? pickedImage;
  final _formKey = GlobalKey<FormState>();
  bool enableUpdate = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingManager(
      isLoading: false,
      child: Scaffold(
          appBar: const MyAppBar(),
          body: Column(
            children: [
              Text("Profile", style: Theme.of(context).textTheme.labelLarge!),
              const SizedBox(height: 40),
              Expanded(
                child: BlocConsumer<UserBloc, UserState>(
                  listener: (_, state) {
                    if (state.status == UserStatus.updated) {
                      Loading1Manager.instance.closeLoadingDialog(context);
                      _showSuccessDialog();
                    } else if (state.status == UserStatus.error || state.status == UserStatus.updateError) {
                      Loading1Manager.instance.closeLoadingDialog(context);
                      Utils.showSnackBar(context: context, message: "Update failed. Please try again.");
                    }
                  },
                  builder: (context, state) {
                    if (state.user != null) {
                      return Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ProfileImage(
                                      onPressed: () async {
                                        final newImage = await Utils().pickImage();
                                        setState(() {
                                          pickedImage = newImage;
                                        });
                                      },
                                      pickedImage: pickedImage,
                                    ),
                                    const SizedBox(height: 40),
                                    ProfileDetailsInformation(
                                      label: AppLocalizations.of(context)!.email,
                                      hintText: AppLocalizations.of(context)!.email,
                                      controller: _emailController,
                                      enabled: false,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Email is not empty";
                                        } else if (!Utils.isEmailValid(value)) {
                                          return "Invalid email";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    ProfileDetailsInformation(
                                      label: AppLocalizations.of(context)!.name,
                                      hintText: AppLocalizations.of(context)!.name,
                                      controller: _nameController,
                                    ),
                                    const SizedBox(height: 20),
                                    ProfileDetailsInformation(
                                      label: AppLocalizations.of(context)!.age,
                                      hintText: AppLocalizations.of(context)!.age,
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Age is not empty";
                                        } else if (int.tryParse(value) == null) {
                                          return "Invalid age";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.gender,
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyTextColor),
                                        ),
                                        Row(
                                          children: [
                                            ...List.generate(2, (index) {
                                              final thisGender = index == 0 ? Gender.male : Gender.female;
                                              final isSelected = thisGender == gender;
                                              final imageUrl = index == 0 ? AppAssets.imgMale : AppAssets.imgFemale;

                                              return Expanded(
                                                child: GenderCard(
                                                    imageUrl: imageUrl,
                                                    gender: thisGender.toShortString(),
                                                    isSelected: isSelected,
                                                    onTap: () {
                                                      setState(() {
                                                        gender = thisGender;
                                                      });
                                                    }),
                                              );
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          MyButton(
                            onPressed: _onUpdateUser,
                            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding),
                            borderRadius: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.save,
                                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.whiteColor)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          )),
    );
  }

  void _showSuccessDialog() {
    Utils().showSuccessDialog(
        context: context,
        icon: const MyIcon(
          icon: AppAssets.icProfileTick,
          colorFilter: ColorFilter.mode(AppColors.whiteColor, BlendMode.srcIn),
        ),
        description: "You have successfully updated your profile.",
        buttonText: "OK",
        onButtonPressed: () {
          Navigator.pop(context);
        });
  }

  _initValues() {
    final userState = context.read<UserBloc>().state;
    if (userState.user != null) {
      print("User: ${userState.user!.toJson()}");
      _nameController.text = userState.user!.name ?? "";
      _ageController.text = userState.user!.age?.toString() ?? "0";
      _emailController.text = userState.user!.email ?? "";
      gender = userState.user!.gender ?? Gender.notHave;
    }
  }

  void _onUpdateUser() {
    if (_formKey.currentState!.validate()) {
      Loading1Manager.instance.showLoadingDialog(context);

      context.read<UserBloc>().add(UpdateUser(
            name: _nameController.text,
            gender: gender,
            age: _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null,
            email: _emailController.text,
            image: pickedImage,
          ));
      // When update finished => The listener at the top will trigger to show a dialog
    }
  }
}

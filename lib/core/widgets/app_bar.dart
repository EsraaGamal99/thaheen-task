import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thaheen_task/core/cubit/locale/locale_cubit.dart';
import 'package:thaheen_task/core/extensions/sizedbox_extensions.dart';
import 'package:thaheen_task/core/theme/app_colors.dart';
import 'package:thaheen_task/core/translations/locale_keys.g.dart';
import 'package:thaheen_task/gen/assets.gen.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.rectangle.path),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                start: 16.w, end: 16.w, bottom: 40.h),
            child: Column(
              children: [
                verticalSpace(60.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.appName.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.language,
                          size: 28.sp, color: AppColor.orangColor),
                      onPressed: () {
                         context.read<LocaleCubit>().toggleLocale(context);
                      },
                    ),
                  ],
                ),
                verticalSpace(10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      horizontalSpace(8.w),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: LocaleKeys.searchCourses.tr(),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      horizontalSpace(8.w),
                      Icon(Icons.search,
                          color: AppColor.orangColor, size: 28.sp),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        verticalSpace(10.h)
      ],
    );
  }
}

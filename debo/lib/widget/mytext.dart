
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color.dart';
import '../utils/dimens.dart';

// ignore: must_be_immutable
class MyText extends StatelessWidget {
  String text;
  double? fontsizeNormal, fontsizeWeb;
  dynamic maxline, fontstyle, fontweight, textalign, multilanguage;
  Color color;
  dynamic overflow;
  bool? withShaderMask;

  MyText({
    super.key,
    required this.color,
    required this.text,
    this.fontsizeNormal,
    this.fontsizeWeb,
    this.maxline,
    this.multilanguage,
    this.overflow,
    this.textalign,
    this.fontweight,
    this.fontstyle,
    this.withShaderMask,
  });

  @override
  Widget build(BuildContext context) {
    if (multilanguage == true) {
      if (withShaderMask != null && withShaderMask == true) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorPrimary, colorPrimaryDark],
              tileMode: TileMode.mirror,
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            );
          },
          child: LocaleText(
            text,
            textAlign: textalign,
            overflow: overflow,
            maxLines: maxline,
            style: kIsWeb
                ? TextStyle(
                    fontSize: Dimens.isBigScreen(context)
                        ? fontsizeWeb
                        : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontweight,
                  )
                : GoogleFonts.inter(
                    fontSize: Dimens.isBigScreen(context)
                        ? fontsizeWeb
                        : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontweight,
                  ),
          ),
        );
      } else {
        return LocaleText(
          text,
          textAlign: textalign,
          overflow: overflow,
          maxLines: maxline,
          style: kIsWeb
              ? TextStyle(
                  fontSize: Dimens.isBigScreen(context)
                      ? fontsizeWeb
                      : fontsizeNormal,
                  fontStyle: fontstyle,
                  color: color,
                  fontWeight: fontweight,
                )
              : GoogleFonts.inter(
                  fontSize: Dimens.isBigScreen(context)
                      ? fontsizeWeb
                      : fontsizeNormal,
                  fontStyle: fontstyle,
                  color: color,
                  fontWeight: fontweight,
                ),
        );
      }
    } else {
      if (withShaderMask != null && withShaderMask == true) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorPrimary, colorPrimaryDark],
              tileMode: TileMode.mirror,
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            );
          },
          child: Text(
            text,
            textAlign: textalign,
            overflow: overflow,
            maxLines: maxline,
            style: kIsWeb
                ? TextStyle(
                    fontSize: Dimens.isBigScreen(context)
                        ? fontsizeWeb
                        : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontweight,
                  )
                : GoogleFonts.inter(
                    fontSize: Dimens.isBigScreen(context)
                        ? fontsizeWeb
                        : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontweight,
                  ),
          ),
        );
      } else {
        return Text(
          text,
          textAlign: textalign,
          overflow: overflow,
          maxLines: maxline,
          style: kIsWeb
              ? TextStyle(
                  fontSize: Dimens.isBigScreen(context)
                      ? fontsizeWeb
                      : fontsizeNormal,
                  fontStyle: fontstyle,
                  color: color,
                  fontWeight: fontweight,
                )
              : GoogleFonts.inter(
                  fontSize: Dimens.isBigScreen(context)
                      ? fontsizeWeb
                      : fontsizeNormal,
                  fontStyle: fontstyle,
                  color: color,
                  fontWeight: fontweight,
                ),
        );
      }
    }
  }
}

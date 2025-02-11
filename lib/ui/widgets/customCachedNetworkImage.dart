import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage(
      {super.key,
      required this.imageUrl,
      this.width,
      this.height,
      this.fit,
      this.color});

  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return imageUrl.endsWith('.svg')
        ? SvgPicture.network(
            imageUrl,
            fit: BoxFit.fill,
            width: width,
            height: height,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.accentColor, BlendMode.srcIn),
            placeholderBuilder: (BuildContext context) {
              return CustomSizedBox(
                width: width ?? 100,
                height: height ?? 100,
                child: const CustomSvgPicture('placeholder',
                    boxFit: BoxFit.contain),
              );
            },
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit ?? BoxFit.contain,
            color: color ,
            errorWidget: (BuildContext context, String url, error) {
              return CustomSizedBox(
                width: width,
                height: height,
                child: const CustomSvgPicture('noImageAvailable',
                    boxFit: BoxFit.contain),
              );
            },
            placeholder: (BuildContext context, String url) {
              return CustomSizedBox(
                width: width ?? 100,
                height: height ?? 100,
                child: const CustomSvgPicture('placeholder',
                    boxFit: BoxFit.contain),
              );
            },
          );
  }
}

import 'package:flutter/material.dart';

/// Reusable app logo widget that can be used across all screens
/// 
/// Usage examples:
/// - Full logo with text: AppLogo(size: 80)
/// - Logo only: AppLogo(size: 60, showText: false)
/// - Custom text color: AppLogo(size: 80, textColor: Colors.white)
class AppLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final Color? textColor;

  const AppLogo({
    Key? key,
    this.size,
    this.showText = true,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 60.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Option 1: Using an image asset (recommended for custom logos)
        // Uncomment this when you add your logo image to assets/images/logo.png
        /*
        Image.asset(
          'assets/images/logo.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image not found
            return Icon(
              Icons.favorite,
              size: logoSize,
              color: Theme.of(context).primaryColor,
            );
          },
        ),
        */
        
        // Option 2: Using an icon (current implementation - works without assets)
        Icon(
          Icons.favorite,
          size: logoSize,
          color: Theme.of(context).primaryColor,
        ),
        
        if (showText) ...[
          SizedBox(height: logoSize * 0.13),
          Text(
            'आंगनवाड़ी',
            style: TextStyle(
              fontSize: logoSize * 0.25,
              fontWeight: FontWeight.bold,
              color: textColor ?? Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: logoSize * 0.05),
          Text(
            'Anganwadi Care',
            style: TextStyle(
              fontSize: logoSize * 0.22,
              fontWeight: FontWeight.w600,
              color: textColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small logo for AppBar - horizontal layout
class AppBarLogo extends StatelessWidget {
  final Color? iconColor;
  final Color? textColor;

  const AppBarLogo({
    Key? key,
    this.iconColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Option 1: Using image (uncomment when you add logo to assets)
        /*
        Image.asset(
          'assets/images/logo.png',
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.favorite,
              size: 28,
              color: iconColor ?? Theme.of(context).primaryColor,
            );
          },
        ),
        */
        
        // Option 2: Using icon (current - works without assets)
        Icon(
          Icons.favorite,
          size: 28,
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'आंगनवाड़ी',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.black87,
              ),
            ),
            Text(
              'Anganwadi Care',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: (textColor ?? Colors.black87).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Circular logo - perfect for splash screens or profile pictures
class CircularAppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const CircularAppLogo({
    Key? key,
    this.size = 120,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.favorite,
          size: size * 0.5,
          color: iconColor ?? Colors.white,
        ),
      ),
    );
  }
}
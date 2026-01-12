import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLeading;
  final Color? backgroundColor;
  final bool useCustomStyle;
  final IconData? leftIcon;
  final VoidCallback? onLeftPressed;
  final IconData? rightIcon;
  final VoidCallback? onRightPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLeading = false,
    this.backgroundColor,
    this.useCustomStyle = false,
    this.leftIcon,
    this.onLeftPressed,
    this.rightIcon,
    this.onRightPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Custom style for car details (gradient background with circular buttons)
    if (useCustomStyle) {
      return Container(
        color: backgroundColor ?? const Color.fromARGB(255, 219, 240, 255),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leftIcon != null)
                  _CircularButton(
                    icon: leftIcon!,
                    onPressed: onLeftPressed ?? () => Navigator.pop(context),
                  )
                else
                  const SizedBox(width: 36),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (rightIcon != null)
                  _CircularButton(
                    icon: rightIcon!,
                    onPressed: onRightPressed ?? () {},
                  )
                else
                  const SizedBox(width: 36),
              ],
            ),
          ),
        ),
      );
    }

    // Standard AppBar style
    return AppBar(
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      automaticallyImplyLeading: showLeading,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircularButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

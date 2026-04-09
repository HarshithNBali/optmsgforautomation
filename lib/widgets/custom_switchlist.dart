import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:flutter/cupertino.dart';

class CustomSwitchListTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final EdgeInsetsGeometry contentPadding;
  final Widget? secondary;

  const CustomSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.contentPadding = const EdgeInsets.only(left: 16.0, right: 10.0, top: 5.0),
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: contentPadding,
      child: Column(
        children: [
          Row(
            children: [
              if (secondary != null) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: secondary!,
                ),
                const SizedBox(width: 14.5),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.drawerTitle(context),
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: CupertinoSwitch(
                  value: value,
                  activeTrackColor: AppStyles.clickableTextColor,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space8),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/user_avatars.dart';
import '../../theme/fluidlearn_colors.dart';
import '../../widgets/user_avatar_view.dart';

/// Profile photo picker — 3-column grid of local avatar PNGs.
class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({super.key, this.initialIndex});

  final int? initialIndex;

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  late int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIndex;
    if (initial != null && initial >= 0 && initial < UserAvatars.count) {
      _selectedIndex = initial;
    } else {
      _selectedIndex = null;
    }
  }

  void _finish() {
    Navigator.of(context).pop(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Photo',
          style: TextStyle(
            color: FluidLearnColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _selectedIndex == null ? null : _finish,
            child: Text(
              'Finish',
              style: TextStyle(
                color: _selectedIndex == null
                    ? FluidLearnColors.brandBlueMuted(0.35)
                    : FluidLearnColors.brandBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
        ),
        itemCount: UserAvatars.count,
        itemBuilder: (context, index) {
          final selected = _selectedIndex == index;
          return LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = constraints.maxWidth;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? FluidLearnColors.brandBlue
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: FluidLearnColors.brandBlue.withValues(
                                alpha: 0.22,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(selected ? 3 : 0),
                    child: UserAvatarView(
                      avatarIndex: index,
                      size: cellSize - (selected ? 6 : 0),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

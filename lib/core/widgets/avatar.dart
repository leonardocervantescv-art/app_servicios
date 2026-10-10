import 'package:flutter/material.dart';
import 'package:manocerca/core/theme/colors.dart';

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final bool online;
  const Avatar({super.key, required this.name, this.size = 56, this.online = false});

  static const _palette = [
    [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
    [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
    [Color(0xFF14B8A6), Color(0xFF134E4A)],
    [Color(0xFFF59E0B), Color(0xFF78350F)],
    [Color(0xFFEC4899), Color(0xFF831843)],
  ];

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ');
    final initials = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'
        : parts[0].substring(0, 1);
    final colors = _palette[name.length % _palette.length];
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: C.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: C.card, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

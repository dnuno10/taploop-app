import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../models/team_member_model.dart';

const _allMembersValue = '__all_members__';

class TeamMemberFilterDropdown extends StatelessWidget {
  final List<TeamMemberModel> members;
  final String? selectedMemberId;
  final ValueChanged<String?> onChanged;
  final String allLabel;

  const TeamMemberFilterDropdown({
    super.key,
    required this.members,
    required this.selectedMemberId,
    required this.onChanged,
    this.allLabel = 'Todos',
  });

  @override
  Widget build(BuildContext context) {
    final selectedMember = selectedMemberId == null
        ? null
        : members.cast<TeamMemberModel?>().firstWhere(
            (member) => member?.id == selectedMemberId,
            orElse: () => null,
          );
    final label = selectedMember?.name.trim().isNotEmpty == true
        ? selectedMember!.name
        : allLabel;

    return PopupMenuButton<String>(
      tooltip: 'Filtrar por miembro',
      position: PopupMenuPosition.under,
      color: context.bgCard,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        onChanged(value == _allMembersValue ? null : value);
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: _allMembersValue,
          child: _DropdownItem(
            label: allLabel,
            selected: selectedMemberId == null,
          ),
        ),
        ...members.map(
          (member) => PopupMenuItem<String>(
            value: member.id,
            child: _DropdownItem(
              label: member.name.trim().isNotEmpty
                  ? member.name
                  : 'Miembro sin nombre',
              selected: selectedMemberId == member.id,
            ),
          ),
        ),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: context.bgCard,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.borderStrongSoft, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final String label;
  final bool selected;

  const _DropdownItem({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 18,
          color: selected ? AppColors.primary : context.textMuted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

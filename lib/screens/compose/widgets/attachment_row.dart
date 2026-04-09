import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/compose/compose_riverpod/compose_state.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:flutter/material.dart';

/// Horizontal scrollable row of attachment cards for compose.
/// Matches the view email attachment card style with an X remove icon
/// instead of a download icon.
class AttachmentRow extends StatelessWidget {
  final List<ComposeAttachment> attachments;
  final ValueChanged<int> onRemove;

  const AttachmentRow({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: attachments.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return _AttachmentCard(
              attachment: attachments[index],
              onRemove: () => onRemove(index),
            );
          },
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final ComposeAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentCard({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        color: context.colors.outlineVariant,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        onTap: () {
          // TODO: open attachment preview — same as view email
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Row(
            children: [
              // File type icon
              _buildFileIcon(context),
              const SizedBox(width: 8),
              // Name + size
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      attachment.fileName,
                      style: AppTypography.attachmentMeta(context)
                          .copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CommonService().formatFileSize(attachment.sizeBytes),
                      style: AppTypography.attachmentSize(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Upload progress or remove button
              if (attachment.isUploading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: attachment.uploadProgress > 0
                        ? attachment.uploadProgress
                        : null,
                    strokeWidth: 2,
                  ),
                )
              else
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRemove,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    final ext = attachment.fileType.toLowerCase();
    IconData icon;
    Color color;
    switch (ext) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
      case 'doc' || 'docx':
        icon = Icons.description;
        color = Colors.blue;
      case 'xls' || 'xlsx' || 'csv':
        icon = Icons.table_chart;
        color = Colors.green;
      case 'jpg' || 'jpeg' || 'png' || 'gif' || 'webp':
        icon = Icons.image;
        color = Colors.orange;
      case 'mp4' || 'mov' || 'avi':
        icon = Icons.videocam;
        color = Colors.purple;
      default:
        icon = Icons.insert_drive_file;
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Icon(icon, size: 28, color: color);
  }
}

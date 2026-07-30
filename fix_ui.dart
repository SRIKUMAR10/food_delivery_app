import 'dart:io';

void main() {
  print('Restoring Track_Order_page_ui.dart...');
  var res = Process.runSync('git', ['checkout', 'lib/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart']);
  if (res.exitCode != 0) {
    print('Failed to git checkout. Please run: git checkout lib/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart manually first, then run this script again.');
    return;
  }
  
  var file = File('lib/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart');
  var content = file.readAsStringSync();
  
  print('Applying default case fix...');
  content = content.replaceFirst(
    '      default:\n        return const Color(0xFFF0F0F0);\n      case TrackingStatus.cancelled:\n        return Colors.red;',
    '      case TrackingStatus.cancelled:\n        return Colors.red;\n      default:\n        return const Color(0xFFF0F0F0);'
  );
  
  print('Adding Cancel Button definition...');
  var cancelButtonCode = '''
  Widget _buildCancelButton(BuildContext context, TrackOrderLoaded state) {
    bool isCancelled = state.trackingSteps.any((step) => step.status == TrackingStatus.cancelled);
    bool isPreparingOrLater = state.trackingSteps.length > 1 &&
        (state.trackingSteps[1].status == TrackingStatus.current ||
         state.trackingSteps[1].status == TrackingStatus.completed);

    if (isCancelled || isPreparingOrLater) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<TrackOrderBloc>().add(CancelOrderEvent(state.orderId));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFE52121),
            side: const BorderSide(color: Color(0xFFE52121)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Cancel Order',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

''';
  if (!content.contains('_buildCancelButton(')) {
    content = content.replaceFirst('  Widget _buildMobileLayout(BuildContext context) {', cancelButtonCode + '  Widget _buildMobileLayout(BuildContext context) {');
  }

  print('Adding Cancel Button to Mobile Layout...');
  content = content.replaceFirst(
    '                _buildDeliveryPartnerCard(context, state),\n                const SizedBox(height: 20),\n                _buildUserInfo(context, state),',
    '                _buildDeliveryPartnerCard(context, state),\n                _buildCancelButton(context, state),\n                const SizedBox(height: 20),\n                _buildUserInfo(context, state),'
  );

  print('Adding Cancel Button to Desktop Layout...');
  content = content.replaceFirst(
    '                            _buildDesktopDeliveryPartnerCard(context, state),\n                          ],\n                        ),\n                      ),\n                    ),\n                  ],\n                ),\n                const SizedBox(height: 24),\n                _buildDesktopUserInfo(context, state),',
    '                            _buildDesktopDeliveryPartnerCard(context, state),\n                            _buildCancelButton(context, state),\n                          ],\n                        ),\n                      ),\n                    ),\n                  ],\n                ),\n                const SizedBox(height: 24),\n                _buildDesktopUserInfo(context, state),'
  );

  file.writeAsStringSync(content);
  print('Successfully patched Track_Order_page_ui.dart!');
}

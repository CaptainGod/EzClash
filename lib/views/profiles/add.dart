import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile() async {
    appController.addProfileFormFile();
  }

  Future<void> _handleAddProfileFormURL(String url) async {
    appController.addProfileFormURL(url);
  }

  Future<void> _toScan() async {
    if (system.isDesktop) {
      appController.addProfileFormQrCode();
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAddProfileFormURL(url);
      });
    }
  }

  Future<void> _toAdd() async {
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        value: '',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('').trim();
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip('').trim();
          }
          return null;
        },
      ),
    );
    if (url != null) {
      _handleAddProfileFormURL(url);
    }
  }

  Future<void> _toAddFromSubscriptionCode() async {
    final code = await globalState.showCommonDialog<String>(
      child: const SubscriptionCodeDialog(),
    );
    if (code != null) {
      appController.addProfileFromSubscriptionCode(code);
    }
  }

  @override
  Widget build(context) {
    return ListView(
      children: [
        ListItem(
          leading: const Icon(Icons.qr_code_sharp),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: _toScan,
        ),
        ListItem(
          leading: const Icon(Icons.upload_file_sharp),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: _handleAddProfileFormFile,
        ),
        ListItem(
          leading: const Icon(Icons.cloud_download_sharp),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: _toAdd,
        ),
        ListItem(
          leading: const Icon(Icons.pin_sharp),
          title: Text(appLocalizations.subscriptionCode),
          subtitle: Text(appLocalizations.subscriptionCodeDesc),
          onTap: _toAddFromSubscriptionCode,
        ),
      ],
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final _urlController = TextEditingController();

  Future<void> _handleAddProfileFormURL() async {
    final url = _urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: _urlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionCodeDialog extends StatefulWidget {
  const SubscriptionCodeDialog({super.key});

  @override
  State<SubscriptionCodeDialog> createState() => _SubscriptionCodeDialogState();
}

class _SubscriptionCodeDialogState extends State<SubscriptionCodeDialog> {
  final _codeController = TextEditingController();
  final _prefixController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _prefixController.text = appController.subscriptionPrefix;
    _codeController.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  Future<void> _handleSubmit() async {
    final code = _codeController.text.trim();
    if (code.length != 8 || !RegExp(r'^\d{8}$').hasMatch(code)) {
      setState(() => _errorText = appLocalizations.subscriptionCodeTip);
      return;
    }
    final prefix = _prefixController.text.trim();
    if (prefix.isNotEmpty) {
      appController.updateSubscriptionPrefix(prefix);
    }
    Navigator.of(context).pop<String>(code);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.importFromSubscriptionCode,
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              controller: _prefixController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.subscriptionPrefix,
              ),
            ),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.subscriptionCodeHint,
                errorText: _errorText,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

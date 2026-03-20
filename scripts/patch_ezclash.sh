#!/usr/bin/env bash
# =============================================================================
# EzClash Patch Script
# Apply all EzClash customizations on top of a fresh FlClash clone.
# Usage: bash scripts/patch_ezclash.sh [--prefix "https://..."]
# =============================================================================
set -euo pipefail

# ---------- configurable defaults --------------------------------------------
APP_NAME="EzClash"
APP_ID="com.captaingod.ezclash"
DEFAULT_PREFIX="https://1814840116.v.123pan.cn/1814840116/"
GITHUB_USER="CaptainGod"

# parse optional --prefix argument
while [[ $# -gt 0 ]]; do
  case $1 in
    --prefix) DEFAULT_PREFIX="$2"; shift 2 ;;
    *) shift ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

echo "▶ EzClash patch starting in: $ROOT"

# =============================================================================
# 1. pubspec.yaml — description + material_color_utilities
# =============================================================================
echo "  [1/9] pubspec.yaml"
sed -i '' \
  "s|^description:.*|description: EzClash - Multi-platform proxy client based on FlClash/ClashMeta, with subscription code support.|" \
  pubspec.yaml
# Ensure material_color_utilities constraint works with Flutter 3.41+
if grep -q 'material_color_utilities: \^0\.11' pubspec.yaml; then
  sed -i '' 's/material_color_utilities: \^0\.11\.[0-9]*/material_color_utilities: ^0.13.0/' pubspec.yaml
fi

# =============================================================================
# 2. Android — applicationId + remove Firebase
# =============================================================================
echo "  [2/9] Android: applicationId + remove Firebase"

# app/build.gradle.kts
sed -i '' \
  "s|applicationId = \"com.follow.clash\"|applicationId = \"$APP_ID\"|" \
  android/app/build.gradle.kts

# Add storeType = "PKCS12" to signingConfig if not already present
if ! grep -q 'storeType = "PKCS12"' android/app/build.gradle.kts; then
  sed -i '' \
    's/keyPassword = mKeyPassword/keyPassword = mKeyPassword\n                storeType = "PKCS12"/' \
    android/app/build.gradle.kts
fi

# Comment out Firebase plugins in app/build.gradle.kts
sed -i '' \
  's|^\(    id("com.google.gms.google-services")\)|    // \1|; s|^\(    id("com.google.firebase.crashlytics")\)|    // \1|' \
  android/app/build.gradle.kts
sed -i '' \
  's|^\(    implementation(platform(libs.firebase.bom))\)|    // \1|; s|^\(    implementation(libs.firebase.crashlytics.ndk)\)|    // \1|; s|^\(    implementation(libs.firebase.analytics)\)|    // \1|' \
  android/app/build.gradle.kts

# settings.gradle.kts
sed -i '' \
  's|^\(    id("com.google.gms.google-services").*\)|    // \1|; s|^\(    id("com.google.firebase.crashlytics").*\)|    // \1|' \
  android/settings.gradle.kts

# common/build.gradle.kts
sed -i '' \
  's|^\(    implementation(platform(libs.firebase.bom))\)|    // \1|; s|^\(    implementation(libs.firebase.crashlytics.ndk)\)|    // \1|; s|^\(    implementation(libs.firebase.analytics)\)|    // \1|' \
  android/common/build.gradle.kts

# GlobalState.kt — remove Firebase imports and body
GLOBAL_STATE="android/common/src/main/java/com/follow/clash/common/GlobalState.kt"
sed -i '' \
  '/^import com.google.firebase/d' \
  "$GLOBAL_STATE"
python3 - "$GLOBAL_STATE" <<'PYEOF'
import sys, re
path = sys.argv[1]
content = open(path).read()
content = re.sub(
    r'fun setCrashlytics\(enable: Boolean\) \{.*?\}',
    'fun setCrashlytics(enable: Boolean) {\n        // Firebase Crashlytics removed in EzClash\n    }',
    content, flags=re.DOTALL
)
open(path, 'w').write(content)
PYEOF

# AndroidManifest — app label
sed -i '' \
  's|android:label="FlClash">|android:label="EzClash">|' \
  android/app/src/main/AndroidManifest.xml
sed -i '' \
  's|android:name=".TileService".*|&|; /android:name=".TileService"/{n; n; s|android:label="FlClash"|android:label="EzClash"|}' \
  android/app/src/main/AndroidManifest.xml 2>/dev/null || true

# =============================================================================
# 3. macOS
# =============================================================================
echo "  [3/9] macOS"
sed -i '' "s|PRODUCT_NAME = FlClash|PRODUCT_NAME = $APP_NAME|" \
  macos/Runner/Configs/AppInfo.xcconfig
# DMG packaging
sed -i '' "s|FlClash|$APP_NAME|g" \
  macos/packaging/dmg/make_config.yaml

# =============================================================================
# 4. Windows
# =============================================================================
echo "  [4/9] Windows"
sed -i '' "s|L\"FlClash\"|L\"$APP_NAME\"|" \
  windows/runner/main.cpp
sed -i '' \
  "s|project(FlClash |project($APP_NAME |; s|set(BINARY_NAME \"FlClash\")|set(BINARY_NAME \"$APP_NAME\")|" \
  windows/CMakeLists.txt
sed -i '' \
  "s|\"FileDescription\", \"FlClash\"|\"FileDescription\", \"$APP_NAME\"|; s|\"OriginalFilename\", \"FlClash.exe\"|\"OriginalFilename\", \"$APP_NAME.exe\"|" \
  windows/runner/Runner.rc
sed -i '' \
  "s|app_name: FlClash|app_name: $APP_NAME|; s|display_name: FlClash|display_name: $APP_NAME|; s|executable_name: FlClash.exe|executable_name: $APP_NAME.exe|; s|output_base_file_name: FlClash.exe|output_base_file_name: $APP_NAME.exe|; s|publisher: chen08209|publisher: $GITHUB_USER|; s|publisher_url:.*FlClash|publisher_url: https://github.com/$GITHUB_USER/$APP_NAME|" \
  windows/packaging/exe/make_config.yaml
sed -i '' \
  "s|'FlClash.exe'|'$APP_NAME.exe'|" \
  windows/packaging/exe/inno_setup.iss

# =============================================================================
# 5. Linux
# =============================================================================
echo "  [5/9] Linux"
sed -i '' "s|set(BINARY_NAME \"FlClash\")|set(BINARY_NAME \"$APP_NAME\")|" \
  linux/CMakeLists.txt
sed -i '' "s|gtk_header_bar_set_title(header_bar, \"FlClash\")|gtk_header_bar_set_title(header_bar, \"$APP_NAME\")|" \
  linux/runner/my_application.cc
for f in linux/packaging/deb/make_config.yaml \
          linux/packaging/appimage/make_config.yaml \
          linux/packaging/rpm/make_config.yaml; do
  sed -i '' "s|FlClash|$APP_NAME|g" "$f"
done

# =============================================================================
# 6. setup.dart — appName
# =============================================================================
echo "  [6/9] setup.dart"
sed -i '' "s|static String get appName => 'FlClash'|static String get appName => '$APP_NAME'|" \
  setup.dart

# =============================================================================
# 7. CI workflow
# =============================================================================
echo "  [7/9] .github/workflows/build.yaml"
# Flutter version
sed -i '' 's/flutter-version: 3\.35\.7/flutter-version: 3.41.5/g' \
  .github/workflows/build.yaml
# Repo reference
sed -i '' \
  "s|chen08209/FlClash/releases/latest|$GITHUB_USER/$APP_NAME/releases/latest|" \
  .github/workflows/build.yaml
# Remove SERVICE_JSON line
sed -i '' '/echo.*SERVICE_JSON.*google-services/d' \
  .github/workflows/build.yaml
# Changelog job permissions
if ! grep -q 'contents: write' .github/workflows/build.yaml; then
  sed -i '' '/^  changelog:/{n; s/^    runs-on:/    permissions:\n      contents: write\n    runs-on:/;}' \
    .github/workflows/build.yaml
fi

# =============================================================================
# 8. i18n — add subscription code strings
# =============================================================================
echo "  [8/9] i18n strings"

add_i18n_en() {
  if ! grep -q '"subscriptionCode"' arb/intl_en.arb; then
    sed -i '' 's|"fileDesc": "Directly upload profile",|"fileDesc": "Directly upload profile",\
  "subscriptionCode": "Subscription Code",\
  "subscriptionCodeDesc": "Import profile using a short subscription code",\
  "importFromSubscriptionCode": "Import from Subscription Code",\
  "subscriptionCodeHint": "Enter 8-digit subscription code",\
  "subscriptionPrefix": "Subscription URL Prefix",\
  "subscriptionCodeTip": "Please enter a valid 8-digit numeric code",|' \
      arb/intl_en.arb
  fi
}

add_i18n_zh() {
  if ! grep -q '"subscriptionCode"' arb/intl_zh_CN.arb; then
    sed -i '' 's|"fileDesc": "直接上传配置文件",|"fileDesc": "直接上传配置文件",\
  "subscriptionCode": "订阅码",\
  "subscriptionCodeDesc": "使用8位订阅码获取配置文件",\
  "importFromSubscriptionCode": "通过订阅码导入",\
  "subscriptionCodeHint": "输入8位数字订阅码",\
  "subscriptionPrefix": "订阅前缀URL",\
  "subscriptionCodeTip": "请输入有效的8位数字订阅码",|' \
      arb/intl_zh_CN.arb
  fi
}
add_i18n_en
add_i18n_zh

# messages_en.dart
if ! grep -q 'subscriptionCode' lib/l10n/intl/messages_en.dart; then
  sed -i '' 's|"fileDesc": MessageLookupByLibrary.simpleMessage("Directly upload profile"),|"fileDesc": MessageLookupByLibrary.simpleMessage("Directly upload profile"),\
    "subscriptionCode": MessageLookupByLibrary.simpleMessage("Subscription Code"),\
    "subscriptionCodeDesc": MessageLookupByLibrary.simpleMessage("Import profile using a short subscription code"),\
    "importFromSubscriptionCode": MessageLookupByLibrary.simpleMessage("Import from Subscription Code"),\
    "subscriptionCodeHint": MessageLookupByLibrary.simpleMessage("Enter 8-digit subscription code"),\
    "subscriptionPrefix": MessageLookupByLibrary.simpleMessage("Subscription URL Prefix"),\
    "subscriptionCodeTip": MessageLookupByLibrary.simpleMessage("Please enter a valid 8-digit numeric code"),|' \
    lib/l10n/intl/messages_en.dart
fi

# messages_zh_CN.dart
if ! grep -q 'subscriptionCode' lib/l10n/intl/messages_zh_CN.dart; then
  sed -i '' 's|"fileDesc": MessageLookupByLibrary.simpleMessage("直接上传配置文件"),|"fileDesc": MessageLookupByLibrary.simpleMessage("直接上传配置文件"),\
    "subscriptionCode": MessageLookupByLibrary.simpleMessage("订阅码"),\
    "subscriptionCodeDesc": MessageLookupByLibrary.simpleMessage("使用8位订阅码获取配置文件"),\
    "importFromSubscriptionCode": MessageLookupByLibrary.simpleMessage("通过订阅码导入"),\
    "subscriptionCodeHint": MessageLookupByLibrary.simpleMessage("输入8位数字订阅码"),\
    "subscriptionPrefix": MessageLookupByLibrary.simpleMessage("订阅前缀URL"),\
    "subscriptionCodeTip": MessageLookupByLibrary.simpleMessage("请输入有效的8位数字订阅码"),|' \
    lib/l10n/intl/messages_zh_CN.dart
fi

# l10n.dart getters
if ! grep -q 'subscriptionCode' lib/l10n/l10n.dart; then
  python3 - lib/l10n/l10n.dart <<'PYEOF'
import sys
path = sys.argv[1]
content = open(path).read()
insert = '''
  String get subscriptionCode {
    return Intl.message('Subscription Code', name: 'subscriptionCode', desc: '', args: []);
  }

  String get subscriptionCodeDesc {
    return Intl.message('Import profile using a short subscription code', name: 'subscriptionCodeDesc', desc: '', args: []);
  }

  String get importFromSubscriptionCode {
    return Intl.message('Import from Subscription Code', name: 'importFromSubscriptionCode', desc: '', args: []);
  }

  String get subscriptionCodeHint {
    return Intl.message('Enter 8-digit subscription code', name: 'subscriptionCodeHint', desc: '', args: []);
  }

  String get subscriptionPrefix {
    return Intl.message('Subscription URL Prefix', name: 'subscriptionPrefix', desc: '', args: []);
  }

  String get subscriptionCodeTip {
    return Intl.message('Please enter a valid 8-digit numeric code', name: 'subscriptionCodeTip', desc: '', args: []);
  }
'''
marker = "  /// `Name`"
content = content.replace(marker, insert + marker, 1)
open(path, 'w').write(content)
PYEOF
fi

# =============================================================================
# 9. Dart source — config model, controller, add view
# =============================================================================
echo "  [9/9] Dart source files"

# --- lib/models/config.dart: add subscriptionPrefix ---
if ! grep -q 'subscriptionPrefix' lib/models/config.dart; then
  sed -i '' \
    "s|@Default(true) bool showTrayTitle,|@Default(true) bool showTrayTitle,\n    @Default('$DEFAULT_PREFIX')\n    String subscriptionPrefix,|" \
    lib/models/config.dart
fi

# --- lib/controller.dart: add 3 methods after addProfileFormQrCode ---
if ! grep -q 'addProfileFromSubscriptionCode' lib/controller.dart; then
  python3 - lib/controller.dart "$DEFAULT_PREFIX" <<'PYEOF'
import sys
path, prefix = sys.argv[1], sys.argv[2]
content = open(path).read()
insert = f'''
  String get subscriptionPrefix {{
    return _ref.read(appSettingProvider).subscriptionPrefix;
  }}

  void updateSubscriptionPrefix(String prefix) {{
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(subscriptionPrefix: prefix));
  }}

  Future<void> addProfileFromSubscriptionCode(String code) async {{
    final url = '${{subscriptionPrefix}}$code';
    addProfileFormURL(url);
  }}
'''
marker = '  void reorder(List<Profile> profiles) {'
content = content.replace(marker, insert + '\n' + marker, 1)
open(path, 'w').write(content)
PYEOF
fi

# --- lib/views/profiles/add.dart: replace entire file ---
if ! grep -q 'SubscriptionCodeDialog' lib/views/profiles/add.dart; then
  cat > lib/views/profiles/add.dart << 'DARTEOF'
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
              onSubmitted: (_) => _handleAddProfileFormURL(),
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
    if (_errorText != null) setState(() => _errorText = null);
  }

  Future<void> _handleSubmit() async {
    final code = _codeController.text.trim();
    if (code.length != 8 || !RegExp(r'^\d{8}$').hasMatch(code)) {
      setState(() => _errorText = appLocalizations.subscriptionCodeTip);
      return;
    }
    final prefix = _prefixController.text.trim();
    if (prefix.isNotEmpty) appController.updateSubscriptionPrefix(prefix);
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
DARTEOF
fi

# =============================================================================
# Done — run build_runner to regenerate freezed code
# =============================================================================
echo ""
echo "✅ All patches applied!"
echo ""
echo "Next steps:"
echo "  1. flutter pub get"
echo "  2. dart run build_runner build --delete-conflicting-outputs"
echo "  3. git add -A && git commit -m 'chore: apply EzClash patches'"

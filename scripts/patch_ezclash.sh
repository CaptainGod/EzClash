#!/usr/bin/env bash
# =============================================================================
# EzClash Patch Script
# Apply all EzClash customizations on top of a fresh FlClash clone.
# Usage: bash scripts/patch_ezclash.sh [--prefix "https://..."]
# Works on both macOS and Linux (GNU sed).
# =============================================================================
set -euo pipefail

# ---------- configurable defaults --------------------------------------------
APP_NAME="EzClash"
APP_ID="com.captaingod.ezclash"
DEFAULT_PREFIX="https://1814840116.v.123pan.cn/1814840116/"
GITHUB_USER="CaptainGod"

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

# ---------- cross-platform sed -i --------------------------------------------
_sedi() {
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

# =============================================================================
# 1. pubspec.yaml — description + material_color_utilities
# =============================================================================
echo "  [1/10] pubspec.yaml"
_sedi \
  "s|^description:.*|description: EzClash - Multi-platform proxy client based on FlClash/ClashMeta, with subscription code support.|" \
  pubspec.yaml
if grep -q 'material_color_utilities: \^0\.11' pubspec.yaml; then
  _sedi 's/material_color_utilities: \^0\.11\.[0-9]*/material_color_utilities: ^0.13.0/' pubspec.yaml
fi

# =============================================================================
# 2. Android — applicationId + remove Firebase
# =============================================================================
echo "  [2/10] Android: applicationId + remove Firebase"

# app/build.gradle.kts
_sedi \
  "s|applicationId = \"com.follow.clash\"|applicationId = \"$APP_ID\"|" \
  android/app/build.gradle.kts

if ! grep -q 'storeType = "PKCS12"' android/app/build.gradle.kts; then
  _sedi \
    's/keyPassword = mKeyPassword/keyPassword = mKeyPassword\n                storeType = "PKCS12"/' \
    android/app/build.gradle.kts
fi

_sedi \
  's|^\(    id("com.google.gms.google-services")\)|    // \1|; s|^\(    id("com.google.firebase.crashlytics")\)|    // \1|' \
  android/app/build.gradle.kts
_sedi \
  's|^\(    implementation(platform(libs.firebase.bom))\)|    // \1|; s|^\(    implementation(libs.firebase.crashlytics.ndk)\)|    // \1|; s|^\(    implementation(libs.firebase.analytics)\)|    // \1|' \
  android/app/build.gradle.kts

# settings.gradle.kts
_sedi \
  's|^\(    id("com.google.gms.google-services").*\)|    // \1|; s|^\(    id("com.google.firebase.crashlytics").*\)|    // \1|' \
  android/settings.gradle.kts

# common/build.gradle.kts
_sedi \
  's|^\(    implementation(platform(libs.firebase.bom))\)|    // \1|; s|^\(    implementation(libs.firebase.crashlytics.ndk)\)|    // \1|; s|^\(    implementation(libs.firebase.analytics)\)|    // \1|' \
  android/common/build.gradle.kts

# GlobalState.kt — remove Firebase imports and body
GLOBAL_STATE="android/common/src/main/java/com/follow/clash/common/GlobalState.kt"
_sedi '/^import com.google.firebase/d' "$GLOBAL_STATE"
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
_sedi 's|android:label="FlClash">|android:label="EzClash">|' \
  android/app/src/main/AndroidManifest.xml

# =============================================================================
# 3. macOS
# =============================================================================
echo "  [3/10] macOS"
_sedi "s|PRODUCT_NAME = FlClash|PRODUCT_NAME = $APP_NAME|" \
  macos/Runner/Configs/AppInfo.xcconfig
_sedi "s|FlClash|$APP_NAME|g" macos/packaging/dmg/make_config.yaml

# =============================================================================
# 4. Windows
# =============================================================================
echo "  [4/10] Windows"
_sedi "s|L\"FlClash\"|L\"$APP_NAME\"|" windows/runner/main.cpp
_sedi \
  "s|project(FlClash |project($APP_NAME |; s|set(BINARY_NAME \"FlClash\")|set(BINARY_NAME \"$APP_NAME\")|" \
  windows/CMakeLists.txt
_sedi \
  "s|\"FileDescription\", \"FlClash\"|\"FileDescription\", \"$APP_NAME\"|; s|\"OriginalFilename\", \"FlClash.exe\"|\"OriginalFilename\", \"$APP_NAME.exe\"|" \
  windows/runner/Runner.rc
_sedi \
  "s|app_name: FlClash|app_name: $APP_NAME|; s|display_name: FlClash|display_name: $APP_NAME|; s|executable_name: FlClash.exe|executable_name: $APP_NAME.exe|; s|output_base_file_name: FlClash.exe|output_base_file_name: $APP_NAME.exe|; s|publisher: chen08209|publisher: $GITHUB_USER|; s|publisher_url:.*FlClash|publisher_url: https://github.com/$GITHUB_USER/$APP_NAME|" \
  windows/packaging/exe/make_config.yaml
_sedi "s|'FlClash.exe'|'$APP_NAME.exe'|" windows/packaging/exe/inno_setup.iss

# =============================================================================
# 5. Linux
# =============================================================================
echo "  [5/10] Linux"
_sedi "s|set(BINARY_NAME \"FlClash\")|set(BINARY_NAME \"$APP_NAME\")|" linux/CMakeLists.txt
_sedi "s|gtk_header_bar_set_title(header_bar, \"FlClash\")|gtk_header_bar_set_title(header_bar, \"$APP_NAME\")|" \
  linux/runner/my_application.cc
for f in linux/packaging/deb/make_config.yaml \
          linux/packaging/appimage/make_config.yaml \
          linux/packaging/rpm/make_config.yaml; do
  _sedi "s|FlClash|$APP_NAME|g" "$f"
done

# =============================================================================
# 6. setup.dart — appName
# =============================================================================
echo "  [6/10] setup.dart"
_sedi "s|static String get appName => 'FlClash'|static String get appName => '$APP_NAME'|" setup.dart

# =============================================================================
# 7. CI workflow — Flutter version + remove Firebase + version auto-sync
# =============================================================================
echo "  [7/10] .github/workflows/build.yaml"
_sedi 's/flutter-version: 3\.35\.7/flutter-version: 3.41.5/g' .github/workflows/build.yaml
_sedi \
  "s|chen08209/FlClash/releases/latest|$GITHUB_USER/$APP_NAME/releases/latest|" \
  .github/workflows/build.yaml
_sedi '/echo.*SERVICE_JSON.*google-services/d' .github/workflows/build.yaml

# Add permissions to changelog job if missing
if ! grep -q 'contents: write' .github/workflows/build.yaml; then
  _sedi '/^  changelog:/{n; s/^    runs-on:/    permissions:\n      contents: write\n    runs-on:/;}' \
    .github/workflows/build.yaml
fi

# Add version auto-sync step (sets pubspec version from git tag before build)
if ! grep -q 'Sync version from git tag' .github/workflows/build.yaml; then
  python3 - .github/workflows/build.yaml <<'PYEOF'
import sys
path = sys.argv[1]
content = open(path).read()
step = """\
      - name: Sync version from git tag
        shell: bash
        run: |
          TAG="${{ github.ref_name }}"
          VERSION="${TAG#v}"
          BUILD=$(date +%Y%m%d%H)
          sed -i "s/^version: .*/version: ${VERSION}+${BUILD}/" pubspec.yaml
          echo "pubspec version set to ${VERSION}+${BUILD}"

"""
marker = "      - name: Get Flutter Dependency"
if marker in content:
    content = content.replace(marker, step + marker, 1)
open(path, 'w').write(content)
PYEOF
fi

# =============================================================================
# 8. App icon — replace FlClash vector with EzClash cat mascot
# =============================================================================
echo "  [8/10] App icons"

MASTER_ICON="$SCRIPT_DIR/icons/master.png"
ICON_BG="#7DBAEC"

# Fix Android adaptive icon XMLs:
# - Remove <monochrome> element (incompatible with bitmap foreground)
# - Delete old FlClash vector foreground XML
for xml in android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml \
            android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml; do
  [ -f "$xml" ] && _sedi '/<monochrome/d' "$xml"
done
rm -f android/app/src/main/res/drawable/ic_launcher_foreground.xml

# Update Android launcher background color
cat > android/app/src/main/res/values/ic_launcher_background.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#7DBAEC</color>
</resources>
EOF

if [ ! -f "$MASTER_ICON" ]; then
  echo "    ⚠️  $MASTER_ICON not found — skipping icon file generation"
  echo "    Copy EzClash 1024×1024 PNG to scripts/icons/master.png and re-run"
else
  # Ensure ImageMagick is available
  MAGICK=""
  if command -v magick &>/dev/null; then
    MAGICK="magick"
  elif command -v convert &>/dev/null; then
    MAGICK="convert"
  elif command -v apt-get &>/dev/null; then
    echo "    Installing ImageMagick…"
    sudo apt-get install -y -q imagemagick
    MAGICK="convert"
  fi

  if [ -z "$MAGICK" ]; then
    echo "    ⚠️  ImageMagick not found — skipping icon file generation"
  else
    ICON_TMP="$(mktemp -d)"

    # Android adaptive foreground: 288px image centered on 432px blue canvas
    # (keeps full image visible inside the adaptive icon safe zone)
    "$MAGICK" -size 432x432 xc:"$ICON_BG" \
      \( "$MASTER_ICON" -resize "288x288" \) \
      -gravity center -composite \
      android/app/src/main/res/drawable/ic_launcher_foreground.webp

    # Android mipmap densities
    for folder_sz in "mipmap-mdpi:48" "mipmap-hdpi:72" "mipmap-xhdpi:96" \
                     "mipmap-xxhdpi:144" "mipmap-xxxhdpi:192"; do
      folder="${folder_sz%%:*}"
      sz="${folder_sz##*:}"
      "$MAGICK" "$MASTER_ICON" -resize "${sz}x${sz}" \
        android/app/src/main/res/${folder}/ic_launcher.webp
      "$MAGICK" "$MASTER_ICON" -resize "${sz}x${sz}" \
        android/app/src/main/res/${folder}/ic_launcher_round.webp
    done

    # Playstore icon
    "$MAGICK" "$MASTER_ICON" -resize "512x512" \
      android/app/src/main/res/ic_launcher-playstore.png

    # macOS AppIcon
    for sz in 16 32 64 128 256 512 1024; do
      "$MAGICK" "$MASTER_ICON" -resize "${sz}x${sz}" \
        macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_${sz}.png
    done

    # Windows ICO (multi-size)
    for sz in 16 32 48 64 128 256; do
      "$MAGICK" "$MASTER_ICON" -resize "${sz}x${sz}" "$ICON_TMP/ico_${sz}.png"
    done
    "$MAGICK" "$ICON_TMP/ico_16.png" "$ICON_TMP/ico_32.png" "$ICON_TMP/ico_48.png" \
              "$ICON_TMP/ico_64.png" "$ICON_TMP/ico_128.png" "$ICON_TMP/ico_256.png" \
              windows/runner/resources/app_icon.ico

    # Linux asset
    "$MAGICK" "$MASTER_ICON" -resize "512x512" assets/images/icon.png

    rm -rf "$ICON_TMP"
    echo "    ✅ Icons generated"
  fi
fi

# =============================================================================
# 9. i18n — add subscription code strings
# =============================================================================
echo "  [9/10] i18n strings"

if ! grep -q '"subscriptionCode"' arb/intl_en.arb; then
  _sedi 's|"fileDesc": "Directly upload profile",|"fileDesc": "Directly upload profile",\
  "subscriptionCode": "Subscription Code",\
  "subscriptionCodeDesc": "Import profile using a short subscription code",\
  "importFromSubscriptionCode": "Import from Subscription Code",\
  "subscriptionCodeHint": "Enter 8-digit subscription code",\
  "subscriptionPrefix": "Subscription URL Prefix",\
  "subscriptionCodeTip": "Please enter a valid 8-digit numeric code",|' \
    arb/intl_en.arb
fi

if ! grep -q '"subscriptionCode"' arb/intl_zh_CN.arb; then
  _sedi 's|"fileDesc": "直接上传配置文件",|"fileDesc": "直接上传配置文件",\
  "subscriptionCode": "订阅码",\
  "subscriptionCodeDesc": "使用8位订阅码获取配置文件",\
  "importFromSubscriptionCode": "通过订阅码导入",\
  "subscriptionCodeHint": "输入8位数字订阅码",\
  "subscriptionPrefix": "订阅前缀URL",\
  "subscriptionCodeTip": "请输入有效的8位数字订阅码",|' \
    arb/intl_zh_CN.arb
fi

if ! grep -q 'subscriptionCode' lib/l10n/intl/messages_en.dart; then
  _sedi 's|"fileDesc": MessageLookupByLibrary.simpleMessage("Directly upload profile"),|"fileDesc": MessageLookupByLibrary.simpleMessage("Directly upload profile"),\
    "subscriptionCode": MessageLookupByLibrary.simpleMessage("Subscription Code"),\
    "subscriptionCodeDesc": MessageLookupByLibrary.simpleMessage("Import profile using a short subscription code"),\
    "importFromSubscriptionCode": MessageLookupByLibrary.simpleMessage("Import from Subscription Code"),\
    "subscriptionCodeHint": MessageLookupByLibrary.simpleMessage("Enter 8-digit subscription code"),\
    "subscriptionPrefix": MessageLookupByLibrary.simpleMessage("Subscription URL Prefix"),\
    "subscriptionCodeTip": MessageLookupByLibrary.simpleMessage("Please enter a valid 8-digit numeric code"),|' \
    lib/l10n/intl/messages_en.dart
fi

if ! grep -q 'subscriptionCode' lib/l10n/intl/messages_zh_CN.dart; then
  _sedi 's|"fileDesc": MessageLookupByLibrary.simpleMessage("直接上传配置文件"),|"fileDesc": MessageLookupByLibrary.simpleMessage("直接上传配置文件"),\
    "subscriptionCode": MessageLookupByLibrary.simpleMessage("订阅码"),\
    "subscriptionCodeDesc": MessageLookupByLibrary.simpleMessage("使用8位订阅码获取配置文件"),\
    "importFromSubscriptionCode": MessageLookupByLibrary.simpleMessage("通过订阅码导入"),\
    "subscriptionCodeHint": MessageLookupByLibrary.simpleMessage("输入8位数字订阅码"),\
    "subscriptionPrefix": MessageLookupByLibrary.simpleMessage("订阅前缀URL"),\
    "subscriptionCodeTip": MessageLookupByLibrary.simpleMessage("请输入有效的8位数字订阅码"),|' \
    lib/l10n/intl/messages_zh_CN.dart
fi

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
# 10. Dart source — config model, controller, add view
# =============================================================================
echo "  [10/10] Dart source files"

if ! grep -q 'subscriptionPrefix' lib/models/config.dart; then
  _sedi \
    "s|@Default(true) bool showTrayTitle,|@Default(true) bool showTrayTitle,\n    @Default('$DEFAULT_PREFIX')\n    String subscriptionPrefix,|" \
    lib/models/config.dart
fi

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
# Done
# =============================================================================
echo ""
echo "✅ All EzClash patches applied! (10/10)"
echo ""
echo "Next steps:"
echo "  1. flutter pub get"
echo "  2. dart run build_runner build --delete-conflicting-outputs"
echo "  3. git add -A && git commit -m 'chore: apply EzClash patches'"

## v0.9.5

- feat: replace app icon with EzClash cat mascot image

- - Replace all platform icons with the new EzClash cat+lightning mascot

- - Android: replace foreground vector XML with bitmap WebP (432×432),

-   update all mipmap densities (mdpi→xxxhdpi), fix adaptive icon XML

-   (remove monochrome reference), update background color to #7DBAEC

- - macOS: all AppIcon sizes (16→1024px)

- - Windows: multi-size ICO (16/32/48/64/128/256px)

- - Linux: assets/images/icon.png

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.9.4

- feat: new EzClash icon and bump version to 0.9.4

- - Replace all platform icons (Android WebP, macOS PNG, Windows ICO)

-   with new dark-navy/teal-E/lightning-bolt EzClash brand icon

- - Add scripts/gen_icon.py for reproducible icon generation

- - Bump pubspec version 0.9.0 → 0.9.4 to match latest release tag

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

- feat: add patch script and auto-sync workflow

- - scripts/patch_ezclash.sh: one-click script to apply all EzClash

-   customizations on a fresh FlClash clone

- - .github/workflows/sync_upstream.yml: weekly check for FlClash updates,

-   auto-creates PR with patches applied when new version detected

- - .upstream-version: tracks current upstream FlClash base (v0.8.92)

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.9.3

- fix: change Android applicationId and remove Firebase Crashlytics

- - applicationId: com.follow.clash -> com.captaingod.ezclash

-   (prevents signature conflict with FlClash on same device)

- - Remove Firebase imports and calls from GlobalState.kt

- - Remove Firebase dependencies from common/build.gradle.kts

-   (fixes IllegalStateException crash on first launch)

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

- fix: add contents:write permission to changelog job

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.9.2

- fix: update all packaging configs from FlClash to EzClash

- - setup.dart appName: EzClash (fixes .app path for macOS DMG)

- - macos/packaging/dmg/make_config.yaml: EzClash.app

- - windows/packaging/exe/make_config.yaml: EzClash.exe

- - windows/packaging/exe/inno_setup.iss: EzClash.exe process name

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.9.1

- feat: rename app to EzClash and bump version to 0.9.0

- - Update app display name on Android, macOS, Windows, Linux

- - Update Windows exe name to EzClash.exe

- - Update Linux binary name to EzClash

- - Update version to 0.9.0+2026032001

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.8.92-ez5

## v0.9.0

- fix: explicitly set storeType=PKCS12 for Android signing

- Fixes 'Tag number over 30 is not supported' error caused by

- BouncyCastle incompatibility with modern PKCS12 keystore format.

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.8.92-ez3

## v0.8.92-ez4

- fix: remove Firebase Crashlytics from Android build

- EzClash does not have its own Firebase project.

- Removing google-services and crashlytics plugins avoids

- the Malformed root json build failure.

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.8.92-ez2

- fix: upgrade Flutter to 3.41.5 in CI to match local SDK

- material_color_utilities 0.13.0 is pinned by Flutter 3.41.5,

- CI was using 3.35.7 which pins 0.11.1 causing version conflict.

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

## v0.8.92-ez1

- feat: add subscription code import method

- - Add subscriptionCode entry to AddProfileView (4th option after QR/File/URL)

- - Add SubscriptionCodeDialog with 8-digit numeric input and editable prefix field

- - Add addProfileFromSubscriptionCode() and updateSubscriptionPrefix() to controller

- - Persist custom prefix via AppSettingProps.subscriptionPrefix field

- - Add i18n strings for zh_CN and en

- - Fix CI workflow: update repo reference, remove fdroid/telegram steps

- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>

- Add sqlite store

- Optimize android quick action

- Optimize backup and restore

- Optimize more details

- Fix windows some issues

- Optimize overwrite handle

- Optimize access control page

- Optimize some details

- Fix android tile service

- Support append system DNS

- Fix some issues

- Fix some issues

- Optimize Windows service mode

- Update core

- Add android separates the core process

- Support core status check and force restart

- Optimize proxies page and access page

- Update flutter and pub dependencies

- Update go version

- Optimize more details

- Optimize desktop view

- Optimize logs, requests, connection pages

- Optimize windows tray auto hide

- Optimize some details

- Update core

- Fix windows tun issues

- Optimize android get system dns

- Optimize more details

- Support override script

- Support proxies search

- Support svg display

- Optimize config persistence

- Add some scenes auto close connections

- Update core

- Optimize more details

- Fix issues that TUN repeat failed to open.

- Fix windows service verify issues

- Add windows server mode start process verify

- Add linux deb dependencies

- Add backup recovery strategy select

- Support custom text scaling

- Optimize the display of different text scale

- Optimize windows setup experience

- Optimize startTun performance

- Optimize android tv experience

- Optimize default option

- Optimize computed text size

- Optimize hyperOS freeform window

- Add developer mode

- Update core

- Optimize more details

- Add issues template

- Optimize android vpn performance

- Add custom primary color and color scheme

- Add linux nad windows arm release

- Optimize requests and logs page

- Fix map input page delete issues

- Add rule override

- Update core

- Optimize more details

- Optimize dashboard performance

- Fix some issues

- Fix unselected proxy group delay issues

- Fix asn url issues

- Fix tab delay view issues

- Fix tray action issues

- Fix get profile redirect client ua issues

- Fix proxy card delay view issues

- Add Russian, Japanese adaptation

- Fix some issues

- Fix list form input view issues

- Fix traffic view issues

- Optimize performance

- Update core

- Optimize core stability

- Fix linux tun authority check error

- Fix some issues

- Fix scroll physics error

- Add windows storage corruption detection

- Fix core crash caused by windows resource manager restart

- Optimize logs, requests, access to pages

- Fix macos bypass domain issues

- Fix some issues

- Update popup menu

- Add file editor

- Fix android service issues

- Optimize desktop background performance

- Optimize android main process performance

- Optimize delay test

- Optimize vpn protect

- Update core

- Fix some issues

- Remake dashboard

- Optimize theme

- Optimize more details

- Update flutter version

- Support better window position memory

- Add windows arm64 and linux arm64 build script

- Optimize some details

- Remake desktop

- Optimize change proxy

- Optimize network check

- Fix fallback issues

- Optimize lots of details

- Update change.yaml

- Fix android tile issues

- Fix windows tray issues

- Support setting bypassDomain

- Update flutter version

- Fix android service issues

- Fix macos dock exit button issues

- Add route address setting

- Optimize provider view

- Update CHANGELOG.md

- Add android shortcuts

- Fix init params issues

- Fix dynamic color issues

- Optimize navigator animate

- Optimize window init

- Optimize fab

- Optimize save

- Fix the collapse issues

- Add fontFamily options

- Update core version

- Update flutter version

- Optimize ip check

- Optimize url-test

- Update release message

- Init auto gen changelog

- Fix windows tray issues

- Fix urltest issues

- Add auto changelog

- Fix windows admin auto launch issues

- Add android vpn options

- Support proxies icon configuration

- Optimize android immersion display

- Fix some issues

- Optimize ip detection

- Support android vpn ipv6 inbound switch

- Support log export

- Optimize more details

- Fix android system dns issues

- Optimize dns default option

- Fix some issues

- Update readme

- Fix build error2

- Fix build error

- Support desktop hotkey

- Support android ipv6 inbound

- Support android system dns

- fix some bugs

- Fix delete profile error

- Fix submit error 2

- Fix submit error

- Optimize DNS strategy

- Fix the problem that the tray is not displayed in some cases

- Optimize tray

- Update core

- Fix some error

- Fix tun update issues

- Add DNS override

- Fixed some bugs

- Optimize more detail

- Add Hosts override

- fix android tip error

- fix windows auto launch error

- Fix windows tray issues

- Optimize windows logic

- Optimize app logic

- Support windows administrator auto launch

- Support android close vpn

- Change flutter version

- Support profiles sort

- Support windows country flags display

- Optimize proxies page and profiles page columns

- Update flutter version

- Update version

- Update timeout time

- Update access control page

- Fix bug

- Optimize provider page

- Optimize delay test

- Support local backup and recovery

- Fix android tile service issues

- Fix linux core build error

- Add proxy-only traffic statistics

- Update core

- Optimize more details

- Add fdroid-repo

- Optimize proxies page

- Fix ua issues

- Optimize more details

- Fix windows build error

- Update app icon

- Fix desktop backup error

- Optimize request ua

- Change android icon

- Optimize dashboard

- Remove request validate certificate

- Sync core

- Fix windows error

- Fix setup.dart error

- Fix android system proxy not effective

- Add macos arm64

- Optimize proxies page

- Support mouse drag scroll

- Adjust desktop ui

- Revert "Fix android vpn issues"

- This reverts commit 891977408e6938e2acd74e9b9adb959c48c79988.

- Fix android vpn issues

- Fix android vpn issues

- Rollback partial modification

- Fix the problem that ui can't be synchronized when android vpn is occupied by an external

- Override default socksPort,port

- Fix fab issues

- Update version

- Fix the problem that vpn cannot be started in some cases

- Fix the problem that geodata url does not take effect

- Update ua

- Fix change outbound mode without check ip issues

- Separate android ui and vpn

- Fix url validate issues 2

- Add android hidden from the recent task

- Add geoip file

- Support modify geoData URL

- Fix url validate issues

- Fix check ip performance problem

- Optimize resources page

- Add ua selector

- Support modify test url

- Optimize android proxy

- Fix the error that async proxy provider could not selected the proxy

- Fix android proxy error

- Fix submit error

- Add windows tun

- Optimize android proxy

- Optimize change profile

- Update application ua

- Optimize delay test

- Fix android repeated request notification issues

- Fix memory overflow issues

- Optimize proxies expansion panel 2

- Fix android scan qrcode error

- Optimize proxies expansion panel

- Fix text error

- Optimize proxy

- Optimize delayed sorting performance

- Add expansion panel proxies page

- Support to adjust the proxy card size

- Support to adjust proxies columns number

- Fix autoRun show issues

- Fix Android 10 issues

- Optimize ip show

- Add intranet IP display

- Add connections page

- Add search in connections, requests

- Add keyword search in connections, requests, logs

- Add basic viewing editing capabilities

- Optimize update profile

- Update version

- Fix the problem of excessive memory usage in traffic usage.

- Add lightBlue theme color

- Fix start unable to update profile issues

- Fix flashback caused by process

- Add build version

- Optimize quick start

- Update system default option

- Update build.yml

- Fix android vpn close issues

- Add requests page

- Fix checkUpdate dark mode style error

- Fix quickStart error open app

- Add memory proxies tab index

- Support hidden group

- Optimize logs

- Fix externalController hot load error

- Add tcp concurrent switch

- Add system proxy switch

- Add geodata loader switch

- Add external controller switch

- Add auto gc on trim memory

- Fix android notification error

- Fix ipv6 error

- Fix android udp direct error

- Add ipv6 switch

- Add access all selected button

- Remove android low version splash

- Update version

- Add allowBypass

- Fix Android only pick .text file issues

- Fix search issues

- Fix LoadBalance, Relay load error

- Fix build.yml4

- Fix build.yml3

- Fix build.yml2

- Fix build.yml

- Add search function at access control

- Fix the issues with the profile add button to cover the edit button

- Adapt LoadBalance and Relay

- Add arm

- Fix android notification icon error

- Add one-click update all profiles

- Add expire show

- Temp remove tun mode

- Remove macos in workflow

- Change go version

- Update Version

- Fix tun unable to open

- Optimize delay test2

- Optimize delay test

- Add check ip

- add check ip request

- Fix the problem that the download of remote resources failed after GeodataMode was turned on, which caused the application to flash back.

- Fix edit profile error

- Fix quickStart change proxy error

- Fix core version

- Fix core version

- Update file_picker

- Add resources page

- Optimize more detail

- Add access selected sorted

- Fix notification duplicate creation issue

- Fix AccessControl click issue

- Fix Workflow

- Fix Linux unable to open

- Update README.md 3

- Create LICENSE

- Update README.md 2

- Update README.md

- Optimize workFlow

- optimize checkUpdate

- Fix submit error

- add WebDAV

- add Auto check updates

- Optimize more details

- optimize delayTest

- upgrade flutter version

- Update kernel

- Add import profile via QR code image

- Add compatibility mode and adapt clash scheme.

- update Version

- Reconstruction application proxy logic

- Fix Tab destroy error

- Optimize repeat healthcheck

- Optimize Direct mode ui

- Optimize Healthcheck

- Remove proxies position animation, improve performance

- Add Telegram Link

- Update healthcheck policy

- New Check URLTest

- Fix the problem of invalid auto-selection

- New Async UpdateConfig

- add changeProfileDebounce

- Update Workflow

- Fix ChangeProfile block

- Fix Release Message Error

- Update Selector 2

- Update Version

- Fix Proxies Select Error

- Fix the problem that the proxy group is empty in global mode.

- Fix the problem that the proxy group is empty in global mode.

- Add ProxyProvider2

- Add ProxyProvider

- Update Version

- Update ProxyGroup Sort

- Fix Android quickStart VpnService some problems

- Update version

- Set Android notification low importance

- Fix the issue that VpnService can't be closed correctly in special cases

- Fix the problem that TileService is not destroyed correctly in some cases

- Adjust tab animation defaults

- Add Telegram in README_zh_CN.md

- Add Telegram

- update mobile_scanner

- Initial commit

## v0.8.92

- Add sqlite store

- Optimize android quick action

- Optimize backup and restore

- Optimize more details

## v0.8.91

- Fix windows some issues

- Optimize overwrite handle

- Optimize access control page

- Optimize some details

## v0.8.90

- Fix android tile service

- Support append system DNS

- Fix some issues

- Update changelog

## v0.8.89

- Fix some issues

- Optimize Windows service mode

- Update core

- Update changelog

## v0.8.88

- Add android separates the core process

- Support core status check and force restart

- Optimize proxies page and access page

- Update flutter and pub dependencies

- Update go version

- Optimize more details

- Update changelog

## v0.8.87

- Optimize desktop view

- Optimize logs, requests, connection pages

- Optimize windows tray auto hide

- Optimize some details

- Update core

- Update changelog

## v0.8.86

- Fix windows tun issues

- Optimize android get system dns

- Optimize more details

- Update changelog

## v0.8.85

- Support override script

- Support proxies search

- Support svg display

- Optimize config persistence

- Add some scenes auto close connections

- Update core

- Optimize more details

## v0.8.84

- Fix windows service verify issues

- Update changelog

## v0.8.83

- Add windows server mode start process verify

- Add linux deb dependencies

- Add backup recovery strategy select

- Support custom text scaling

- Optimize the display of different text scale

- Optimize windows setup experience

- Optimize startTun performance

- Optimize android tv experience

- Optimize default option

- Optimize computed text size

- Optimize hyperOS freeform window

- Add developer mode

- Update core

- Optimize more details

- Add issues template

- Update changelog

## v0.8.82

- Optimize android vpn performance

- Add custom primary color and color scheme

- Add linux nad windows arm release

- Optimize requests and logs page

- Fix map input page delete issues

- Update changelog

## v0.8.81

- Add rule override

- Update core

- Optimize more details

- Update changelog

## v0.8.80

- Optimize dashboard performance

- Fix some issues

- Fix unselected proxy group delay issues

- Fix asn url issues

- Update changelog

## v0.8.79

- Fix tab delay view issues

- Fix tray action issues

- Fix get profile redirect client ua issues

- Fix proxy card delay view issues

- Add Russian, Japanese adaptation

- Fix some issues

- Update changelog

## v0.8.78

- Fix list form input view issues

- Fix traffic view issues

- Update changelog

## v0.8.77

- Optimize performance

- Update core

- Optimize core stability

- Fix linux tun authority check error

- Fix some issues

- Fix scroll physics error

- Update changelog

## v0.8.75

- Add windows storage corruption detection

- Fix core crash caused by windows resource manager restart

- Optimize logs, requests, access to pages

- Fix macos bypass domain issues

- Update changelog

## v0.8.74

- Fix some issues

- Update changelog

## v0.8.73

- Update popup menu

- Add file editor

- Fix android service issues

- Optimize desktop background performance

- Optimize android main process performance

- Optimize delay test

- Optimize vpn protect

- Update changelog

## v0.8.72

- Update core

- Fix some issues

- Update changelog

## v0.8.71

- Remake dashboard

- Optimize theme

- Optimize more details

- Update flutter version

- Update changelog

## v0.8.70

- Support better window position memory

- Add windows arm64 and linux arm64 build script

- Optimize some details

## v0.8.69

- Remake desktop

- Optimize change proxy

- Optimize network check

- Fix fallback issues

- Optimize lots of details

- Update change.yaml

- Fix android tile issues

- Fix windows tray issues

- Support setting bypassDomain

- Update flutter version

- Fix android service issues

- Fix macos dock exit button issues

- Add route address setting

- Optimize provider view

- Update changelog

- Update CHANGELOG.md

## v0.8.67

- Add android shortcuts

- Fix init params issues

- Fix dynamic color issues

- Optimize navigator animate

- Optimize window init

- Optimize fab

- Optimize save

## v0.8.66

- Fix the collapse issues

- Add fontFamily options

## v0.8.65

- Update core version

- Update flutter version

- Optimize ip check

- Optimize url-test

## v0.8.64

- Update release message

- Init auto gen changelog

- Fix windows tray issues

- Fix urltest issues

- Add auto changelog

- Fix windows admin auto launch issues

- Add android vpn options

- Support proxies icon configuration

- Optimize android immersion display

- Fix some issues

- Optimize ip detection

- Support android vpn ipv6 inbound switch

- Support log export

- Optimize more details

- Fix android system dns issues

- Optimize dns default option

- Fix some issues

- Update readme

## v0.8.60

- Fix build error2

- Fix build error

- Support desktop hotkey

- Support android ipv6 inbound

- Support android system dns

- fix some bugs

## v0.8.59

- Fix delete profile error

## v0.8.58

- Fix submit error 2

- Fix submit error

- Optimize DNS strategy

- Fix the problem that the tray is not displayed in some cases

- Optimize tray

- Update core

- Fix some error

## v0.8.57

- Fix tun update issues

- Add DNS override
- Fixed some bugs
- Optimize more detail

- Add Hosts override

## v0.8.56

- fix android tip error
- fix windows auto launch error

## v0.8.55

- Fix windows tray issues

- Optimize windows logic

- Optimize app logic

- Support windows administrator auto launch

- Support android close vpn

## v0.8.53

- Change flutter version

- Support profiles sort

- Support windows country flags display

- Optimize proxies page and profiles page columns

## v0.8.52

- Update flutter version

- Update version

- Update timeout time

- Update access control page

- Fix bug

## v0.8.51

- Optimize provider page

- Optimize delay test

- Support local backup and recovery

- Fix android tile service issues

## v0.8.49

- Fix linux core build error

- Add proxy-only traffic statistics

- Update core

- Optimize more details

- Merge pull request #140 from txyyh/main

- 添加自建 F-Droid 仓库相关 workflow
- Rename readme fingerprint

- Rename workflow deploy repo name

- Add download guide to README

- Add push release files to fdroid-repo

## v0.8.48

- Optimize proxies page

- Fix ua issues

- Optimize more details

## v0.8.47

- Fix windows build error

## v0.8.46

- Update app icon

- Fix desktop backup error

- Optimize request ua

- Change android icon

- Optimize dashboard

## v0.8.44

- Remove request validate certificate

- Sync core

## v0.8.43

- Fix windows error

## v0.8.42

- Fix setup.dart error

- Fix android system proxy not effective

- Add macos arm64

## v0.8.41

- Optimize proxies page

- Support mouse drag scroll

- Adjust desktop ui

- Revert "Fix android vpn issues"

- This reverts commit 891977408e6938e2acd74e9b9adb959c48c79988.

## v0.8.40

- Fix android vpn issues

- Fix android vpn issues

- Rollback partial modification

## v0.8.39

- Fix the problem that ui can't be synchronized when android vpn is occupied by an external

- Override default socksPort,port

## v0.8.38

- Fix fab issues

## v0.8.37

- Update version

- Fix the problem that vpn cannot be started in some cases

- Fix the problem that geodata url does not take effect

## v0.8.36

- Update ua

- Fix change outbound mode without check ip issues

- Separate android ui and vpn

- Fix url validate issues 2

- Add android hidden from the recent task

- Add geoip file

- Support modify geoData URL

## v0.8.35

- Fix url validate issues

- Fix check ip performance problem

- Optimize resources page

## v0.8.34

- Add ua selector

- Support modify test url

- Optimize android proxy

- Fix the error that async proxy provider could not selected the proxy

## v0.8.33

- Fix android proxy error

- Fix submit error

- Add windows tun

- Optimize android proxy

- Optimize change profile

- Update application ua

- Optimize delay test

## v0.8.32

- Fix android repeated request notification issues

## v0.8.31

- Fix memory overflow issues

## v0.8.30

- Optimize proxies expansion panel 2

- Fix android scan qrcode error

## v0.8.29

- Optimize proxies expansion panel

- Fix text error

## v0.8.28

- Optimize proxy

- Optimize delayed sorting performance

- Add expansion panel proxies page

- Support to adjust the proxy card size

- Support to adjust proxies columns number

- Fix autoRun show issues

- Fix Android 10 issues

- Optimize ip show

## v0.8.26

- Add intranet IP display

- Add connections page

- Add search in connections, requests

- Add keyword search in connections, requests, logs

- Add basic viewing editing capabilities

- Optimize update profile

## v0.8.25

- Update version

- Fix the problem of excessive memory usage in traffic usage.

- Add lightBlue theme color

- Fix start unable to update profile issues

- Fix flashback caused by process

## v0.8.23

- Add build version

- Optimize quick start

- Update system default option

## v0.8.22

- Update build.yml

- Fix android vpn close issues

- Add requests page

- Fix checkUpdate dark mode style error

- Fix quickStart error open app

- Add memory proxies tab index

- Support hidden group

- Optimize logs

- Fix externalController hot load error

## v0.8.21

- Add tcp concurrent switch

- Add system proxy switch

- Add geodata loader switch

- Add external controller switch

- Add auto gc on trim memory

- Fix android notification error

## v0.8.20

- Fix ipv6 error

- Fix android udp direct error

- Add ipv6 switch

- Add access all selected button

- Remove android low version splash

## v0.8.19

- Update version

- Add allowBypass

- Fix Android only pick .text file issues

## v0.8.18

- Fix search issues

## v0.8.17

- Fix LoadBalance, Relay load error

- Fix build.yml4

- Fix build.yml3

- Fix build.yml2

- Fix build.yml

- Add search function at access control

- Fix the issues with the profile add button to cover the edit button

- Adapt LoadBalance and Relay

- Add arm

- Fix android notification icon error

## v0.8.16

- Add one-click update all profiles
- Add expire show

## v0.8.15

- Temp remove tun mode

- Remove macos in workflow

- Change go version

## v0.8.14

- Update Version

- Fix tun unable to open

## v0.8.13

- Optimize delay test2

- Optimize delay test

- Add check ip

- add check ip request

## v0.8.12

- Fix the problem that the download of remote resources failed after GeodataMode was turned on, which caused the
  application to flash back.

- Fix edit profile error

- Fix quickStart change proxy error

- Fix core version

## v0.8.10

- Fix core version

## v0.8.9

- Update file_picker

- Add resources page

- Optimize more detail

- Add access selected sorted

- Fix notification duplicate creation issue

- Fix AccessControl click issue

## v0.8.7

- Fix Workflow

- Fix Linux unable to open

- Update README.md 3

- Create LICENSE
- Update README.md 2

- Update README.md

- Optimize workFlow

## v0.8.6

- optimize checkUpdate

## v0.8.5

- Fix submit error

## v0.8.4

- add WebDAV

- add Auto check updates

- Optimize more details

- optimize delayTest

## v0.8.2

- upgrade flutter version

## v0.8.1

- Update kernel
- Add import profile via QR code image

## v0.8.0

- Add compatibility mode and adapt clash scheme.

## v0.7.14

- update Version

- Reconstruction application proxy logic

## v0.7.13

- Fix Tab destroy error

## v0.7.12

- Optimize repeat healthcheck

## v0.7.11

- Optimize Direct mode ui

## v0.7.10

- Optimize Healthcheck

- Remove proxies position animation, improve performance
- Add Telegram Link

- Update healthcheck policy

- New Check URLTest

- Fix the problem of invalid auto-selection

## v0.7.8

- New Async UpdateConfig

- add changeProfileDebounce

- Update Workflow

- Fix ChangeProfile block

- Fix Release Message Error

## v0.7.7

- Update Selector 2

## v0.7.6

- Update Version

- Fix Proxies Select Error

## v0.7.5

- Fix the problem that the proxy group is empty in global mode.

- Fix the problem that the proxy group is empty in global mode.

## v0.7.4

- Add ProxyProvider2

## v0.7.3

- Add ProxyProvider

- Update Version

- Update ProxyGroup Sort

- Fix Android quickStart VpnService some problems

## v0.7.1

- Update version

- Set Android notification low importance

- Fix the issue that VpnService can't be closed correctly in special cases

- Fix the problem that TileService is not destroyed correctly in some cases

- Adjust tab animation defaults

- Add Telegram in README_zh_CN.md

- Add Telegram

## v0.7.0

- update mobile_scanner

- Initial commit
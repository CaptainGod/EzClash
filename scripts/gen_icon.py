#!/usr/bin/env python3
"""Generate EzClash app icon as SVG, then export to all required sizes."""
import os, subprocess, sys, shutil

# ── Icon SVG design ──────────────────────────────────────────────────────────
# Dark navy background, bold "Ez" in teal-cyan, lightning-bolt accent
SVG = """\
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0f2027"/>
      <stop offset="50%" stop-color="#203a43"/>
      <stop offset="100%" stop-color="#2c5364"/>
    </linearGradient>
    <linearGradient id="ez" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#00e5ff"/>
      <stop offset="100%" stop-color="#00b0cc"/>
    </linearGradient>
    <linearGradient id="bolt" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ffd600"/>
      <stop offset="100%" stop-color="#ff9500"/>
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>

  <!-- Background rounded square -->
  <rect width="1024" height="1024" rx="230" ry="230" fill="url(#bg)"/>

  <!-- Subtle inner ring -->
  <rect x="32" y="32" width="960" height="960" rx="210" ry="210"
        fill="none" stroke="rgba(0,229,255,0.12)" stroke-width="3"/>

  <!-- Big "E" letter -->
  <!-- Horizontal bars of E: top, middle, bottom; vertical stem on left -->
  <!-- Stem -->
  <rect x="195" y="240" width="110" height="544" rx="18" fill="url(#ez)" filter="url(#glow)"/>
  <!-- Top bar -->
  <rect x="195" y="240" width="480" height="110" rx="18" fill="url(#ez)" filter="url(#glow)"/>
  <!-- Middle bar (shorter) -->
  <rect x="195" y="457" width="380" height="110" rx="18" fill="url(#ez)" filter="url(#glow)"/>
  <!-- Bottom bar -->
  <rect x="195" y="674" width="480" height="110" rx="18" fill="url(#ez)" filter="url(#glow)"/>

  <!-- Lightning bolt accent (top-right area) -->
  <polygon points="700,240 640,460 690,460 630,720 770,450 710,450 760,240"
           fill="url(#bolt)" opacity="0.92" filter="url(#glow)"/>
</svg>
"""

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TMP  = "/tmp/ezclash_icon"
os.makedirs(TMP, exist_ok=True)

svg_path = f"{TMP}/master.svg"
png1024  = f"{TMP}/icon_1024.png"

with open(svg_path, "w") as f:
    f.write(SVG)

print("✅ SVG written")

# ── Convert SVG → 1024×1024 PNG via sips+qlmanage (macOS) ─────────────────
# sips cannot read SVG directly; use qlmanage to rasterise
def svg_to_png(src, dst, size=1024):
    """Use qlmanage (QuickLook) to render SVG to PNG, then resize with sips."""
    render_dir = f"{TMP}/ql"
    os.makedirs(render_dir, exist_ok=True)
    subprocess.run(
        ["qlmanage", "-t", "-s", str(size), "-o", render_dir, src],
        check=True, capture_output=True
    )
    # qlmanage writes <filename>.png in the output dir
    rendered = f"{render_dir}/{os.path.basename(src)}.png"
    if os.path.exists(rendered):
        shutil.copy(rendered, dst)
        return True
    return False

ok = svg_to_png(svg_path, png1024, 1024)
if not ok:
    print("qlmanage failed, trying rsvg-convert / inkscape …")
    sys.exit(1)

print(f"✅ Master PNG: {png1024}")

def resize(src, dst, size):
    subprocess.run(["sips", "-z", str(size), str(size), src, "--out", dst],
                   check=True, capture_output=True)

def to_webp(src, dst, size):
    """Resize then convert PNG→WebP using ImageMagick magick."""
    magick = shutil.which("magick") or shutil.which("convert")
    subprocess.run([magick, src, "-resize", f"{size}x{size}", dst],
                   check=True, capture_output=True)

# ── macOS AppIcon ─────────────────────────────────────────────────────────
mac_dir = f"{BASE}/macos/Runner/Assets.xcassets/AppIcon.appiconset"
for sz in [16, 32, 64, 128, 256, 512, 1024]:
    dst = f"{mac_dir}/app_icon_{sz}.png"
    resize(png1024, dst, sz)
    print(f"  macOS {sz}px → {dst}")

print("✅ macOS icons done")

# ── Android WebP mipmaps ──────────────────────────────────────────────────
android_sizes = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}
res_base = f"{BASE}/android/app/src/main/res"
for folder, sz in android_sizes.items():
    dst_dir = f"{res_base}/{folder}"
    for name in ["ic_launcher.webp", "ic_launcher_round.webp"]:
        to_webp(png1024, f"{dst_dir}/{name}", sz)
    print(f"  Android {folder} ({sz}px)")

# ic_launcher-playstore.png (512×512)
playstore = f"{res_base}/ic_launcher-playstore.png"
resize(png1024, playstore, 512)
print(f"  Android playstore icon → {playstore}")

print("✅ Android icons done")

# ── Windows ICO ───────────────────────────────────────────────────────────
# Need ImageMagick `convert`; fall back to Python3 ICO writer if absent
win_ico = f"{BASE}/windows/runner/resources/app_icon.ico"
magick_bin = shutil.which("magick") or shutil.which("convert")
if magick_bin:
    sizes = [16, 32, 48, 64, 128, 256]
    pngs  = []
    for sz in sizes:
        p = f"{TMP}/ico_{sz}.png"
        resize(png1024, p, sz)
        pngs.append(p)
    subprocess.run([magick_bin, *pngs, win_ico], check=True)
    print(f"✅ Windows ICO: {win_ico}")
else:
    # Minimal ICO writer (1-frame, 256×256 PNG stream — valid in Win Vista+)
    magick_bin = None
    import struct, io
    sz = 256
    tmp_256 = f"{TMP}/ico_256.png"
    resize(png1024, tmp_256, sz)
    with open(tmp_256, "rb") as f:
        png_data = f.read()
    # ICO header: ICONDIR(6) + ICONDIRENTRY(16) + PNG data
    ico_data  = struct.pack("<HHH", 0, 1, 1)          # reserved, type=1, count=1
    ico_data += struct.pack("<BBBBHHII",
                            0, 0, 0, 0,                # w=0(256), h=0(256), colorCount, reserved
                            1, 32,                     # planes, bitCount
                            len(png_data),             # size of image data
                            6 + 16)                    # offset to image data
    ico_data += png_data
    with open(win_ico, "wb") as f:
        f.write(ico_data)
    print(f"✅ Windows ICO (single-frame 256px fallback): {win_ico}")

# ── Linux (assets/images) ─────────────────────────────────────────────────
linux_icon = f"{BASE}/assets/images/icon.png"
if os.path.exists(os.path.dirname(linux_icon)):
    resize(png1024, linux_icon, 512)
    print(f"✅ Linux asset icon: {linux_icon}")

print("\n🎉 All icons generated successfully!")

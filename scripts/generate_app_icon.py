#!/usr/bin/env python3
"""Generate the FrostGram primary app icon artwork.

Produces a 1024x1024 RGBA PNG: a deep-indigo -> frost-blue vertical gradient
with a white six-fold snowflake. Used for:
  - AppIcon.icon/Assets/frostgram.png (Icon Composer primary icon)
  - IceCubesApp/Assets.xcassets/AppIconAlternate0-image.imageset/AppIcon.png
  - IceCubesApp/Assets.xcassets/AppIcon.solidimagestack layers
  - Images/AppIcon.png (marketing)

Local tooling only (Pillow); not a project dependency. Run from repo root:
  python scripts/generate_app_icon.py
"""

from pathlib import Path
import math

from PIL import Image, ImageDraw

SIZE = 1024
SS = 4  # supersampling factor

# Frost palette
TOP = (27, 31, 59)       # deep indigo
BOTTOM = (94, 156, 214)  # frost blue
WHITE = (245, 250, 255, 255)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def gradient(size):
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        c = lerp(TOP, BOTTOM, y / (size - 1))
        for x in range(size):
            px[x, y] = c
    return img


def snowflake(size, color):
    """Draw a six-fold snowflake centered in a square RGBA image."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = size / 2
    r_main = size * 0.40
    w_main = max(2, int(size * 0.022))
    w_branch = max(1, int(size * 0.014))

    for i in range(6):
        ang = math.radians(i * 60)
        dx, dy = math.cos(ang), math.sin(ang)
        # main spoke
        d.line(
            [(c - dx * r_main, c - dy * r_main), (c + dx * r_main, c + dy * r_main)],
            fill=color,
            width=w_main,
        )
        # two branch pairs per spoke
        for t, br in ((0.52, 0.16), (0.74, 0.11)):
            bx, by = c + dx * r_main * t, c + dy * r_main * t
            for sign in (-1, 1):
                bang = ang + sign * math.radians(55)
                bdx, bdy = math.cos(bang), math.sin(bang)
                d.line(
                    [(bx, by), (bx + bdx * r_main * br, by + bdy * r_main * br)],
                    fill=color,
                    width=w_branch,
                )
    # center hexagon dot
    r_dot = size * 0.045
    d.ellipse(
        [c - r_dot, c - r_dot, c + r_dot, c + r_dot],
        fill=color,
    )
    return img


def main():
    out = Path(__file__).resolve().parent.parent

    big = SIZE * SS
    base = gradient(big).convert("RGBA")
    flake = snowflake(big, WHITE)

    # Primary icon: gradient + soft glow + snowflake
    icon = base.copy()
    glow = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    r = big * 0.46
    gd.ellipse([big / 2 - r, big / 2 - r, big / 2 + r, big / 2 + r], fill=(255, 255, 255, 26))
    icon = Image.alpha_composite(icon, glow)
    icon = Image.alpha_composite(icon, flake)
    icon = icon.resize((SIZE, SIZE), Image.LANCZOS)

    targets = [
        out / "AppIcon.icon" / "Assets" / "frostgram.png",
        out / "IceCubesApp" / "Assets.xcassets" / "AppIconAlternate0-image.imageset" / "AppIcon.png",
        out / "Images" / "AppIcon.png",
    ]
    for t in targets:
        t.parent.mkdir(parents=True, exist_ok=True)
        icon.save(t, "PNG")
        print(f"wrote {t}")

    # Solid image stack (watch): background gradient + foreground flake
    bg = gradient(big).resize((SIZE, SIZE), Image.LANCZOS).convert("RGB")
    bg_target = (
        out / "IceCubesApp" / "Assets.xcassets" / "AppIcon.solidimagestack"
        / "Back.solidimagestacklayer" / "Content.imageset" / "Background.png"
    )
    bg.save(bg_target, "PNG")
    print(f"wrote {bg_target}")

    fg = snowflake(big, WHITE).resize((SIZE, SIZE), Image.LANCZOS)
    fg_target = (
        out / "IceCubesApp" / "Assets.xcassets" / "AppIcon.solidimagestack"
        / "Front.solidimagestacklayer" / "Content.imageset" / "Layer 1.png"
    )
    fg.save(fg_target, "PNG")
    print(f"wrote {fg_target}")


if __name__ == "__main__":
    main()

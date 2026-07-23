# Android app icon

The Android launcher icon is based on the `矢印あり` design on Page 2 of the
[Figma source](https://www.figma.com/design/jwh5zluClHeaaoCUKmctYy/%E7%84%A1%E9%A1%8C?node-id=8-50)
(node `8:51`).

- `app_icon_page2.png` is the 4x Figma export (`1240x1264`).
- `app_icon_foreground_page2.png` is the transparent foreground source. The
  cream background is intentionally excluded from this image.
- `app_icon_square_512.png` is the square reference used for generated Android
  launcher resources. The transparent bottom 24 pixels of the Figma export are
  cropped before resizing.
- Legacy launcher icons are stored as `mipmap-*/ic_launcher.png`.
- Android 8.0 and later use `mipmap-anydpi-v26/ic_launcher.xml` with the
  density-specific `ic_launcher_foreground.png` resources. The arrows, trunk,
  and leaves are centered inside the adaptive icon's `66dp / 108dp` safe
  region. The hill intentionally extends to the bottom edge so it can bleed
  naturally beneath circular and rounded masks. The cream color is supplied
  only by the background layer.
- `previews/adaptive_icon_circle.png` and
  `previews/adaptive_icon_rounded.png` are mask previews used to confirm that
  both arrowheads remain visible.

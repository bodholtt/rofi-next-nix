# default.nix
{
  stdenv,
  lib,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  flex,
  bison,
  glib,
  wayland-scanner,
  wayland,
  wayland-protocols,
  cairo,
  pango,
  gdk-pixbuf,
  librsvg,
  libxkbcommon,
  withX11 ? false,
  libxcb,
  xcb-util-cursor,
  xcbutil,
  xcbutilwm,
  libstartup_notification,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "rofi-next";
  version = "0-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "davatorium";
    repo = "rofi";
    rev = "1ad1df6b72d4c8b0e40e8ced1249ef8a8a6bc0ad";
    hash = "sha256-NlyPrTooEOsILhbq2dw08IHEp4YUKySK03PQReb+zc0=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    flex
    bison
    glib
    wayland-scanner
    makeWrapper
  ];

  buildInputs = [
    glib
    wayland
    wayland-protocols
    cairo
    pango
    gdk-pixbuf
    librsvg
    libxkbcommon
  ]
  ++ lib.optionals withX11 [
    libxcb
    xcb-util-cursor
    xcbutil
    xcbutilwm
    libstartup_notification
  ];

  mesonFlags = [
    (lib.mesonEnable "wayland" true)
    (lib.mesonEnable "xcb" withX11)
    (lib.mesonEnable "check" false)
  ];

  doCheck = false;

  postFixup = ''
    loaders="${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    test -f "$loaders" || { echo "gdk-pixbuf loaders.cache not found at $loaders" >&2; exit 1; }
    wrapProgram $out/bin/rofi --set GDK_PIXBUF_MODULE_FILE "$loaders"
  '';

  meta = {
    description = "A window switcher, Application launcher and dmenu replacement. (based on next branch)";
    homepage = "https://github.com/davatorium/rofi";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "rofi";
  };
}

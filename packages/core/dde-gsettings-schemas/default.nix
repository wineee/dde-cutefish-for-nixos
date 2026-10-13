{
  lib,
  runCommand,
  glib,
  dde-grand-search,
  startdde,
  deepin-desktop-schemas,
  gsettings-desktop-schemas,
  extraGSettingsOverrides ? "",
  extraGSettingsOverridePackages ? [ ],
}:

let
  # Every package listed here must ship a
  # `share/gsettings-schemas/<name>/glib-2.0/schemas` directory: the copy below
  # has no `-d` guard, so a package without one fails the build loudly instead
  # of being silently skipped.
  #
  # dde-session-shell, dde-file-manager, dde-tray-loader and
  # deepin-system-monitor ship no gschema XML — upstream deliberately does not
  # install it (session-shell only installs it in the legacy non-snipe Qt5
  # build; tray-loader's two *.gschema.xml are unreferenced leftovers from the
  # dconfig migration). Don't "fix" those packages to produce a schema.
  gsettingsOverridePackages = [
    dde-grand-search
    startdde
    deepin-desktop-schemas
    gsettings-desktop-schemas # dde-appearance need org.gnome.desktop.background
  ]
  ++ extraGSettingsOverridePackages;

in
# TODO: Having https://github.com/NixOS/nixpkgs/issues/54150 would supersede this
runCommand "nixos-gsettings-desktop-schemas" { preferLocalBuild = true; } ''
  data_dir="$out/share/gsettings-schemas/nixos-gsettings-overrides"
  schema_dir="$data_dir/glib-2.0/schemas"

  mkdir -p $schema_dir

  ${lib.concatMapStringsSep "\n" (
    pkg: "cp -rf \"${glib.getSchemaPath pkg}\"/*.xml \"$schema_dir\""
  ) gsettingsOverridePackages}

  chmod -R a+w "$data_dir"

  cat - > "$schema_dir/nixos-defaults.gschema.override" <<- EOF
  ${extraGSettingsOverrides}
  EOF

  ${glib.dev}/bin/glib-compile-schemas $schema_dir
''

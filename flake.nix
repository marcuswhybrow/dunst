{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux; 

    # Dunst complains if ini colour codes aren't wrapped in double quotes,
    # or if booleans aren't the word "true" or "false".
    toDunstIni = pkgs.lib.generators.toINI {
      mkKeyValue = key: value: let
        value' = if builtins.isBool value then (if value then "true" else "false")
          else if builtins.isString value then ''"${value}"''
          else toString value;
      in "    ${key} = ${value'}";
    };

    config = import ./config.nix { inherit pkgs; };

  in {
    overrides.x86_64-linux.dunst = extraConfig: let 
      finalConfig = pkgs.lib.recursiveUpdate config extraConfig;
      iniText = toDunstIni finalConfig;
      dunstrc = pkgs.writeText "dunstrc" iniText;

      tee = "${pkgs.coreutils}/bin/tee";
    in pkgs.runCommand "dunst" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/share
      ln -s ${dunstrc} $out/share/dunstrc 

      mkdir -p $out/bin
      ln -s ${pkgs.dunst}/bin/* $out/bin

      rm $out/bin/dunst
      makeWrapper ${pkgs.dunst}/bin/dunst $out/bin/dunst \
        --add-flags "-config $out/share/dunstrc"


      mkdir -p $out/lib/systemd/user
      ${tee} $out/lib/systemd/user/dunst.service << EOF
      [Unit]
      Description=Dunst notification daemon
      Documentation=man:dunst(1)
      PartOf=graphical-session.target

      [Service]
      Type=dbus
      BusName=org.freedesktop.Notifications
      ExecStart=$out/bin/dunst
      EOF


      mkdir -p $out/share/dbus-1/services
      tee $out/share/dbus-1/services/org.knopwob.dunst.service << EOF
      [D-BUS Service]
      Name=org.freedesktop.Notifications
      Exec=$out/bin/dunst
      SystemdService=dunst.service
      EOF


      mkdir -p $out/share/systemd/user
      ln -s $out/lib/systemd/user/dunst.service $out/share/systemd/user/dunst.service

    '';

    packages.x86_64-linux.dunst = self.overrides.x86_64-linux.dunst {};
    packages.x86_64-linux.default = self.packages.x86_64-linux.dunst;
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [
        pkgs.modd
      ];
    };
  };
}

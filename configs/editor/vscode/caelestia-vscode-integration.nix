{ vscode-utils, fetchurl, ... }:
vscode-utils.buildVscodeExtension rec {
  pname = "caelestia-integration";
  version = "1.2.0";
  vscodeExtName = pname;
  vscodeExtPublisher = "caelestia-dots";
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";
  # Имя файла ОБЯЗАНО заканчиваться на .vsix —
  # unpack-vsix-setup-hook проверяет: [[ "$curSrc" =~ \.vsix$ ]]
  src = fetchurl {
    name = "${vscodeExtUniqueId}.vsix";
    url = "https://github.com/caelestia-dots/caelestia/raw/refs/heads/main/vscode/caelestia-vscode-integration/caelestia-vscode-integration-${version}.vsix";
    sha256 = "sha256-iO10oObFrCYdu8Zq6KFyG50wfRmhiUjGjduF1HGpefs=";
  };
}

{ lib
, pkgs
, upstream
, ...
}:
let
  copilotPatchFilter = pkgs.writeText "copilot-patch.jq" ''
    .extensionEnabledApiProposals = (.extensionEnabledApiProposals // {})
    | .extensionEnabledApiProposals["GitHub.copilot"] = [
        "inlineCompletions",
        "inlineCompletionsNew",
        "inlineCompletionsAdditions",
        "textDocumentNotebook",
        "interactive",
        "interactiveUserActions",
        "terminalDataWriteEvent"
      ]
    | .extensionEnabledApiProposals["vscode.github-authentication"] = [
        "authIssuers",
        "authProviderSpecific"
      ]
    | .defaultAccount = (.defaultAccount // {
        "authenticationProvider": {
          "id": "github",
          "enterpriseProviderId": "github-enterprise",
          "enterpriseProviderConfig": "github.copilot.advanced.authProvider",
          "enterpriseProviderUriSetting": "github-enterprise.uri",
          "scopes": [
            ["user:email"],
            ["read:user"],
            ["read:user", "user:email", "repo", "workflow"]
          ]
        },
        "chatEntitlementUrl": "https://api.github.com/copilot_internal/user",
        "tokenEntitlementUrl": "https://api.github.com/copilot_internal/v2/token",
        "mcpRegistryDataUrl": "https://api.github.com/copilot/mcp_registry"
      })
    | .inheritAuthAccountPreference = (.inheritAuthAccountPreference // {
        "github.copilot": ["github.copilot-chat"]
      })
    | .extensionsGallery = {
        "nlsBaseUrl": "https://www.vscode-unpkg.net/_lp/",
        "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
        "itemUrl": "https://marketplace.visualstudio.com/items",
        "publisherUrl": "https://marketplace.visualstudio.com/publishers",
        "resourceUrlTemplate": "https://{publisher}.vscode-unpkg.net/{publisher}/{name}/{version}/{path}",
        "extensionUrlTemplate": "https://www.vscode-unpkg.net/_gallery/{publisher}/{name}/latest",
        "controlUrl": "https://main.vscode-cdn.net/extensions/marketplace.json",
        "mcpUrl": "https://main.vscode-cdn.net/mcp/servers.json"
      }
    | .extensionPublisherOrgs = ["microsoft", "github", "openai"]
    | .trustedExtensionPublishers = ["microsoft", "github", "openai"]
    | .extensionEnabledApiProposals["GitHub.copilot-chat"] = (
        .extensionEnabledApiProposals["GitHub.copilot-chat"] // [
          "interactive",
          "interactiveUserActions"
        ]
      )
    | .trustedExtensionAuthAccess = (.trustedExtensionAuthAccess // {})
    | .trustedExtensionAuthAccess.github = ((.trustedExtensionAuthAccess.github // []) + [
        "GitHub.copilot",
        "GitHub.copilot-chat"
      ] | unique)
    | .trustedExtensionAuthAccess["github-enterprise"] = ((.trustedExtensionAuthAccess["github-enterprise"] // []) + [
        "GitHub.copilot",
        "GitHub.copilot-chat"
      ] | unique)
  '';
in
{
  package = pkgs.vscodium.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.jq ];
    postInstall = (old.postInstall or "") + ''
      product_json=$(find "$out" -path "*/resources/app/product.json" -print -quit)
      if [ -n "$product_json" ]; then
        tmp=$(mktemp)
        ${pkgs.jq}/bin/jq -f ${copilotPatchFilter} "$product_json" > "$tmp"
        mv "$tmp" "$product_json"
      fi
    '';
  });

  # Using a profile other than default probably will break the caelestia-integration extension
  profiles.default = {
    userSettings =
      let
        settingsJsonPath =
          if upstream != null
          then "${upstream}/vscode/settings.json"
          else null;
      in
      if settingsJsonPath != null && builtins.pathExists settingsJsonPath then
        builtins.fromJSON (builtins.readFile settingsJsonPath)
      else
        lib.warn "caelestia-dots: upstream vscode/settings.json not found, using minimal defaults." {
          "workbench.colorTheme" = "Caelestia";
          "workbench.iconTheme" = "catppuccin-mocha";
        };

    keybindings =
      let
        keybindingsJsonPath =
          if upstream != null
          then "${upstream}/vscode/keybindings.json"
          else null;
      in
      if keybindingsJsonPath != null && builtins.pathExists keybindingsJsonPath then
        builtins.fromJSON (builtins.readFile keybindingsJsonPath)
      else
        lib.warn "caelestia-dots: upstream vscode/keybindings.json not found, using minimal defaults." [
          {
            command = "workbench.action.reloadWindow";
            key = "ctrl+shift+alt+r";
          }
        ];

    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc-icons
      llvm-vs-code-extensions.vscode-clangd
      charliermarsh.ruff
      esbenp.prettier-vscode
      github.vscode-pull-request-github
      github.copilot
      github.copilot-chat
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "qt-qml";
          publisher = "TheQtCompany";
          version = "1.11.0";
          hash = "sha256-sFFFWvoEiFqEvlX28rohbaKWZamhKa0iFIZJ6h7K77A=";
        };
      })
    ];
  };
}

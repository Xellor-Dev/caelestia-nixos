{
  lib,
  pkgs,
  ...
}: let
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
in {
  package = pkgs.vscodium.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.jq ];
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
    userSettings = {
      "[c]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
      "[cpp]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
      "[python]" = {
        "editor.defaultFormatter" = "charliermarsh.ruff";
      };
      "codeium.enableCodeLens" = false;
      "codeium.enableConfig" = {
        "*" = true;
        fish = true;
        qml = true;
      };
      "chat.disableAIFeatures" = false;
      "diffEditor.hideUnchangedRegions.enabled" = true;
      "doxdocgen.generic.boolReturnsTrueFalse" = false;
      "editor.codeActionsOnSave" = {
        "source.organizeImports" = "explicit";
      };
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.inlayHints.enabled" = "off";
      "editor.minimap.autohide" = "mouseover";
      "editor.multiCursorModifier" = "ctrlCmd";
      "editor.renderWhitespace" = "trailing";
      "editor.smoothScrolling" = true;
      "editor.suggestSelection" = "recentlyUsedByPrefix";
      "git.enableSmartCommit" = true;
      "github.copilot.enable" = {
        "*" = true;
      };
      "github.copilot.advanced.authProvider" = "github";
      "github.copilot.editor.enableAutoCompletions" = true;
      "github.copilot.chat.enabled" = true;
      "javascript.preferences.importModuleSpecifierEnding" = "minimal";
      "prettier.arrowParens" = "avoid";
      "prettier.printWidth" = 120;
      "prettier.tabWidth" = 4;
      "python.languageServer" = "Pylance";
      "qt-qml.doNotAskForQmllsDownload" = true;
      # "qt-qml.qmlls.additionalImportPaths" = ["/usr/lib/qt6/qml"];
      # "qt-qml.qmlls.customExePath" = "${pkgs.kdePackages.qtdeclarative}/qmlls";
      "ruff.lineLength" = 120;
      "security.workspace.trust.startupPrompt" = "always";
      "terminal.integrated.enableMultiLinePasteWarning" = "never";
      "terminal.integrated.smoothScrolling" = true;
      "typescript.preferences.importModuleSpecifierEnding" = "minimal";
      "typescript.preferences.preferTypeOnlyAutoImports" = true;
      "workbench.colorTheme" = "Caelestia";
      "workbench.iconTheme" = "catppuccin-mocha"; # This will not change automatically for light mode
      "workbench.list.smoothScrolling" = true;
    };

    keybindings = [
      {
        command = "workbench.action.reloadWindow";
        key = "ctrl+shift+alt+r";
      }
      {
        command = "workbench.action.previousEditor";
        key = "ctrl+pageup";
      }
      {
        command = "workbench.action.nextEditor";
        key = "ctrl+pagedown";
      }
      {
        command = "editor.action.moveLinesUpAction";
        key = "ctrl+shift+up";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        command = "editor.action.moveLinesDownAction";
        key = "ctrl+shift+down";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        command = "editor.action.insertCursorAbove";
        key = "shift+alt+up";
        when = "editorTextFocus";
      }
      {
        command = "editor.action.insertCursorBelow";
        key = "shift+alt+down";
        when = "editorTextFocus";
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

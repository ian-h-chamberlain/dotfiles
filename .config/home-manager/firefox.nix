{ ... }: {
  programs.firefox = {
    enable = true;
    # Use homebrew-packaged casks instead of nixpkgs
    package = null;

    # Hmm, this is scary... There seem to be a number of issues with profiles.ini +
    # home-manager, so maybe an alternative would be better...
    # https://github.com/nix-community/home-manager/issues/5717
    # https://github.com/nix-community/home-manager/issues/3323
    profiles.default-release = {
      id = 0;
      isDefault = true;
      path = "vx10kpch.default-release";
    };

    profiles.default = {
      id = 1;
      path = "180zuhmp.default";
    };

    # Use a "nix" profile to avoid overwriting existing profile, hopefully
    # gradually transitioning to this profile will be easier than cold turkey
    profiles.nix = {
      id = 2;

      containersForce = true;
      containers = {
        work = {
          id = 1;
          icon = "briefcase";
          color = "green";
        };
      };

      # We'll let firefox sync deal with extensions and most settings, but
      # some of those are not synced so set them here.
      settings = {
        "browser.aboutConfig.showWarning" = false;
        # Startup with new tab tools homepage
        # TODO: may need extensions.webextension.uuids in order to resolve this,
        # but idk if there is any additional danger to that ...
        # Check out https://github.com/WylieYYYY/nixos/blob/26eabf77e5f4d8d846d9a1eab6d380b9a6e97df0/user/browser.nix#L30-L41
        # `placements` would likely depend on these uuids as well.
        "browser.newtab.extensionControlled" = true;
        "browser.startup.homepage" = "moz-extension://cac42bf5-bf60-064a-b980-9752663ab966/newTab.xhtml";

        # Custom toolbar layouts, extension overflow etc. There are some "state"
        # elements in here too, unclear how important they are or not
        "browser.uiCustomization.state" = {
          # Current max version:
          # https://searchfox.org/mozilla-central/source/browser/components/customizableui/CustomizableUI.sys.mjs#60
          # How version upgrades are treated:
          # https://searchfox.org/mozilla-central/source/browser/components/customizableui/CustomizableUI.sys.mjs#445-727
          currentVersion = 20;
          dirtyAreaCache = [
            "addon-bar"
            "PersonalToolbar"
            "nav-bar"
            "TabsToolbar"
            "PanelUI-contents"
            "widget-overflow-fixed-list"
            "unified-extensions-area"
          ];
          newElementCount = 10;
          placements = {
            PersonalToolbar = [ "personal-bookmarks" ];
            TabsToolbar = [
              "firefox-view-button"
              "tabbrowser-tabs"
              "new-tab-button"
              "alltabs-button"
            ];
            nav-bar = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "home-button"
              "unified-back-forward-button"
              "urlbar-container"
              "downloads-button"
              "reload-button"
              "stop-button"
              "window-controls"
              "RIL_toolbar_button"
              "greasemonkey-tbb"
              "abp-toolbarbutton"
              "firebug-badged-button"
              "ublock0_raymondhill_net-browser-action"
              "keepassxc-browser_keepassxc_org-browser-action"
              "jid1-bycqofyfmbmd9a_jetpack-browser-action"
              "_59812185-ea92-4cca-8ab7-cfcacee81281_-browser-action"
              "fxa-toolbar-menu-button"
              "_e4a8a97b-f2ed-450b-b12d-ee082ba24781_-browser-action"
              "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action"
              "reset-pbm-toolbar-button"
              "unified-extensions-button"
            ];
            unified-extensions-area = [
              "fx_cast_matt_tf-browser-action"
              "dontfuckwithpaste_raim_ist-browser-action"
              "newtabtools_darktrojan_net-browser-action"
              "_1bb0deba-416a-4848-b119-9b94f37a268d_-browser-action"
              "_04188724-64d3-497b-a4fd-7caffe6eab29_-browser-action"
              "refinedhackernews_mihir_ch-browser-action"
              "firefox_tampermonkey_net-browser-action"
              "_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action"
              "_8b2164f4-fdb6-47eb-b692-312cc6d04f6b_-browser-action"
              "jid1-93cwpmrbvpjrqa_jetpack-browser-action"
              "treestyletab_piro_sakura_ne_jp-browser-action"
              "plugin_okta_com-browser-action"
              "damian_outlook_com-browser-action"
              "discussions_discu_eu-browser-action"
              "display-anchors_robwu_nl-browser-action"
              "firenvim_lacamb_re-browser-action"
              "_119be3f3-597c-4f6a-9caf-627ee431d374_-browser-action"
              "_1220100b-db8f-419f-9cd4-ed7a51cee7f3_-browser-action"
              "_5df6e133-f35d-4c62-885a-56387df22f6b_-browser-action"
              "_62391615-4d17-4257-919b-369c26a4e628_-browser-action"
              "_cca112bb-1ca6-4593-a2f1-38d808a19dda_-browser-action"
              "_e737d9cb-82de-4f23-83c6-76f70a82229c_-browser-action"
              "_testpilot-containers-browser-action"
              "cookieautodelete_kennydo_com-browser-action"
              "enhancerforyoutube_maximerf_addons_mozilla_org-browser-action"
              "idcac-pub_guus_ninja-browser-action"
              "leechblockng_proginosko_com-browser-action"
              "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
              "_c7e15941-6082-499c-a52c-94015f7eb5d1_-browser-action"
            ];
            widget-overflow-fixed-list = [ "library-button" ];
          };
          seen = [
            "abp-toolbarbutton"
            "developer-button"
            "ublock0_raymondhill_net-browser-action"
            "feed-button"
            "keepassxc-browser_keepassxc_org-browser-action"
            "treestyletab_piro_sakura_ne_jp-browser-action"
            "newtabtools_darktrojan_net-browser-action"
            "jid1-93cwpmrbvpjrqa_jetpack-browser-action"
            "jid1-bycqofyfmbmd9a_jetpack-browser-action"
            "_59812185-ea92-4cca-8ab7-cfcacee81281_-browser-action"
            "webide-button"
            "dontfuckwithpaste_raim_ist-browser-action"
            "fx_cast_matt_tf-browser-action"
            "_8b2164f4-fdb6-47eb-b692-312cc6d04f6b_-browser-action"
            "_e4a8a97b-f2ed-450b-b12d-ee082ba24781_-browser-action"
            "firefox_tampermonkey_net-browser-action"
            "_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action"
            "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action"
            "_1bb0deba-416a-4848-b119-9b94f37a268d_-browser-action"
            "_04188724-64d3-497b-a4fd-7caffe6eab29_-browser-action"
            "refinedhackernews_mihir_ch-browser-action"
            "plugin_okta_com-browser-action"
            "save-to-pocket-button"
            "damian_outlook_com-browser-action"
            "discussions_discu_eu-browser-action"
            "display-anchors_robwu_nl-browser-action"
            "firenvim_lacamb_re-browser-action"
            "_119be3f3-597c-4f6a-9caf-627ee431d374_-browser-action"
            "_1220100b-db8f-419f-9cd4-ed7a51cee7f3_-browser-action"
            "_5df6e133-f35d-4c62-885a-56387df22f6b_-browser-action"
            "_62391615-4d17-4257-919b-369c26a4e628_-browser-action"
            "_cca112bb-1ca6-4593-a2f1-38d808a19dda_-browser-action"
            "_e737d9cb-82de-4f23-83c6-76f70a82229c_-browser-action"
            "_testpilot-containers-browser-action"
            "cookieautodelete_kennydo_com-browser-action"
            "enhancerforyoutube_maximerf_addons_mozilla_org-browser-action"
            "idcac-pub_guus_ninja-browser-action"
            "leechblockng_proginosko_com-browser-action"
            "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
            "_c7e15941-6082-499c-a52c-94015f7eb5d1_-browser-action"
          ];
        };
      };
    };
  };
}

{ lib
, osConfig
, pkgs
, ...
}: {
  programs.git = {
    enable = true;
    userName = "fentas";
    userEmail = "jan.guth@gmail.com";
    extraConfig = {
      init = { defaultBranch = "main"; };
      github.user = "fentas";
      core.editor = "nvim";
      pull.rebase = false;
    };
  };
}

_: {
  programs.git = {
    enable = true;
    userName = "fentas";
    userEmail = "jan.guth@gmail.com";
    extraConfig = {
      init = { defaultBranch = "main"; };
      core.editor = "nvim";
      pull.rebase = false;
    };
  };
}

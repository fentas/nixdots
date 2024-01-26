<h1 align="center">
<a href='#'><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px"/></a>
  <br>
  <br>
  <div>
    <a href="https://github.com/fentas/nixdots/issues">
        <img src="https://img.shields.io/github/issues/fentas/nixdots?color=fab387&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/fentas/nixdots/stargazers">
        <img src="https://img.shields.io/github/stars/fentas/nixdots?color=ca9ee6&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/fentas/nixdots/blob/master/LICENSE">
        <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=ca9ee6&colorA=313244&colorB=cba6f7"/>
    </a>
    <br>
    </div>
   </h1>
   <br>

<div align="center">
<h1>
❄️ NixOS dotfiles ❄️
</h1>
</div>
<h2 align="center">NixOS system configuration. Feel free to explore!</h2>

## Shoutout to:

- [AlphaTechnolog](https://github.com/AlphaTechnolog/nixdots)
- [Eriim's](https://github.com/erictossell/nixflakes)
- [IogaMaster](https://github.com/IogaMaster)
- [linuxmobile](https://github.com/linuxmobile)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NotAShelf](https://github.com/NotAShelf/nyx)
- [notusknot](https://github.com/notusknot)
- [Siduck76](https://github.com/siduck76/nvchad/)
- [Sioodmy](https://github.com/sioodmy/dotfiles)
- [ZerotoNix](https://zero-to-nix.com)

<hr>

```mint
⠀⠀   🌸 Setup / Hyprland 🌸
 -----------------------------------

 ╭─ Distro  -> NixOS
 ├─ Editor  -> Neovim
 ├─ Browser -> Firefox 
 ├─ Shell   -> ZSH
 ╰─ Resource Monitor -> Btop

 ╭─ Model -> DELL XPS 8940
 ├─ CPU   -> Intel i5-10400f @ 4.3GHz
 ├─ GPU   -> NVIDIA GeForce GTX 1650 SUPER
 ╰─ Resolution -> 1920x1080@165hz

 ╭─ WM       -> Hyprland
 ├─ Terminal -> Wezterm
 ├─ Theme    -> Catppuccin
 ├─ Icons    -> Papirus-Dark
 ├─ Font     -> JetBrains Mono Nerd Font
 ╰─ Hotel    -> Trivago

                        
```

<hr>

<div align="center">
<img src="https://cdn.discordapp.com/attachments/933711967217123411/1155200026486780005/rice.png" alt="Rice Preview" width="400px" height="253"/>
<img src="https://cdn.discordapp.com/attachments/933711967217123411/1155200026058952724/nvim.png" alt"Rice Preview2" width="400px" height="253"/>
</div>

<hr>

## Commands you should know:

- Rebuild and switch to change the system configuration (in the configuration directory):

```bash
rebuild
# or
sudo nixos-rebuild switch --flake '.#fentas'
```

- Connect to internet (Change what's inside the brackets with your info).

```bash
iwctl --passphrase [passphrase] station [device] connect [SSID]
```

## Installation

I'll guide you through the Installation, but first make sure to download the Minimal ISO image available at [NixOS](https://nixos.org/download#nixos-iso) and make a bootable drive with it. I suggest using [Rufus](https://rufus.ie/en/) for the task as it's a great software.
Also I'm going to use an ethernet cable for the tutorial to make things easier. We shall begin!

### Installation Steps

**Only follow these steps after using the bootable drive, changing BIOS boot priority and getting into the installation!**

```bash
# if needed some terminal changes
video=1920x1080
setfont ter-128n

# ! configure networking as needed
curl -sfL https://raw.githubusercontent.com/fentas/nixdots/main/install.sh -O install.sh
sudo nix-shell ./install.sh
```

Credits for the installation section goes to [Stephenstechtalks](https://github.com/stephenstechtalks) and [AlphaTechnolog](https://github.com/AlphaTechnolog) as they helped a lot with their installation guides.

## Conclusion

That should be all! If you have any problem, feel free to make an issue in the github repo. (https://github.com/fentas/nixdots/issues).

The code is licensed under the MIT license, so you can use or distribute the code however you like.

# Sway build for Regolith 2.1
Build system for sway and regolith related tools. Apps provided (make sure you do not install these via Ubuntu's package repos):

## Core:
  * Sway
  * Trawl
  * wlroots
  * seatd

## Apps:
  * clipman
  * kanshi
  * swaylock-effects
  * xdg-desktop-portal-wlr (for screen sharing)

## Wayland edition of Regolith Uitls:
**Note**: This will replace preinstalled versions. Although, there shouldn't be any change in user experience for users of X11 edition (with i3).
  * Ilia
  * regolith-i3-config
  * regolith-displayd
  * regolith-session
  * regolith-

# Preparing System Environment
## Meson and Ninja

Make sure you uninstall `meson` and `ninja` if you've already installed them via Ubuntu's package manager. Sway and wlroots routinely require the very latest versions of both, so we'll be installing the latest versions using `python3-pip` instead.

## Permissions

Some operations require root to complete - typically anything that requires access to '/usr/' or `/usr/local/`. See [Makefile](Makefile) for details.

While building, `sudo` will be run at some point to do so, and your password will be asked.

## Dependencies

You need `make`. That's it really, everything else can be installed via the provided targets in the [Makefile](Makefile).

## Building stuff

First time, you should probably run

```
make yolo
```

This will clone all the app's git repos, install dev dependencies and tools required to build everything, then it proceeds to build and install each project in sequence.

Have a look at the [Makefile](Makefile) for all the different build targets, in case you want to build this or the other app. 

### Updating repositories before building

Simply pass `-e UPDATE=true` to `make`:

```
make sway -e UPDATE=true
```

### App versions

At the top of the [Makefile](Makefile) you'll see one variable per app that defines which version of that app to build that you can override via environment. By version, I mean either a git hash, or a branch, or a tag - we will simply be running `git checkout $APP_VERSION` before building that app.

For instance, if I wanted to build wlroots `0.11.0`, sway `1.5` and swaylock-effects `master`, while making sure we're on the absolute latest commits for each:

```
make core ilia -e SWAY_VERSION=1.5 -e WLROOTS_VERSION=0.11.0 -e UPDATE=true
```

### The .env file

You can create an `.env` file and place any overrides to environment variables in there, if you need to. This allows you to for these values in a more permanent and convenient fashion than command line (`make -e FOO=bar ...`) arguments, and without changing the [Makefile](Makefile) which is handy if you need to do a `git pull` on this project. The `.env` file is ignored in source control and as such you need to create it yourself if you need it.

Example syntax:

```
SWAY_VERSION=master
WLROOTS_VERSION=master
SOME_APP_BUILD_MODIFIER_VAR=yes
```

## Uninstalling stuff

When installing the stuff we're compiling, `ninja` will be copying the relevant files wherever they need to be in the system, without creating a `deb` package. Therefore, `apt autoremove app` won't work.

So far all the apps in the repo except for clipman use `meson` and `ninja` for building. As long as you don't delete the `APP/build` repository you can uninstall from the system anything ninja installs:

```
cd APP
sudo ninja -C build uninstall
```

If you deleted the `build` folder on the app, simply build the app again (on the same version as before) before running the command above.

## wlroots & seatd dependencies

This goes without saying, but if you're updating `wlroots` or `seatd` make sure they're built first (`seatd`, then `wlroots`) so that any of the other apps that link against it (like `sway`) have the right version to link against instead of linking against the version you're replacing.

## Screen sharing

Ubuntu 22.04 comes with all the plumbing to make it all work:
  * pipewire 0.3
  * xdg-desktop-portal-gtk with the correct build flags

### Limitations

xdg-desktop-portal-wlr does not support window sharing, [only entire outputs](https://github.com/emersion/xdg-desktop-portal-wlr/wiki/FAQ). No way around this. Apps won't show anything on the window list, when asked to initiate a screen sharing session.

### How to install

```
make xdg-desktop-portal-wlr-build -e UPDATE=true
```

This will compile & install & make available the wlr portal to xdg-desktop-portal.

After that, make sure systemd has the following env var `XDG_CURRENT_DESKTOP=sway`. This won't work by merely setting that env var before you start sway. The best way is to create a file containing that at `~/.config/environment.d/xdg.conf`, [like so](https://github.com/luispabon/sway-dotfiles/blob/master/configs/environment.d/xdg.conf). Then reboot.

### Choosing an output to share

When choosing to share a screen from an app, xdpw won't give it a list of available windows or screens to the app to display and for you to choose from. Instead, you'll need to tell your app to share everything and after that the xdpw's output chooser will kick in.

By default it'll be `slurp` - your cursor will change to a crosshairs and you'll be able to click on a screen to share only that one.

The chooser is configurable, see docs here:
https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/xdg-desktop-portal-wlr.5.scd#output-chooser

For instance, if you'd like to use wofi/dmenu, place the following on `~/config/xdg-desktop-portal-wlr/config`

```
[screencast]
chooser_type=dmenu
chooser_cmd=wofi --show=dmenu
```

The actual defaults (if you had no config file) are:

```
[screencast]
chooser_type=simple
chooser_cmd="slurp -f %o -o"
```

### Firefox

Should work out of the box on Firefox 84+ using the wayland backend.

When you start screensharing, on the dialog asking you what to share tell it to "Use operating system settings" when prompted. After that, the output chooser for xdpw will kick in, as explained on the previous section.

### Chromium

Ubuntu's Chromium snap currently does not seem to have webrtc pipewire support.

### Chrome

Open `chrome://flags` and flip `WebRTC PipeWire support` to `enabled`. Should work after that.


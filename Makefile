REQUIRED_UBUNTU_CODENAME=jammy
CURRENT_UBUNTU_CODENAME=$(shell lsb_release -cs)

# Include environment overrides
ifneq ("$(wildcard .env)","")
	include .env
	export
endif

# Define here which branches or tags you want to build for each project
SWAY_VERSION ?= bcf9a989
WLROOTS_VERSION ?= 972a5cdf
WAYLAND_VERSION ?= main
KANSHI_VERSION ?= master
SWAYLOCK_VERSION ?= master
CLIPMAN_VERSION ?= master
XDG_DESKTOP_PORTAL_VERSION ?= master
REGOLITH_SESSION_VERSION ?= sway-session
REGOLITH_I3_CONFIG_VERSION ?= wayland-dev
REGOLITH_LOOK_DEFAULT_VERSION ?= wayland-dev
REGOLITH_FTUE_VERSION ?= sway-session
LAYER_SHELL_VERSION ?= master
ILIA_VERSION ?= ubuntu/jammy-wayland
REGOLITH_DISPLAYD_VERSION ?= master 

ifdef UPDATE
	UPDATE_STATEMENT = git pull;
endif

ifdef ASAN_BUILD
	ASAN_STATEMENT = -Db_sanitize=address
endif

define PREFIX 
/usr 
endef

define BASE_CLI_DEPS
	git \
	curl \
	mercurial \
	python3-pip \
	aptitude
endef

define WAYLAND_DEPS
	libxml2-dev
endef

define WLROOTS_DEPS
	wayland-protocols \
	libegl1-mesa-dev \
	libgles2-mesa-dev \
	libdrm-dev \
	libgbm-dev \
	libinput-dev \
	libxkbcommon-dev \
	libgudev-1.0-dev \
	libpixman-1-dev \
	libsystemd-dev \
	cmake \
	libpng-dev \
	libavutil-dev \
	libavcodec-dev \
	libavformat-dev \
	libxcb-composite0-dev \
	libxcb-icccm4-dev \
	libxcb-image0-dev \
	libxcb-render0-dev \
	libxcb-xfixes0-dev \
	libxkbcommon-dev \
	libxcb-xinput-dev \
	libx11-xcb-dev \
	libxcb-dri3-dev \
	libxcb-present-dev \
	libxcb-render-util0 \
	libxcb-render-util0-dev \
	libxcb-res0-dev
endef

define SWAY_DEPS
	libjson-c-dev \
	libpango1.0-dev \
	libcairo2-dev \
	libgdk-pixbuf2.0-dev \
	xwayland \
	swaybg \
	foot \
	scdoc
endef

define TRAWL_DEPS
	 cargo \
	 libglib2.0-dev 
endef

define ILIA_DEPS
	valac \
	libtracker-sparql-3.0-dev \
	libatk1.0-dev \
	libgtk-3-0 \
	libgtk-3-dev \
	libjson-glib-dev \
	libgee-0.8-2 \
	libgirepository1.0-dev \
	libgee-0.8-dev
endef

define GTK_LAYER_DEPS
	libgtk-layer-shell-dev \
	libgtk-layer-shell0
endef

define SWAYLOCK_DEPS
	libpam0g-dev
endef

define CLIPMAN_DEPS
	golang-go
endef

define XDG_DESKTOP_PORTAL_DEPS
	libpipewire-0.3-dev \
	libinih-dev
endef

PIP_PACKAGES=ninja meson

NINJA_CLEAN_BUILD_INSTALL=$(UPDATE_STATEMENT) sudo ninja -C build uninstall; sudo rm build -rf; meson build --prefix=$(PREFIX) $(ASAN_STATEMENT); ninja -C build; sudo ninja -C build install


check-ubuntu-version:
	@if [ "$(CURRENT_UBUNTU_CODENAME)" != "$(REQUIRED_UBUNTU_CODENAME)" ]; then echo "### \n#  Unsupported version of ubuntu (current: '$(CURRENT_UBUNTU_CODENAME)', required: '$(REQUIRED_UBUNTU_CODENAME)').\n#  Check this repo's remote branches (git branch -r) to see if your version is there and switch to it (these branches are deprecated but should work for your version)\n###"; exit 1; fi

## Meta installation targets
yolo: install-dependencies install-repos core apps regolith
core: seatd-build wayland-build wlroots-build trawl-build sway-build
apps: xdg-desktop-portal-wlr-build kanshi-build swaylock-build clipman-build
regolith: regolith-session-build regolith-i3-config-build regolith-look-default-build ilia-build regolith-displayd-build regolith-ftue-build

## Build dependencies
install-repos:
	@git clone https://github.com/regolith-linux/sway.git || echo "Already installed"
	@git clone https://gitlab.freedesktop.org/wlroots/wlroots.git || echo "Already installed"
	@git clone https://gitlab.freedesktop.org/wayland/wayland.git || echo "Already installed"
	@git clone https://git.sr.ht/~emersion/kanshi || echo "Already installed"
	@git clone https://github.com/mortie/swaylock-effects.git || echo "Already installed"
	@git clone https://github.com/yory8/clipman.git || echo "Already installed"
	@git clone https://git.sr.ht/~kennylevinsen/seatd || echo "Already installed"
	@git clone https://github.com/emersion/xdg-desktop-portal-wlr.git || echo "Already installed"
	@git clone https://github.com/regolith-linux/trawl.git || echo "Already installed"
	@git clone https://github.com/regolith-linux/regolith-session.git || echo "Already Installed"
	@git clone https://github.com/regolith-linux/regolith-i3-config.git || echo "Already Installed"
	@git clone https://github.com/regolith-linux/regolith-displayd.git || echo "Already installed"
	@git clone https://github.com/regolith-linux/regolith-look-default.git || echo "Already installed"
	@git clone https://github.com/regolith-linux/ilia.git || echo "Already installed"
	@git clone https://github.com/wmww/gtk-layer-shell.git || echo "Already installed"
	@git clone https://github.com/regolith-linux/regolith-ftue.git || echo "Already installed"

install-dependencies:
	sudo apt -y remove --purge libwayland-dev libwayland-bin
	sudo apt -y install build-essential
	sudo apt -y install $(BASE_CLI_DEPS)
	sudo apt -y install --no-install-recommends \
		$(WAYLAND_DEPS) \
		$(WLROOTS_DEPS) \
		$(SWAY_DEPS) \
		$(ILIA_DEPS) \
		$(TRAWL_DEPS) \
		$(GTK_LAYER_DEPS) \
		$(SWAYLOCK_DEPS) \
		$(CLIPMAN_DEPS) \
		$(XDG_DESKTOP_PORTAL_DEPS)
	sudo pip3 install $(PIP_PACKAGES) --upgrade
	rustc --version || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

fix-dependencies:
	printf 'n\ny\ny\n' | sudo aptitude install libgbm-dev libjson-c-dev libsystemd-dev  libudev-dev libgtk-3-dev

clean-dependencies:
	sudo apt autoremove --purge $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(SWAYLOCK_DEPS) $(XDG_DESKTOP_PORTAL_DEPS)

meson-ninja-build: check-ubuntu-version
	cd $(APP_FOLDER); git fetch; git checkout $(APP_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

## Sway
seatd-build:
	make meson-ninja-build -e APP_FOLDER=seatd -e APP_VERSION=$(SEATD_VERSION)

wayland-build:
	cd wayland; rm -rf build; git fetch; git checkout ${WAYLAND_VERSION}; meson build --prefix=${PREFIX} -Dtests=false -Ddocumentation=false -Ddtd_validation=false -Dscanner=true; sudo meson install -C build

wlroots-build:
	cd wlroots; rm -rf build; git fetch; git checkout ${WLROOTS_VERSION}; meson build --prefix=${PREFIX} -Dxwayland='enabled' -Dbackends="['drm', 'libinput', 'x11']"; sudo meson install -C build

sway-build:
	cd sway; rm -rf build; git fetch; git checkout ${SWAY_VERSION}; meson build --prefix=${PREFIX} -Dxwayland='enabled'; sudo meson install -C build
	sudo cp -f $(PWD)/sway/contrib/grimshot /usr/local/bin/

trawl-build:
	cd trawl && make && make install 
	systemctl --user enable trawld

## Regolith
regolith-session-build:
	cd regolith-session; git fetch; git checkout $(REGOLITH_SESSION_VERSION); sudo rsync -avh usr/ /usr/

regolith-i3-config-build:
	cd regolith-i3-config; git fetch; git checkout $(REGOLITH_I3_CONFIG_VERSION); make install

regolith-look-default-build:
	cd regolith-look-default; git fetch; git checkout $(REGOLITH_LOOK_DEFAULT_VERSION); sudo rsync -avh usr/ /usr/

regolith-displayd-build:
	cd regolith-displayd;  git fetch; git checkout $(REGOLITH_DISPLAYD_VERSION); make; make install
	systemctl --user enable regolith-displayd

regolith-ftue-build:
	cd regolith-ftue; git fetch; git checkout $(REGOLITH_FTUE_VERSIONO); sudo cp regolith-init-term-profile /usr/share/regolith-ftue; sudo cp regolith-ftue /usr/bin/regolith-ftue

layer-shell-build:
	cd gtk-layer-shell; git fetch; git checkout $(LAYER_SHELL_VERSION); meson build --prefix=$(PREFIX); sudo meson install -C build

ilia-build: 
	make layer-shell-build
	make meson-ninja-build -e APP_FOLDER=ilia -e APP_VERSION=$(ILIA_VERSION)

## Apps
kanshi-build:
	make meson-ninja-build -e APP_FOLDER=kanshi -e APP_VERSION=$(KANSHI_VERSION)

swaylock-build:
	make meson-ninja-build -e APP_FOLDER=swaylock-effects -e APP_VERSION=$(SWAYLOCK_VERSION)

clipman-build:
	cd clipman; git fetch; git checkout $(CLIPMAN_VERSION); go install 
	sudo cp -f ~/go/bin/clipman /usr/local/bin/

xdg-desktop-portal-wlr-build:
	cd xdg-desktop-portal-wlr; git fetch; git checkout $(XDG_DESKTOP_PORTAL_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)
	sudo ln -sf /usr/local/libexec/xdg-desktop-portal-wlr /usr/libexec/
	sudo ln -sf /usr/local/share/xdg-desktop-portal/portals/wlr.portal /usr/share/xdg-desktop-portal/portals/

## Debugging
printenv:
	env

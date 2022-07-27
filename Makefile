REQUIRED_UBUNTU_CODENAME=jammy
CURRENT_UBUNTU_CODENAME=$(shell lsb_release -cs)

# Include environment overrides
ifneq ("$(wildcard .env)","")
	include .env
	export
endif

# Define here which branches or tags you want to build for each project
SWAY_VERSION ?= master
WLROOTS_VERSION ?= master
WAYLAN_VERSION ?= main
KANSHI_VERSION ?= master
SWAYLOCK_VERSION ?= master
CLIPMAN_VERSION ?= master
XDG_DESKTOP_PORTAL_VERSION ?= master

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
	libwayland-dev \
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
	libxcb-res0-dev
endef

define SWAY_DEPS
	libjson-c-dev \
	libpango1.0-dev \
	libcairo2-dev \
	libgdk-pixbuf2.0-dev \
	scdoc
endef

define TRAWL_DEPS
	 libglib2.0-dev 
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
yolo: install-dependencies install-repos core apps
core: seatd-build wlroots-build trawl-build sway-build
apps: xdg-desktop-portal-wlr-build kanshi-build swaylock-build clipman-build

## Build dependencies
install-repos:
	@git clone https://github.com/regolith-linux/sway.git || echo "Already installed"
	@git clone https://gitlab.freedesktop.org/wlroots/wlroots.git || echo "Already installed"
	cd wlroots && mkdir -p subprojects && cd subprojects && git clone https://gitlab.freedesktop.org/wayland/wayland.git || echo "Already installed"
	@git clone https://git.sr.ht/~emersion/kanshi || echo "Already installed"
	@git clone https://github.com/mortie/swaylock-effects.git || echo "Already installed"
	@git clone https://github.com/yory8/clipman.git || echo "Already installed"
	@git clone https://git.sr.ht/~kennylevinsen/seatd || echo "Already installed"
	@git clone https://github.com/emersion/xdg-desktop-portal-wlr.git || echo "Already installed"
	@git clone https://github.com/sardemff7/libgwater.git || echo "Already installed"
	@git clone https://github.com/regolith-linux/trawl.git || echo "Already installed"
	@git clone https://github.com/regolith-linux/regolith-displayd.git || echo "Already installed"

install-dependencies:
	sudo apt -y install build-essential
	sudo apt -y install $(BASE_CLI_DEPS)
	sudo apt -y install --no-install-recommends \
		$(WAYLAND_DEPS) \
		$(WLROOTS_DEPS) \
		$(SWAY_DEPS) \
		$(TRAWL_DEPS) \
		$(GTK_LAYER_DEPS) \
		$(SWAYLOCK_DEPS) \
		$(CLIPMAN_DEPS) \
		$(XDG_DESKTOP_PORTAL_DEPS)
	sudo pip3 install $(PIP_PACKAGES) --upgrade
	rustc --version || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

fix-dependencies:
	printf 'n\ny\ny\n' | sudo aptitude install libgbm-dev libjson-c-dev libsystemd-dev  libudev-dev

clean-dependencies:
	sudo apt autoremove --purge $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(SWAYLOCK_DEPS) $(XDG_DESKTOP_PORTAL_DEPS)

meson-ninja-build: check-ubuntu-version
	cd $(APP_FOLDER); git fetch; git checkout $(APP_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

## Sway
seatd-build:
	make meson-ninja-build -e APP_FOLDER=seatd -e APP_VERSION=$(SEATD_VERSION)

wlroots-build:
	make meson-ninja-build -e APP_FOLDER=wlroots -e APP_VERSION=$(WLROOTS_VERSION)

sway-build:
	make meson-ninja-build -e APP_FOLDER=sway -e APP_VERSION=$(SWAY_VERSION)
	sudo cp -f $(PWD)/sway/contrib/grimshot /usr/local/bin/

trawl-build:
	cd trawl && make install 

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

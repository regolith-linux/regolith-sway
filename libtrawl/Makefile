PREFIX = ${DESTDIR}/usr

all: build

distclean: clean

clean:
	-rm -r build

build-arch: build

build-independent: build

binary: build

binary-arch: build

binary-independent: build

build: setup
	cd build; meson compile

setup:
	scripts/run_codegen.sh service.xml config_manager.c config_manager.h
	meson build --prefix=$(PREFIX)

install:
	cd build; meson install
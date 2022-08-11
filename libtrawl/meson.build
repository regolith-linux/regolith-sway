project('demo', 'c',
  version : '0.1',
  default_options : ['warning_level=3'])

pkg = import('pkgconfig')

gio_dep = dependency('gio-unix-2.0')
lib_deps = [gio_dep]
sources = ['client_api.c', 'config_manager.c']

lib_so_version = '0'
pkg_config_name = 'trawldb-0'

libclient_api = library ('trawl-client',
        sources,
        dependencies: lib_deps,
        version: meson.project_version(),
        soversion: lib_so_version,
        install: true)

install_headers(['client_api.h', 'config_manager.h', ], subdir: 'trawldb')

pkg.generate(libclient_api, 
        name: 'trawldb',
        version: meson.project_version(),
        libraries: [libclient_api],
        filebase: pkg_config_name,
        install_dir: '/usr/lib/pkgconfig',
        description: 'Use regolith config manager')

run_target('uninstall-lib', command : ['scripts/uninstall.sh'])

subdir('example')

/etc/apt/sources.list:
  file.managed:
    - source: salt://obs-server/sources.list
    - user: root
    - group: root
    - mode: 644

obs:
  host.present:
    - ip: 127.0.0.1

refresh_packages_db:
  cmd.run:
    - name: apt-get update -y
    - onchanges:
      - file: /etc/apt/sources.list

install_obs_server_packages:
  pkg.installed:
    - pkgs:
      - obs-server
      - obs-utils
      - osc

obs-api:
  pkg:
    - installed
  file.managed:
    - name: /usr/share/obs/api/config/database.yml
    - source: salt://llvm-obs/obs-conf/obs-api_database.yml
    - template: jinja

install_apache:
  pkg.installed:
    - pkgs:
      - apache2
      - apache2-utils
      - libapache2-mod-passenger
      - libapache2-mod-xforward
      - memcached

create_self_signed_ssl_for_testing:
  cmd.script:
    - name: generate_ssl.sh
    - source: salt://llvm-obs/obs-scripts/generate_ssl.sh

install_obs_build_from_backports:
  pkg.latest:
    - pkgs:
      - obs-build
    - fromrepo: stretch-backports

# We use libsolv from testing due to a debian control
# size limitation in older versions of the lib
# see https://athoscr.me/blog/gsoc2018-7/
install_libsolv_from_testing:
  pkg.latest:
    - pkgs:
      - libsolv0
      - libsolv-perl
      - libsolvext0
    - fromrepo: buster

# This is needed due to an incompatible version of
# nokogiri (which was updated) in Stretch
/usr/share/obs/api/Gemfile:
  file.managed:
    - source: salt://obs-server/Gemfile
    - user: root
    - group: root
    - mode: 644

{% if salt['grains.get']('api_setup') != 'done' %}
rake_task_setup:
  cmd.run:
     - name: "bash /usr/share/obs/api/script/rake-tasks.sh setup"
  grains.present:
    - name: api_setup
    - value: done

restart_apache:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - rake_task_setup
{% endif %}

start_obsservice:
  service.running:
    - name: obsservice
    - enable: True

/root/.oscrc:
  file.managed:
    - source: salt://obs-server/oscrc
    - user: root
    - group: root
    - mode: 600
    - template: jinja

/tmp/obs_instance_configuration.xml:
  file.managed:
    - source: salt://obs-server/obs_instance_configuration.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_unstable.xml:
  file.managed:
    - source: salt://obs-server/debian_unstable.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_unstable.conf:
  file.managed:
    - source: salt://obs-server/debian_unstable.conf
    - user: root
    - group: root
    - mode: 644

/tmp/debian_clang.xml:
  file.managed:
    - source: salt://obs-server/debian_clang.xml
    - user: root
    - group: root
    - mode: 644

restart_obssrcserver:
  service.running:
    - name: obssrcserver
    - enable: True
    - watch:
      - create_self_signed_ssl_for_testing

set_obs_instance_configurations:
  cmd.run:
    - name: osc api /configuration -T /tmp/obs_instance_configuration.xml

create_debian_unstable_project:
  cmd.run:
    - name: osc meta prj Debian:Unstable -F /tmp/debian_unstable.xml

configure_debian_unstable_project:
  cmd.run:
    - name: osc meta prjconf Debian:Unstable -F /tmp/debian_unstable.conf

create_debian_clang_project:
  cmd.run:
    - name: osc meta prj Debian:Unstable:Clang -F /tmp/debian_clang.xml

/usr/local/bin/trigger_clang_build:
  file.managed:
    - source: salt://obs-server/trigger_clang_build
    - user: root
    - group: root
    - mode: 755

build_obs_clang_build_package:
  cmd.run:
    - name: trigger_clang_build obs-service-clang-build

/usr/local/bin/check_new_uploads:
  file.managed:
    - source: salt://obs-server/check_new_uploads
    - user: root
    - group: root
    - mode: 755
  cron.present:
    - user: root
    - minute: 15
    - hour: '*/2'

/tmp/obs_service_clang_build_meta.xml:
  file.managed:
    - source: salt://obs-server/obs_service_clang_build_meta.xml
    - user: root
    - group: root
    - mode: 644

allow_obs_service_clang_build_usage:
  cmd.run:
    - name: osc meta pkg Debian:Unstable:Clang obs-service-clang-build -F /tmp/obs_service_clang_build_meta.xml

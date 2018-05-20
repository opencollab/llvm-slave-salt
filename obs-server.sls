install obs server packages:
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

install apache:
  pkg.installed:
    - pkgs:
      - apache2
      - apache2-utils
      - libapache2-mod-passenger
      - libapache2-mod-xforward
      - memcached

create self signed ssl for testing:
  cmd.script:
    - name: generate_ssl.sh
    - source: salt://llvm-obs/obs-scripts/generate_ssl.sh

rake task setup:
  cmd.run:
     - name: "bash /usr/share/obs/api/script/rake-tasks.sh setup"

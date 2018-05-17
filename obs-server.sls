install obs server packages:
  pkg.installed:
    - pkgs:
      - obs-server
      - obs-worker

obs-api:
  pkg:
    - installed
  file.managed:
     - name: /usr/share/obs/api/config/database.yml
     - source: salt://llvm-obs/obs-conf/obs-api_database.yml
     - template: jinja

populate_database setup db:
  cmd.run:
     - name: "RAILS_ENV=\"production\" rake db:setup"
     - cwd: /usr/share/obs/api/

populate_database write configuration:
  cmd.run:
     - name: "RAILS_ENV=\"production\" rake writeconfiguration"
     - cwd: /usr/share/obs/api/

/usr/share/obs/api/log:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

/usr/share/obs/api/tmp:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

install apache:
  pkg.installed:
    - pkgs:
      - apache2
      - apache2-utils
      - libapache2-mod-passenger
      - libapache2-mod-xforward
      - memcached

enable apache ssl module:
  cmd.run:
    - name: a2enmod ssl

create self signed ssl for testing:
  cmd.script:
    - name: generate_ssl.sh
    - source: salt://llvm-obs/obs-scripts/generate_ssl.sh

reload apache:
  service.running:
    - name: apache2
    - enable: True
    - reload: True

obsapidelayed:
  service.running:
    - enable: True

memcached:
  service.running:
    - enable: True

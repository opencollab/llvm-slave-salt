install_mysql:
  pkg.installed:
    - pkgs:
      - mysql-server
      - python-mysqldb 

reload-mysql:
  service.running:
    - name: mysql
    - enable: True
    - reload: True

root_user:
  mysql_user.present:
    - name: 'root'
    - password: {{salt['pillar.get']('obs-database:lookup:root-password')}}

mysql remove anonymous users:
  mysql_user.absent:
    - name: ''
    - host: 'localhost'
    - connection_user: 'root'
    - connection_pass: {{salt['pillar.get']('obs-database:lookup:root-password') }}
    - connection_charset: utf8

mysql remove test database:
  mysql_database.absent:
    - name: test
    - host: 'localhost'
    - connection_user: 'root'
    - connection_pass: {{salt['pillar.get']('obs-database:lookup:root-password') }}
    - connection_charset: utf8

create api database:
  mysql_database.present:
    - name: {{salt['pillar.get']('obs-database:lookup:obs-api-database') }}
    - host: localhost
    - connection_user: 'root'
    - connection_pass: {{salt['pillar.get']('obs-database:lookup:root-password') }}
    - connection_charset: utf8

create obs for api user@localhost:
  mysql_user.present:
    - name: {{salt['pillar.get']('obs-database:lookup:obs-user') }}
    - host: localhost
    - password: {{salt['pillar.get']('obs-database:lookup:obs-api-database-password') }}

create obs for api user@%:
  mysql_user.present:
    - name: {{salt['pillar.get']('obs-database:lookup:obs-user') }}
    - host: \%
    - password: {{salt['pillar.get']('obs-database:lookup:obs-api-database-password') }}

grant permission:
  cmd.script:
    - name: grant_permissions.sh
    - source: salt://llvm-obs/obs-scripts/grant_permissions.sh
    - template: jinja

mysql_restart:
  module.wait:
    - name: service.restart
    - m_name: mysql

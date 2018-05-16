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
    - password: 'TOPSECRET'

mysql remove anonymous users:
  mysql_user.absent:
    - name: ''
    - host: 'localhost'
    - connection_user: 'root'
    - connection_pass: 'TOPSECRET'
    - connection_charset: utf8

mysql remove test database:
  mysql_database.absent:
    - name: test
    - host: 'localhost'
    - connection_user: 'root'
    - connection_pass: 'TOPSECRET'
    - connection_charset: utf8

create api database:
  mysql_database.present:
    - name: api_production
    - host: localhost
    - connection_user: 'root'
    - connection_pass: 'TOPSECRET'
    - connection_charset: utf8

create obs for api user@localhost:
  mysql_user.present:
    - name: obs
    - host: localhost
    - password: 'topsecretpasskey'

create obs for api user@%:
  mysql_user.present:
    - name: obs
    - host: \%
    - password: 'topsecretpasskey'

obs_grants to api obs@localhost:
  mysql_grants.present:
    - host: localhost
    - database: api_production.\*
    - grant: all privileges
    - user: obs

obs_grants to api obs@%:
  mysql_grants.present:
    - host: \%
    - database: api_production.\*
    - grant: all privileges
    - user: obs

create webui database:
  mysql_database.present:
    - name: webui_production
    - host: localhost
    - connection_user: 'root'
    - connection_pass: 'TOPSECRET'
    - connection_charset: utf8

#Grant permissions to obs:
#  mysql_query.run:
#    - database: api_production
#    - connection_user: root
#    - connection_pass: TOPSECRET
#    - output:   "/tmp/query_id.txt"
#    - query: |
#        GRANT all privileges ON api_production.* TO 'obs'@'%', 'obs'@'localhost';
#        FLUSH PRIVILEGES;
        
grant permission:
  cmd.script:
    - name: grant_permissions.sh
    - source: salt://llvm-obs/obs-scripts/grant_permissions.sh

mysql_restart:
  module.wait:
    - name: service.restart
    - m_name: mysql


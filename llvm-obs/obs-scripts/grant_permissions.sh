#!/bin/bash
mysql -u root -p{{salt['pillar.get']('obs-database:lookup:root-password')}} <<EOF
set sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
GRANT all privileges ON api_production.* TO 'obs'@'%', 'obs'@'localhost';
FLUSH PRIVILEGES;
EOF

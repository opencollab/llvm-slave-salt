base:
  '*':
    - apt-common
#   - obs-common
  'E@irill*':
    - match: compound
    - debile-servers
    - debile-servers-users
#   - mysql_init
#   - obs-server
#  'E@blade*':
#    - match: compound
#    - llvm-slave
#    - apt-common-pinning

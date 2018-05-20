base:
  '*':
    - apt-common
  'E@blade*':
    - match: compound
    - llvm-slave
    - apt-common-pinning
  'E@obs-server* or E@irill8*':
    - obs-common
    - mysql_init
    - obs-server
  'E@obs-worker* or E@korcula.*':
    - obs-common
    - obs-worker

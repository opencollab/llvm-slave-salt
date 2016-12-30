base:
  '*':
    - apt-common
#  'E@irill*':
#    - match: compound
#    - debile-servers
#    - debile-servers-users
  'E@blade*':
    - match: compound
    - llvm-slave
    - apt-common-pinning

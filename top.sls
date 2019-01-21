base:
  '*':
    - apt-common
  'E@blade*':
    - match: compound
    - llvm-slave
    - apt-common-pinning

sudo: pkg.installed

/etc/apt/apt.conf.d/90norecommend:
  file:
    - managed
    - source: salt://apt-common/90norecommend

/etc/apt/apt.conf:
  file:
    - managed
    - source: salt://apt-common/apt.conf

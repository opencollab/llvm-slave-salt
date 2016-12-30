{% set site_user = 'jenkins' %}

fail2ban: pkg.installed
ntp: pkg.installed
emacs-nox: pkg.installed
cowbuilder: pkg.installed
rsync: pkg.installed
jenkins-debian-glue: pkg.installed
default-jdk: pkg.installed
subversion-tools: pkg.installed
svn2cl: pkg.installed
smbclient: pkg.installed
cifs-utils: pkg.installed
lintian: pkg.installed
# for lintian-junit-report
ruby: pkg.installed 
openjdk-8-jre-headless: pkg.installed
git-buildpackage: pkg.installed
quilt: pkg.installed
fakeroot: pkg.installed

jenkins:
  group:
    - present
  user:
    - present
    - shell: /bin/bash
    - groups:
      - jenkins
    - fullname: Jenkins user
    - require:
      - group: jenkins
#  ssh_auth:
#    - present
#    - user: sylvestre
#    - source: salt://debile/ssh_keys/sylvestre
#    - require:
#      - user: sylvestre


/etc/sudoers.d/jenkins:
  file:
    - managed
    - source: salt://llvm-slave-jenkins/jenkins.sudo

/home/{{ site_user }}/secret.lst:
    file:
        - managed
        - user: {{ site_user }}
        - group: {{ site_user }}
        - source: salt://llvm-slave-jenkins/secret.lst

/home/{{ site_user }}/run-slave.sh:
    file:
        - managed
        - user: {{ site_user }}
        - group: {{ site_user }}
        - source: salt://llvm-slave-jenkins/run-slave.sh
        - mode: 700

/etc/systemd/system/jenkins.service:
    file:
        - managed
        - user: {{ site_user }}
        - group: {{ site_user }}
        - source: salt://llvm-slave-jenkins/jenkins.service


/home/{{ site_user }}/slave.jar:
    file:
        - managed
        - skip_verify: True
        - user: {{ site_user }}
        - group: {{ site_user }}
        - source: http://llvm-jenkins.debian.net/jnlpJars/slave.jar


install_reprepro:
  pkg.installed:
    - sources:
      - reprepro: http://ftp.us.debian.org/debian/pool/main/r/reprepro/reprepro_5.1.1-1_amd64.deb

llvm_jenkins_repo:
  git.latest:
    - name: https://github.com/sylvestre/llvm-jenkins.debian.net.git
    - target: /home/{{ site_user }}/llvm-jenkins.debian.net.git
    - force_reset: True

/root/.pbuilderrc:
  file.symlink:
    - target: /home/{{ site_user }}/llvm-jenkins.debian.net.git/pbuilderrc
    - force: True

/etc/jenkins/debian_glue:
  file.symlink:
    - target: /home/{{ site_user }}/llvm-jenkins.debian.net.git/debian_glue
    - force: True

/usr/share/jenkins-debian-glue/pbuilder-hookdir:
  file.symlink:
    - target: /home/{{ site_user }}/llvm-jenkins.debian.net.git/pbuilder-hookdir/
    - force: True

/usr/share/debootstrap/scripts/zesty:
  file.symlink:
    - target: /usr/share/debootstrap/scripts/trusty
    - force: True

/usr/share/debootstrap/scripts/artful:
  file.symlink:
    - target: /usr/share/debootstrap/scripts/trusty
    - force: True

/usr/share/debootstrap/scripts/bionic:
  file.symlink:
    - target: /usr/share/debootstrap/scripts/trusty
    - force: True

/usr/share/debootstrap/scripts/buster:
  file.symlink:
    - target: /usr/share/debootstrap/scripts/stretch
    - force: True

/srv/repository:
  mount.mounted:
    - device: //santamaria.siege.inria.fr/repository
    - fstype: cifs
    - mkmnt: True
    - opts: 
      - username=jenkins
      - password=PASSWORD
      - uid=1006
      - gid=1006

/home/{{ site_user }}/.gnupg:
  file.recurse:
    - source: salt://llvm-slave-jenkins/gnupg
    - include_empty: True
    - user: {{ site_user }}
    - group: {{ site_user }}
    - dir_mode: 700

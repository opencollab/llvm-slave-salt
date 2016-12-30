apt-show-versions: pkg.installed

pkg.upgrade:
    module.run:
        - refresh: True
        - require:
          - file: jessie.list
          - file: stretch.list
          - file: jenkins-debian-glue.list
#          - file: experimental.list
#          - file: unstable.list
          - file: preferences


# system:
#     pkg:
#         - upgrade
#         - refresh: True
#         - prereq:
# #          - file: sources.list
# #          - file: jessie.list
# #          - file: experimental.list
#           - file: stretch.list
#           - file: preferences

#sources.list:
#    file.remove:
#        - name: /etc/apt/sources.list

jessie.list:
    file.managed:
        - name: /etc/apt/sources.list.d/jessie.list
        - source: salt://apt-common/jessie.list
        - reload_modules: true

stretch.list:
    file.managed:
        - name: /etc/apt/sources.list.d/stretch.list
        - source: salt://apt-common/stretch.list
        - reload_modules: true

#experimental.list:
#    file.managed:
#        - name: /etc/apt/sources.list.d/experimental.list
#        - source: salt://apt-common/experimental.list
#        - reload_modules: true

#unstable.list:
#    file.managed:
#        - name: /etc/apt/sources.list.d/unstable.list
#        - source: salt://apt-common/unstable.list
#        - reload_modules: true

preferences:
    file.managed:
        - name: /etc/apt/preferences
        - source: salt://apt-common/preferences
        - reload_modules: true

jenkins-debian-glue.list:
    file.managed:
        - name: /etc/apt/sources.list.d/jenkins-debian-glue.list
        - source: salt://apt-common/jenkins-debian-glue.list
        - reload_modules: true

base:
  pkgrepo.managed:
    - humanname: saltstack
    - name: deb http://repo.saltstack.com/apt/debian/8/amd64/latest jessie main
    - file: /etc/apt/sources.list.d/salt.list
    - key_url: salt://apt-common/SALTSTACK-GPG-KEY.pub
    - require_in:
      - pkg: salt-minion
  pkg.latest:
    - name: salt-minion
    - refresh: True

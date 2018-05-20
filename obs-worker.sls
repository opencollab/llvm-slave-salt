install obs server packages:
  pkg.installed:
    - pkgs:
      - obs-worker
      - obs-utils

enable obs workers:
  file.replace:
    - name: /etc/default/obsworker
    - pattern: '^ENABLED=0'
    - repl: 'ENABLED=1'
    - count: 1

set obs source server:
  file.replace:
    - name: /etc/default/obsworker
    - pattern: '^OBS_SRC_SERVER="obs:5352"'
    - repl: '{{salt['pillar.get']('obs-database:lookup:obs-server')}}:5352'
    - count: 1

set obs repo server:
  file.replace:
    - name: /etc/default/obsworker
    - pattern: '^OBS_REPO_SERVER="obs:5252"'
    - repl: '{{salt['pillar.get']('obs-database:lookup:obs-server')}}:5252'
    - count: 1

obsworker:
  service.running:
    - name: obsworker
    - enable: True
    - reload: True


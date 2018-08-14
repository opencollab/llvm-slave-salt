install_obs_worker_packages:
  pkg.installed:
    - pkgs:
      - obs-worker
      - obs-utils

/etc/default/obsworker:
  file.managed:
    - source: salt://obs-worker/obsworker
    - user: root
    - group: root
    - mode: 644
    - template: jinja

obsworker:
  service.running:
    - name: obsworker
    - enable: True
    - reload: True


from fabric.api import env

env.project_code = "ureport"
env.require_tag = True


def _configure(build_name):
    env.build_name = build_name
    env.nginx_file_path = "conf/nginx.ureport.conf"
    env.supervisor_file_path = "conf/supervisor.ureport.conf"
    env.hostname = "ureport-%(build_name)s.elasticbeanstalk.com" % env


def dev():
    _configure("dev")


def stage():
    _configure("stage")

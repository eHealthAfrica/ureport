import os
from fabric.api import env

env.project_code = "ureport"
env.require_tag = True


def _configure(build_name):
    env.build_name = build_name
    env.config_dir = "conf"
    env.nginx_file_path = os.path.join(env.config_dir, "nginx.ureport.conf")
    env.nginx_template = "%(nginx_file_path)s.tmpl" % env
    env.supervisor_file_path = os.path.join(
        env.config_dir, "supervisor.ureport.conf")
    env.hostname = "ureport-%(build_name)s.elasticbeanstalk.com" % env
    env.tag = os.environ.get("TRAVIS_TAG", "latest")

    env.eb_extensions_dir = ".ebextensions/"
    env.dockerrun_file_name = "Dockerrun.aws.json"
    env.dockerrun_file_path = os.path.join(
        env.config_dir, env.dockerrun_file_name)
    env.dockerrun_template = "%(dockerrun_file_path)s.tmpl" % env
    env.artifact_file_name = "deploy.zip"
    env.artifact_file_path = os.path.join(
        env.config_dir, env.artifact_file_name)


def dev():
    _configure("dev")


def stage():
    _configure("stage")

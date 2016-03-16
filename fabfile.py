import os
import zipfile

from fabric.colors import green
from fabric.api import local
from fabconfig import env, dev, stage  # noqa

from jinja2 import Environment, FileSystemLoader

loader = FileSystemLoader("conf", followlinks=True)
template_env = Environment(loader=loader)


def deploy():
    create_nginx_config()
    create_dockerrun_file()
    create_zip()
    local("eb deploy")


def create_nginx_config():
    template = template_env.get_template(env.nginx_template)
    with open(env.nginx_file_path, "w") as file_handle:
        data = template.render(hostname=env.hostname)
        file_handle.write(data)
    notify("Create %(nginx_file_path)s with hostname: %(hostname)s" % env)


def create_dockerrun_file():
    template = template_env.get_template(env.dockerrun_template)
    with open(env.dockerrun_file_path, "w") as file_handle:
        context = {
            "tag": env.tag,
            "environment": env.environment
        }
        data = template.render(**context)
        file_handle.write(data)
    notify("Create Dockerrun.aws.json with tag %s" % env.tag)


def create_zip():
    zip_file_handle = zipfile.ZipFile(env.artifact_file_path, "w")
    _zipdir(zip_file_handle, path=env.eb_extensions_dir)
    zip_file_handle.write(
        env.dockerrun_file_path, arcname=env.dockerrun_file_name)
    zip_file_handle.close()


def _zipdir(zip_file_handle, path):
    for root, dirs, files in os.walk(path):
        for file in files:
            zip_file_handle.write(os.path.join(root, file))


def _get_commit_id():
    return local("git rev-parse HEAD", capture=True)[:20]


def _get_current_branch_name():
    return local('git branch | grep "^*" | cut -d" " -f2', capture=True)


def notify(msg):
    bar = "+" + "-" * (len(msg) + 2) + "+"
    print green("")
    print green(bar)
    print green("| %s |" % msg)
    print green(bar)
    print green("")

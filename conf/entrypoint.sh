#!/bin/bash
set -e


# Define help message
show_help() {
    echo """
    Commands
    manage     : Invoke django manage.py commands
    setupdb  : Create empty database for ureport, will still need migrations run
    """
}

case "$1" in
    manage )
        cd /code/
        python manage.py "${@:2}"
    ;;
    setupdb )
        set +e
        cd /code/
        python manage.py sqlcreate | psql -U postgres -h db
        python manage.py migrate
    ;;
    start )
        cd /code
        python manage.py collectstatic --noinput
        /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
        nginx -g "daemon off;"
    ;;
    *)
        show_help
    ;;
esac

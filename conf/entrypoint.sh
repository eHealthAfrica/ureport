#!/bin/bash
set -e


# Define help message
show_help() {
    echo """
    Commands
    manage     : Invoke django manage.py commands
    setuplocaldb  : Create empty database for ureport, will still need migrations run
    """
}

setup_local_db() {
    cd /code
    python manage.py sqlcreate | psql -U $RDS_USERNAME -h $RDS_HOSTNAME
    python manage.py migrate
}

setup_prod_db() {
    cd /code
    python manage.py migrate
}

case "$1" in
    manage )
        cd /code/
        python manage.py "${@:2}"
    ;;
    setuplocaldb )
        setup_local_db
    ;;
    setupproddb )
        setup_prod_db
    ;;
    start )
        cd /code
        ln -sf /code/ureport/settings.py.${ENV} /code/ureport/settings.py
        python manage.py collectstatic --noinput &
        /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
    ;;
    test)
      cd /code
      coverage run --source="." manage.py test ureport ureport/admins ureport/assets ureport/contacts ureport/countries ureport/jobs ureport/locations ureport/news ureport/polls ureport/public ureport/utils --verbosity=2 --noinput
    ;;
    bash )
        bash
    ;;
    *)
        show_help
    ;;
esac

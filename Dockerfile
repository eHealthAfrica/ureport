FROM ubuntu:14.04

ENV HOME /root

ENV TERM screen-256color

RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

ADD conf/apt-packages.txt /tmp/apt-packages.txt
RUN apt-get update -qq && cat /tmp/apt-packages.txt | xargs apt-get --yes --force-yes install

ADD conf/npm-packages.txt /tmp/npm-packages.txt
RUN cat /tmp/npm-packages.txt | xargs npm install -g

ADD pip-requires.txt /tmp/requirements_requires.txt
RUN pip install -r /tmp/requirements_requires.txt  

ADD pip-freeze.txt /tmp/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /tmp/requirements.txt  
RUN pip install coveralls

RUN mkdir -p /var/log/ureport

ADD conf/entrypoint.sh /usr/local/bin/entrypoint.sh 
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /etc/supervisor/conf.d && mkdir -p /var/log/supervisor

ADD conf/nginx.ureport.conf /etc/nginx/sites-enabled/default

WORKDIR /code
RUN mkdir -p /var/www/static && chmod -R 760 /var/www/static/ && chown -R www-data:www-data /var/www/static

ADD ./ /code/

RUN ln -sf /code/conf/supervisor.ureport.conf /etc/supervisor/conf.d/ureport.conf
RUN ln -sf /code/conf/supervisord.conf /etc/supervisor/supervisord.conf
RUN ln -sf /usr/bin/nodejs /usr/bin/node

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["start"]

FROM resin/rpi-raspbian:wheezy
MAINTAINER ponteineptique <thibault.clerice[@]uni-leipzig.de>

# Install required packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing

# Install required packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git-core \
        zlib1g-dev \
        libxslt1-dev \
        libxml2-dev \
        python3 \
        python3-dev \
        python3-pip \
        build-essential \
        nginx \
        supervisor \
        redis-server \
        unzip

# Clone required resources
run mkdir /var/log/gunicorn

WORKDIR /code/

# Getting a corpus
RUN apt-get install unzip
RUN mkdir ./data
ADD https://github.com/PerseusDL/canonical-latinLit/archive/master.zip ./data/canonical-latinLit.zip
RUN cd ./data && unzip -q canonical-latinLit.zip

# Debug
RUN ls ./data

# Cloning
RUN git clone git://github.com/Capitains/Nautilus.git
RUN git clone git://github.com/Capitains/rpi-capitains-raspbian.git

# get python virtual env

# Get the capitains packages
ADD https://bootstrap.pypa.io/get-pip.py get-pip.py
RUN python3 get-pip.py && \
    pip3 install virtualenv

RUN python3 Nautilus/setup.py install && \
        pip3 install flask_nemo && \
        pip3 install gunicorn && \
        pip3 install requests

# Stop supervisor service as we'll run it manually
RUN service supervisor stop

# Expose Ports
EXPOSE 5000

# From rehabstudio/docker-gunicor-nginx
RUN pip install supervisor-stdout

# file management, everything after an ADD is uncached, so we do it as late as possible in the process.
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./nginx.conf /etc/nginx/nginx.conf

# restart nginx to load the config
RUN service nginx restart

# start supervisor to run our wsgi server
CMD supervisord -c /etc/supervisord.conf -n

# Clean up the distrib
RUN apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/*

# Define default command
CMD ["bash"]
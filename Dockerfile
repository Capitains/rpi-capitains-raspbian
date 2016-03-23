FROM resin/rpi-raspbian:jessie
MAINTAINER ponteineptique <thibault.clerice[@]uni-leipzig.de>

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

# Cloning
RUN git clone git://github.com/Capitains/Nautilus.git

# Get the capitains packages
RUN python3 Nautilus/setup.py install

RUN easy_install3 --upgrade pip
RUN pip3 install requests
RUN pip3 install flask_nemo
RUN pip3 install gunicorn
RUN pip3 install supervisor-stdout

# Expose Ports
EXPOSE 5000

# Stop supervisor service as we'll run it manually
RUN service supervisor stop

# Get the main app and configuration files
# File management (everything after an ADD is uncached) so we do it as late as possible in the process.
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./app.py ./app.py

# restart nginx to load the config
CMD service nginx stop
CMD ["nginx", "-g", "daemon off;"]

ADD https://github.com/PerseusDL/canonical-latinLit/archive/master.zip ./data/canonical-latinLit.zip
RUN cd ./data && unzip -q canonical-latinLit.zip

# start supervisor to run our wsgi server
CMD supervisord -c /etc/supervisord.conf -n

# Clean up the distrib
RUN apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/*
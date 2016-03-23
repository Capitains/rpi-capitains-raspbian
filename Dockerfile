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

RUN easy_install3 --upgrade pip
RUN cd Nautilus && python3 setup.py install
RUN pip3 install requests
RUN pip3 install flask_nemo
RUN pip3 install gunicorn
RUN pip3 install supervisor-stdout

# Required by supervisor which runs on python 2.7 apparently
RUN apt-get install python-setuptools && easy_install pip && pip2.7 install supervisor-stdout

# Stop supervisor service as we'll run it manually
RUN service supervisor stop
RUN service nginx stop

# Get the main app and configuration files
# File management (everything after an ADD is uncached) so we do it as late as possible in the process.
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./app.py ./app.py


ADD https://github.com/PerseusDL/canonical-latinLit/archive/master.zip ./data/canonical-latinLit.zip
RUN cd ./data && unzip -q canonical-latinLit.zip

# start supervisor to run our wsgi server
CMD ["nginx", "-g", "daemon off;"]
CMD supervisord -c /etc/supervisord.conf -n

# Expose right ports
EXPOSE 80

# Clean up the distrib
RUN apt-get -y autoremove && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/*

CMD ["bash"]
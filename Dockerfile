FROM resin/rpi-raspbian:wheezy
MAINTAINER ponteineptique <thibault.clerice[@]uni-leipzig.de>

# Install required packages
RUN apt-get update && apt-get install -y \ 
	git-core \
	zlib1g-dev \
	libxslt1-dev \
	libxml2-dev \
	python3.4-dev \
	python3.4-venv \
	python3-pip \
	build-essential \
	nginx \
	supervisor

# Clone required resources
RUN mkdir data && /
	git clone https://github.com/PerseusDL/canonical-latinLit.git
RUN git clone https://github.com/Capitains/Nautilus.git
RUN git clone https://github.com/Capitains/rpi-capitains-raspbian.git

# Get the capitains packages
RUN pyvenv-3.4 venv && \ 
	cd Nautilus && \
	venv/bin/python3.4 setup install && \
	venv/bin/pip install flask_nemo && \
	venv/bin/pip install gunicorn && \
	venv/bin/pip install requests

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
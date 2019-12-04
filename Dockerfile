# Let's use the official Passenger container.
FROM trafex/alpine-nginx-php7
MAINTAINER Jonas Plitt "jonas.plitt@rub.de"

# Clone our private GitHub Repository
USER root
RUN apk add --no-cache git

USER nobody
RUN git clone https://github.com/redflag237/fsr-webnacht.git /myapp/
RUN cp -R /myapp/* /home/app/
RUN chown app:app -R /home/app/

# Setup Gems
#RUN bundle install --gemfile=/home/app/Gemfile

# Setup Nginx
ENV HOME /root
RUN rm -f /etc/service/nginx/down
ADD myapp /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default

# Setup Database Configuration. Since we use both we'll add both here.
# This is done to preserve Docker linking of environment variables within Nginx.
#ADD postgres-env.conf /etc/nginx/main.d/postgres-env.conf
#ADD mongodb-env.conf /etc/nginx/main.d/mongodb-env.conf

# Clean-up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /myapp/

CMD ["/sbin/my_init"]
EXPOSE 80

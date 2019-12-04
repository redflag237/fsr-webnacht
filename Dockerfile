# Let's use the official Passenger container.
FROM trafex/alpine-nginx-php7
MAINTAINER Jonas Plitt "jonas.plitt@rub.de"

# Clone our private GitHub Repository
USER root
RUN apk add --no-cache git
RUN mkdir /myapp/
RUN mkdir /home/app/
RUN chmod o+rw /myapp/
RUN chmod o+rw /home/app/

USER nobody
RUN git clone https://github.com/redflag237/fsr-webnacht.git /myapp/
RUN ls -lisah /myapp/
RUN cp -R /myapp/* /home/app/
RUN ls -lisah /home/app/
#RUN chown app:app -R /home/app/
#RUN cp -R /home/app/ /var/www/html

# Setup Gems
#RUN bundle install --gemfile=/home/app/Gemfile

# Setup Nginx
#ENV HOME /root
#RUN rm -f /etc/service/nginx/down
#ADD myapp /etc/nginx/sites-enabled/
#RUN rm /etc/nginx/sites-enabled/default

# Setup Database Configuration. Since we use both we'll add both here.
# This is done to preserve Docker linking of environment variables within Nginx.
#ADD postgres-env.conf /etc/nginx/main.d/postgres-env.conf
#ADD mongodb-env.conf /etc/nginx/main.d/mongodb-env.conf

# Clean-up
USER root
RUN rm -rf /tmp/* /var/tmp/* /myapp/
#RUN apt clean && 

#CMD ["/sbin/my_init"]
#EXPOSE 80

# Switch to use a non-root user from here on
#USER nobody

# Add application
WORKDIR /var/www/html
#COPY --chown=nobody /home/app/ /var/www/html/
#RUN chmod o+rw /var/www/html
RUN cp -R /home/app/ /var/www/html/
#RUN chmod o-w /var/www/html
RUN ls -lisah /var/www/html/
RUN chown nobody:nobody /var/www/html/.*

USER nobody
# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
#HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

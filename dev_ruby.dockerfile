FROM phusion/passenger-ruby33:latest

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Enable NGINX
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
# Добавляем конфигурацию NGINX и passenger для приложения.
ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mkdir /home/app/webapp

# Config nginx. Можно создать файл конфигурации и включить его в контейнер.
# ADD secret_key.conf /etc/nginx/main.d/secret_key.conf
# ADD gzip_max.conf /etc/nginx/conf.d/gzip_max.conf

# Ruby 3.3.1
RUN ruby -v
RUN rm -f /etc/service/sshd/down

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# This copies your web app with the correct ownership.
COPY --chown=app:app ./ /home/app/webapp
ENV HOME /home/app/webapp
WORKDIR $HOME/
COPY Gemfile* $HOME/

# install node, yarn, webpack
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
RUN bash n lts
RUN npm install -g n
RUN n 14.19.0
RUN npm install --global yarn@1.22.4 webpack

# При создании образа будут предупреждения о запуске bundler от имени root. Отключаем.
RUN bundle config --global silence_root_warning 1
RUN bash -lc 'bundle install'

# Install JavaScript dependencies
RUN yarn install

# Set necessary environment variables for asset precompilation
ENV SECRET_KEY_BASE=798a3053a94cb2b5c828a4b72a33b25a2fa14f3635757816ff0cf6ab4a66772fd2baec7721e06ceb824f68a7f39e536fa93c187b880691419b588bff866b5ae9
ENV DATABASE_HOST=db
ENV DATABASE_USER=postgres
ENV DATABASE_PASSWORD=password
ENV DATABASE_NAME=db-primary

# Precompile assets
RUN RAILS_ENV=development bundle exec rake assets:precompile

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add the entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

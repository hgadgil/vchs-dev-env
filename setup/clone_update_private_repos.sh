#!/bin/sh

eval `ssh-agent`

ssh-add $HOME/.ssh/id_rsa

# -- INSTALL Service Controller
# -----------------------------
if [ ! -x $HOME/vchs/service_controller ] ; then
  git clone git@github-vchs:vchs/service_controller.git $HOME/vchs/service_controller
fi

if [ -x $HOME/vchs/service_controller ] ; then
  cd $HOME/vchs/service_controller
  git pull origin master

  bundle install

  # --- perform rails specific setup action
  # --- start from clean slate
  # bundle exec rake db:drop:all
  bundle exec rake db:migrate

fi


# -- INSTALL Echo Node/Gateway
# ----------------------------

if [ ! -x $HOME/vchs/echo ] ; then
  git clone git@github-vchs:vchs/echo.git $HOME/vchs/echo
fi

if [ -x $HOME/vchs/echo ] ; then
  cd $HOME/vchs/echo
  git pull origin master

  bundle install
fi


# -- INSTALL Service Controller CLI
# ---------------------------------

if [ ! -x $HOME/vchs/sc-cli ] ; then
  git clone git@github-vchs:vchs/sc-cli.git $HOME/vchs/sc-cli
fi

if [ -x $HOME/vchs/sc-cli ] ; then

  gem uninstall sc-cli -x -a

  cd $HOME/vchs/sc-cli
  git pull origin master

  bundle install
  gem build sc-cli.gemspec
  gem install sc-cli*.gem --no-ri --no-rdoc
fi

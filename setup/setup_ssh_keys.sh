#!/bin/sh

ssh_dir="/home/vagrant/.ssh"
authorized_keys_path="${ssh_dir}/authorized_keys"
pub_key_path="${ssh_dir}/id_rsa.pub"
priv_key_path="${ssh_dir}/id_rsa"

chmod 600 $priv_key_path

count=`grep "ci-cf-vchs" $authorized_keys_path | wc -l`

if [ "$count" -eq "0" ]  ; then
  echo "Adding ci-cf-vchs public key to authorized keys"
  cat $pub_key_path >> $authorized_keys_path;
fi

eval $(ssh-agent)

ssh-add "${ssh_dir}/id_rsa"



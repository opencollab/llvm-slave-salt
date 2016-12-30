#!/bin/sh

HOSTNAME=$(hostname -a)
NODE=$(grep $HOSTNAME secret.lst|cut -d" " -f1)
SECRET=$(grep $HOSTNAME secret.lst|cut -d" " -f2)

nohup java -jar slave.jar -jnlpUrl https://llvm-jenkins.debian.net/computer/$NODE/slave-agent.jnlp -secret $SECRET

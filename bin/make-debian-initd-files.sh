#! /bin/sh

set -e

COMMON_PARAMS="--param-app-home=/usr/share/jruby-jsvc/example --param-module-name=Crazy --param-debug=false --param-app-user=root --param-jruby-jsvc-jar=/usr/share/java/jruby-jsvc.jar --param-jsvc=/usr/bin/jsvc --param-jruby-home=/usr/lib/jruby --param-java-home=/usr/lib/jvm/java-6-openjdk"

NAME=$1
OUT_TO=$2

ruby -Ilib bin/jruby-jsvc-initd $COMMON_PARAMS --param-app-name=$NAME > $OUT_TO

#! /bin/sh
# Generic script for running ruby scripts as daemons using
# jsvc and a java class to control the daemon.
#
# Contains common parameters and start/stop

# Things you'll need to set on a per script/daemon basis:
# SCRIPT_NAME - Path to the ruby script which creates a Daemon
# object for jsvc to control
# APP_NAME - Name of your application
#
# Things you can set:
# PROG_OPTS - Arguments to send to the program. A few defaults are appended to this.

if [ -z ${SCRIPT_NAME} ]; then
    echo "SCRIPT_NAME not set"
    exit 1
fi

if [ -z ${MODULE_NAME} ]; then
    echo "MODULE_NAME not set"
    exit 1
fi

# Local development - uncomment these to use jsvc-daemon from a working copy
if [ "${JRUBY_DAEMON_DEV}" ]; then
    echo "jsvc-wrapper, in development mode"
    JSVC=`which jsvc`
    JAVA_HOME=`jruby -e 'puts Java::JavaLang::System.get_property("java.home")'`
    JRUBY_HOME=`jruby -e 'puts Java::JavaLang::System.get_property("jruby.home")'`
    APP_HOME=.
    PIDFILE=jsvc-$SCRIPT_NAME.pid
    LOG_DIR=log
    # Uncomment for debugging the daemon script
    JSVC_ARGS_EXTRA="-debug -nodetach "
    JAVA_PROPS="-DJRubyDaemon.debug=true"

    echo "JAVA_HOME  : $JAVA_HOME"
    echo "JRUBY_HOME : $JRUBY_HOME"
else
    # Standard install
    JSVC=/usr/bin/jsvc
    JAVA_HOME=/usr/lib/jvm/java-6-sun
    JRUBY_HOME=/usr/lib/jruby1.4
    APP_HOME=/usr/lib/$APP_NAME
    USER=$APP_NAME
    PIDFILE=/var/run/$APP_NAME/jsvc-$SCRIPT_NAME.pid
    LOG_DIR=/var/log/$APP_NAME
fi

# If you want your programs to run as or not as daemons pass a flag to tell them which they are
PROG_OPTS="$PROG_OPTS --no-log-stdout --daemon"

# Implements the jsvc Daemon interface.
MAIN_CLASS=com.msp.jsvc.JRubyDaemon

RUBY_SCRIPT=$APP_HOME/bin/$SCRIPT_NAME

# Set some jars variables if they aren't already there
if [ ${#MSP_JSVC_JAR} -eq 0 ]; then
    MSP_JSVC_JAR=/usr/share/java/msp-jsvc.jar
fi
if [ ${#DAEMON_JAR} -eq 0 ]; then
    DAEMON_JAR=/usr/share/java/commons-daemon.jar
fi

CLASSPATH=$JRUBY_HOME/lib/jruby.jar:$JRUBY_HOME/lib/profile.jar:$DAEMON_JAR:$MSP_JSVC_JAR

echo "CLASSPATH  : $CLASSPATH"

JAVA_PROPS="$JAVA_PROPS -Djruby.memory.max=500m \
-Djruby.stack.max=1024k \
-Djna.boot.library.path=$JRUBY_HOME/lib/native/linux-i386:$JRUBY_HOME/lib/native/linux-amd64 \
-Djffi.boot.library.path=$JRUBY_HOME/lib/native/i386-Linux:$JRUBY_HOME/jruby/lib/native/s390x-Linux:$JRUBY_HOME/lib/native/x86_64-Linux \
-Djruby.home=$JRUBY_HOME \
-Djruby.lib=$JRUBY_HOME/lib \
-Djruby.script=jruby \
-Djruby.shell=/bin/sh
-Djruby.daemon.module.name=$MODULE_NAME"

JAVA_OPTS="-Xmx500m -Xss1024k -Xbootclasspath/a:$JRUBY_HOME/lib/jruby.jar:$JRUBY_HOME/lib/bsf.jar"

JSVC_ARGS="-home $JAVA_HOME \
$JSVC_ARGS_EXTRA \
-wait 20 \
-pidfile $PIDFILE \
-user $USER \
-procname jsvc-$SCRIPT_NAME \
-jvm server"

if [ not "${JRUBY_DAEMON_DEV}" ]; then
    JSVC_ARGS="$JSVC_ARGS \
-outfile $LOG_DIR/jsvc-$SCRIPT_NAME.log \
-errfile &1"
fi

#
# Stop/Start
#

STOP_COMMAND="$JSVC $JSVC_ARGS -stop $MAIN_CLASS"
START_COMMAND="$JSVC $JSVC_ARGS -cp $CLASSPATH $JAVA_PROPS $JAVA_OPTS $MAIN_CLASS $RUBY_SCRIPT $PROG_OPTS"

case "$1" in
    start)
	if [ -e "$PIDFILE" ]; then
	    echo "Pidfile already exists, not starting."
	    exit 1
	else
	    echo "Starting $SCRIPT_NAME daemon..."
	    $START_COMMAND
	    EXIT_CODE=$?
	    if [ "$EXIT_CODE" != 0 ]; then
		echo "Daemon exited with status: $EXIT_CODE. Check pidfile and log"
	    fi
	fi
	;;
    stop)
	if [ -e "$PIDFILE" ]; then
	    echo "Stopping $SCRIPT_NAME daemon..."
	    $STOP_COMMAND
	else
	    echo "No pid file, not stopping."
	    exit 1
	fi
	;;
    restart)
	if [ -e "$PIDFILE" ]; then
	    echo "Stopping $SCRIPT_NAME daemon..."
	    $STOP_COMMAND
	fi
	if [ -e "$PIDFILE" ]; then
	    echo "Pidfile still present, $SCRIPT_NAME hasn't stopped"
	    exit 1
	else
	    $START_COMMAND
	    EXIT_CODE=$?
	    if [ "$EXIT_CODE" != 0 ]; then
		echo "Daemon exited with status: $EXIT_CODE. Check pidfile and log"
	    fi
	fi
	;;
    status)
	if [ "$PIDFILE" ]; then
	    PID=`cat $PIDFILE`
	    OUTPUT=`ps $PID | egrep "^$PID "`
	    if [ ${#OUTPUT} -gt 0 ]; then
		echo "Service running with pid: $PID"
	    else
		echo "Pidfile present, but process not running"
	    fi
	else
	    echo "No pidfile present"
	fi
	;;
    *)
	echo "Unrecognised command. Usage jsvc-daemon [ start | stop ]"
	;;
esac
#!/bin/bash
# vim:set et ts=2 sw=2:
# set -x

ZOOK_DIR="/zookeeper"
JDK_OPTS="/java-options.conf"

LOGS_DIR="$(pwd)/logs"
DATA_DIR="$(pwd)/data"

if [ -f  "${JDK_OPTS}" ];then
  source "${JDK_OPTS}"
else
  JDK_OPTIONS="-Xms128M -Xmx512M"
fi

JMX_OPTS="-Dcom.sun.management.jmxremote \
          -Dcom.sun.management.jmxremote.local.onlyl.only=false \
          -Dcom.sun.management.jmxremote.authenticate=false \
          -Dcom.sun.management.jmxremote.ssl=false"

CLASSPATH=""
for jar in $(find ${ZOOK_DIR} -name "*.jar"); do
  CLASSPATH="$jar:$CLASSPATH"
done
CLASSPATH="${CLASSPATH}$ZOOK_DIR/conf:$ZOOK_DIR:/home/jdk/bin:/home/jdk/jre/bin"

cd $ZOOK_DIR
exec /home/jdk/bin/java \
       -Dzookeeper.log.dir="$LOGS_DIR" \
       -Dzookeeper.root.logger="INFO,CONSOLE"  \
       -cp "$CLASSPATH" \
       $JMX_OPTS $JDK_OPTIONS \
       org.apache.zookeeper.server.quorum.QuorumPeerMain \
       ${ZOOK_DIR}/conf/zoo.cfg \
    1> >(exec /usr/bin/cronolog ${LOGS_DIR}/stdout.txt-%Y%m%d >/dev/null 2>&1)
    #2> >(exec /usr/bin/cronolog ${LOGS_DIR}/stderr.txt-%Y%m%d >/dev/null 2>&1)

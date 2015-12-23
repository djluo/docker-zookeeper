FROM       docker.xlands-inc.com/baoyu/java8
MAINTAINER djluo <dj.luo@baoyugame.com>

ENV ZooVer 3.4.7

RUN export http_proxy="http://172.17.42.1:8080/" \
    && BIN="http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-${ZooVer}/zookeeper-${ZooVer}.tar.gz" \
    && curl -sLo   /download $BIN \
    && tar xf /download -C / \
    && rm -fv /download \
    && mkdir  /zookeeper \
    && cp -a  /zookeeper-${ZooVer}/bin  /zookeeper/ \
    && cp -a  /zookeeper-${ZooVer}/lib  /zookeeper/ \
    && cp -a  /zookeeper-${ZooVer}/conf /zookeeper/ \
    && cp -a  /zookeeper-${ZooVer}/*jar /zookeeper/ \
    && rm -rf /zookeeper-${ZooVer}

COPY ./main.sh       /
COPY ./entrypoint.pl /

ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/main.sh"]

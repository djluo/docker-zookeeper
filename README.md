
Servers="192.168.9.7:1611:1612,192.168.9.7:1621:1622,192.168.9.7:1631:1632"

node1="${Parent:=/home/zookeeper}/node1"
sudo docker run -d --net=host \
     -e Servers="$Servers" \
     -e clientPort=1610 \
     -e Current_Servers=192.168.9.7:1611:1612 \
     -w ${node1} -v ${node1}:${node1} \
     --name node1 zook /main.sh

node2="${Parent}/node2"
sudo docker run -d --net=host \
     -e Servers="$Servers" \
     -e clientPort=1620 \
     -e Current_Servers=192.168.9.7:1621:1622 \
     -w ${node2} -v ${node2}:${node2} \
     --name node2 zook /main.sh

node3="${Parent}/node3"
sudo docker run -d --net=host \
     -e Servers="$Servers" \
     -e clientPort=1630 \
     -e Current_Servers=192.168.9.7:1631:1632 \
     -w ${node3} -v ${node3}:${node3} \
     --name node3 zook /main.sh

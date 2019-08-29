# 서비스설정
bash config.sh --seed-ip=192.168.0.15 --seed-port=7070 --launcher-ip=192.168.0.15 --launcher-port=7080 --launcher-nodem-port=18880 --na-ip=192.168.0.15 --na-port=8050 --nodehome-service-ip=192.168.0.15 --nodehome-service-port=7081 --nodehome-nodem-port=18881 run

# 서비스시작
bash run-service-nodes.sh start 

# 서비스종료
bash run-service-nodes.sh stop

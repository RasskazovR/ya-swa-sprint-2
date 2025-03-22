#!/bin/bash

###
# Инициализация сервера конфигурации
###
echo -e "--Инициализация конфигурационного сервера--\n"
docker exec -i rr-config-server mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "rr-config-server",
    configsvr: true,
    members: [
      { _id : 0, host : "rr-config-server:27017" }
    ]
  }
);
exit();
EOF
echo -e "\n"

###
# Инициализация первого шарда
###
echo -e "\n--Инициализация первого шарда--\n"
docker exec -i rr-shard-one mongosh --port 27018 --quiet <<EOF
rs.initiate(
  {
    _id:"rr-shard-one",
    members: [
      {
        _id: 0, host:"rr-shard-one:27018"
      }
    ]
  }
);
exit();
EOF
echo -e "\n"

###
# Инициализация второго шарда
###
echo -e "\n--Инициализация второго шарда--\n"
docker exec -i rr-shard-two mongosh --port 27019 --quiet <<EOF
rs.initiate(
  {
    _id:"rr-shard-two",
    members: [
      {
        _id: 0, host:"rr-shard-two:27019"
      }
    ]
  }
);
exit();
EOF
echo -e "\n"

###
# Ожидание запуска контейнера с роутером
###
echo -ne "\n --- Ожидаем запуск роутера"
for i in {1..8}; do
  sleep 1;
  echo -n "."
done
echo -e "!\n"

###
# Иницализация роутера
###
echo -e "\n--Инициализация роутера--\n"
docker exec -i rr-mongo-router mongosh --port 27020 --quiet <<EOF
sh.addShard( "rr-shard-one/rr-shard-one:27018");
sh.addShard( "rr-shard-two/rr-shard-two:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
exit();
EOF
echo -e "\n"

###
# Иницализация БД
###
echo -e "\n--Инициализация БД--\n"
docker exec -i rr-mongo-router mongosh --port 27020 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
db.helloDoc.countDocuments() 
exit();
EOF
echo -e "\n"

###
# Проверка шардов
###
echo -e "\n--Количество документов на первом шарде--\n"
docker exec -i rr-shard-one mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments() 
exit();
EOF
echo -e "\n"
echo -e "\n--Количество документов на втором шарде--\n"
docker exec -i rr-shard-two mongosh --port 27019 --quiet <<EOF
use somedb
db.helloDoc.countDocuments() 
exit();
EOF
echo -e "\n"

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
# Ожидание запуска контейнера с роутером
###
echo -ne "\n --- Ожидаем запуск роутера"
for i in {1..10}; do
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

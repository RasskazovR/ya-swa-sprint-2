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
# Инициализируем бд
###

#docker compose exec -T shard-one mongosh <<EOF
#use somedb
#for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
#EOF


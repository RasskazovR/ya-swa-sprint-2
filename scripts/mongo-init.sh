#!/bin/bash

docker compose exec -ti rr-config-server mongosh --port 27017 --quiet <<EOF
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

#docker compose exec -T <service-name> mongosh --port <mongo port> --quiet <<EOF
#<mongosh commands here>
#EOF 

###
# Инициализируем бд
###

#docker compose exec -T shard-one mongosh <<EOF
#use somedb
#for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
#EOF


#!/bin/bash

KEYFILE=/tmp/keyfile
INIT_FLAG=/data/db/.init-done

cp /keyfile/rs_keyfile "$KEYFILE"
chmod 600 "$KEYFILE"
chown mongodb:mongodb "$KEYFILE"

if [ ! -f "$INIT_FLAG" ]; then
  echo "🔓 Primera vez: iniciando mongod sin auth para configuración"

  mongod --replSet rs0 --bind_ip_all --port 27017 --keyFile "$KEYFILE" > /tmp/mongod.log 2>&1 &
  echo "⏳ Esperando a que Mongo esté listo..."
  until mongosh --eval "db.adminCommand('ping')" &>/dev/null; do
    sleep 1
  done

  echo "⚙️ Iniciando replicaset..."
  mongosh --eval 'rs.initiate({
    _id: "rs0",
    members: [ { _id: 0, host: "localhost:27017" } ]
  })'

  sleep 2

  echo "👤 Creando usuarios..."
  mongosh --eval '
    db = db.getSiblingDB("admin");
    db.createUser({
      user: "root",
      pwd: "12345678",
      roles: [ { role: "root", db: "admin" } ]
    });
  '
  sleep 2
  touch "$INIT_FLAG"

  echo "🛑 Deteniendo mongod temporal..."
  mongod --shutdown



  exec mongod --replSet rs0 --bind_ip_all --port 27017 --keyFile "$KEYFILE" --auth > /tmp/mongod.log 2>&1 &
  sleep 2

  echo "Creando app"
  mongosh -u root -p 12345678 --eval '
    db = db.getSiblingDB("mongochat");
    db.createUser({
      user: "springapp",
      pwd: "app123",
      roles: [ { role: "readWrite", db: "mongochat" } ]
    });
  '
  sleep 2
  echo "🛑 Deteniendo mongod temporal..."
  mongod --shutdown
fi

echo "🔐 Iniciando mongod con autenticación"
exec mongod --replSet rs0 --bind_ip_all --port 27017 --keyFile "$KEYFILE" --auth


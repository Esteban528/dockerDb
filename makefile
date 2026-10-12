.PHONY: mysql mongo mongorp postgres redis down

HAS_DOCKER := $(shell docker -v 2>/dev/null)
CMD := $(if $(HAS_DOCKER),docker,podman)

mysql:
	cd ./MySQL && ${CMD} compose up

mongo:
	cd ./Mongo && ${CMD} compose up

mongorp:
	cd ./Mongo-ReplicaSet && ${CMD} compose up

postgres:
	cd ./Postgres && ${CMD} compose up

redis:
	cd ./Redis && ${CMD} compose up

down:
	${CMD} compose down --remove-orphans

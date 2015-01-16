.PHONY: all build riak-container start test stop

all: stop riak-container start

build riak-container:
	docker build -t "luman75/riak:2.0.4" .

start:
	./bin/start-cluster.sh

restart: start stop

types:
	docker exec -it "riak01" "/sbin/register-types.sh"

test:
	./bin/test-cluster.sh

stop:
	./bin/stop-cluster.sh

start-bash:
	docker run --rm -t -i "luman75/riak:2.0.4" bash

bash: stop build start-bash
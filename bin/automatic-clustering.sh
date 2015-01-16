#! /bin/sh

echo "Register"  >> /tmp/automatic

if env | grep -q "DOCKER_RIAK_AUTOMATIC_CLUSTERING=1"; then
  # Join node to the cluster
  if env | grep -q "SEED_PORT_8098_TCP_ADDR"; then
    /usr/local/bin/riak-admin cluster join "riak@${SEED_PORT_8098_TCP_ADDR}" >> /tmp/automatic 2>&1
  fi

  # Are we the last node to join?
  sleep 5.
  if /usr/local/bin/riak-admin member-status | egrep "joining|valid" | wc -l | grep -q "${DOCKER_RIAK_CLUSTER_SIZE}"; then
    echo "Commiting cluster" >> /tmp/automatic
    /usr/local/bin/riak-admin cluster plan >> /tmp/automatic 2>&1 && riak-admin cluster commit >> /tmp/automatic 2>&1
  fi
fi

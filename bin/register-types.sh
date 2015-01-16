#! /bin/sh
echo "Register specific data types for type oriented buckets"  >> /tmp/automatic

/usr/local/bin/riak-admin bucket-type create maps '{"props":{"datatype":"map"}}' >> /tmp/automatic
/usr/local/bin/riak-admin bucket-type activate maps

/usr/local/bin/riak-admin bucket-type create sets '{"props":{"datatype":"set"}}' >> /tmp/automatic
/usr/local/bin/riak-admin bucket-type activate sets

/usr/local/bin/riak-admin bucket-type create counters '{"props":{"datatype":"counter"}}' >> /tmp/automatic
/usr/local/bin/riak-admin bucket-type activate counters
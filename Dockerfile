# Riak
#
# VERSION       1.0.3

FROM luman75/mobibase:14.04-1
MAINTAINER  Lukasz Dutka lukasz.dutka@gmail.com

# Environmental variables
ENV DEBIAN_FRONTEND noninteractive

# Install Java 7
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y software-properties-common && \
    apt-add-repository ppa:webupd8team/java -y && apt-get update -qq && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer telnet mc bash-completion git build-essential

RUN apt-get install -y libwxbase2.8-0 libwxgtk2.8-0

# Install Erlang
RUN  cd &&\
	wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_16.b.3-1~ubuntu~precise_amd64.deb && \
	dpkg -i esl-erlang_16.b.3-1~ubuntu~precise_amd64.deb && \
	rm -rf esl-erlang_16.b.3-1~ubuntu~precise_amd64.deb


# Install riak dependencies
RUN apt-get install -y libpam0g-dev

RUN cd && \
	git clone --branch riak-2.0.4 https://github.com/basho/riak.git && \
	cd /root/riak && \
	make rel


RUN groupadd -r riak && useradd -d /var/lib/riak -g riak riak

# installing riak release
RUN  mv /root/riak/rel/riak /usr/lib && \
    chown -R riak:riak /usr/lib/riak && \
    ln -s /usr/lib/riak/etc /etc/riak && \
    ln -s /usr/lib/riak/log /var/log/riak && \
    ln -s /usr/lib/riak/data /var/lib/riak && \
    rm -rf  /usr/local/bin && \
    ln -s /usr/lib/riak/bin /usr/local/bin 

ADD conf /etc/riak

## Setup the Riak service
RUN mkdir -p /etc/service/riak
ADD bin/riak.sh /etc/service/riak/run

# Setup automatic clustering
ADD bin/automatic-clustering.sh /sbin/automatic-clustering.sh
ADD bin/register-types.sh /sbin/register-types.sh


## Tune Riak configuration settings for the container
RUN sed -i.bak 's/listener.http.internal = 127.0.0.1/listener.http.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    sed -i.bak 's/listener.protobuf.internal = 127.0.0.1/listener.protobuf.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    sed -i.bak 's/riak_control = off/riak_control = on/' /etc/riak/riak.conf && \
    echo "anti_entropy.concurrency_limit = 1" >> /etc/riak/riak.conf && \
    echo "javascript.map_pool_size = 0" >> /etc/riak/riak.conf && \
    echo "javascript.reduce_pool_size = 0" >> /etc/riak/riak.conf && \
    echo "javascript.hook_pool_size = 0" >> /etc/riak/riak.conf

# Make Riak's data and log directories volumes
VOLUME /var/lib/riak
VOLUME /var/log/riak

# Open ports for HTTP and Protocol Buffers
EXPOSE 8098 8087


# Enable insecure SSH key
# See: https://github.com/phusion/baseimage-docker#using_the_insecure_key_for_one_container_only
#RUN /usr/sbin/enable_insecure_key

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Leverage the baseimage-docker init system
CMD ["/sbin/my_init", "--quiet"]


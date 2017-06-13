FROM centos:7
MAINTAINER Kunal Limaye <klimaye@redhat.com>

USER root
RUN yum -y install epel-release && yum -y install nodejs git

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/CentOS/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r nodeuser -g 1000 && useradd -u 1000 -r -g nodeuser -m -d /opt/nodeuser -s /sbin/nologin -c "Node.js user" nodeuser && \
    chmod 755 /opt/nodeuser

# Set the working directory to nodeuser' user home directory
WORKDIR /opt/nodeuser

# Specify the user which should be used to execute all commands below
USER nodeuser

RUN git clone https://github.com/openshift/nodejs-ex && cd nodejs-ex && npm install

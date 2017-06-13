# why-container-orchestration


# Local build of Node.js application

## I am very excited about the uber cool Node.js app that we are developing.  Lets get on with it on my Mac...

```bash
git clone https://github.com/openshift/nodejs-ex
cd nodejs-ex
npm install
node server.js
```

# Hang on but why containers?

## Because its uber cool
## Well Docker is the answer, what was your question again?
## Well you know its sort of portable...lets have a look

1. **Create a template**

   ```DOCKERFILE
   FROM centos:7
   # Dockerfile to use to build the nodejs application
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
   ```
2. **Standardise the build process**

   ```bash
   docker build \
       --file Dockerfile \
       --rm \
       --tag nodejs .
   ```
3. **Run that bad boy <kbd>nodejs</kbd> anywhere. Even Cloud!**

   ```bash
   docker run -it -p 8081:8080 nodejs bash
   cd nodejs-ex
   node server.js
   ```
   > You should be able to access the application at [localhost:8081](localhost:8081)
4. **Hang on it gets better.  To service increased demand I can start horizontal SCALING!**

   ```bash
   docker run -it -p 8082:8080 nodejs bash
   cd nodejs-ex
   node server.js
   ```
   > You should be able to access the application at [localhost:8082](localhost:8082)

5. But aren't they two separate application instances?  Correctamundo!

6. Not to worry we will stand up a load balancer in front of it.  And register the application instances manually into it?  Especially when we introduce change (newer version) of the application...

7. OK may be lets use a **smart proxy** that auto-magically registers/de-registers application instances.  Yeehaw!  

8. OK lets think about this whole **orchestration piece**

    1. Security - RBAC, project and application level isolation, audit trail, etc.
    2. Self service UI for developers
    3. Rolling upgrades - canary deployment, blue-green deployment, A/B testing
    4. Scaling - horizontal scale-in and scale-out to meet demand
    5. Integrated docker registry - where and which images I use is very important
    6. Lifecycle management of application images

9. Let me give you a very brief view of it.

   ```bash
   oc cluster up --create-machine=true   \
                   --use-existing-config   \
                   --host-data-dir=/mydata \
                   --image=registry.access.redhat.com/openshift3/ose \
                   --version=latest   ```

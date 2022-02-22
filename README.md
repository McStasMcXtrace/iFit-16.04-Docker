# iFit-16.04-Docker
Minimal Ubuntu 16.04-based docker-solution to run iFit 

# Building
```
docker build --tag mccode/ubuntu-16.04-ifit .
```

# dockerhub
The image has been uploaded to dockerhub and can be run using e.g.
```
docker run -ti -u docker -w /home/docker -v $HOME/iFit-docker:/home/docker/host docker.io/mccode/ubuntu-16.04-ifit /usr/local/bin/ifit
```

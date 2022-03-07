# Benchmarking on Kata Containers

These are the tools for running our benchmark on the Kata Containers.

## Step 1: Installl Kata Containers

[Kata's official website](https://github.com/kata-containers/documentation/tree/master/install) offers different installation options per Linux distribution.

## Step 2: Install Docker

We will be using Docker to manager our Kata Containers.

[Docker's official website](https://docs.docker.com/engine/install/) offers steps to install on a myriad of Linux distributions.

Don't forget to run the [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) to be able to use Docker straight away:
```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
$ newgrp docker
```

## Step 3: Configure Docker to use Kata Containers

We're going to integrate Kata Containers with Docker:

We do this by creating a Docker configuration file.
First we create the directory for the configuration:
```
$ sudo mkdir -p /etc/docker
$ sudo chown root:docker /etc/docker
```

And then we create the configuration file - `/etc/docker/daemon.json` with the following content (since we installed Kata using `snap`):
```
{
  "runtimes": {
    "kata": {
      "path": "/snap/bin/kata-containers.runtime"
    }
  }
}
```

Restart Docker to make sure the changes kick-in:
```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

## Step 4: Test it

Run: `docker run -it --runtime kata alpine:latest` and pray to the Linux god you see a shell.

From a different terminal, if we run `ps aux | grep kata`, we can see the QEMU instance that is actually running the VM:
```
root       17717 18.7  0.5 2644380 177240 ?      Sl   01:47   0:00 /snap/kata-containers/686/usr/bin/qemu-system-aarch64 ...
```

## Step 5: Create a Docker image with our web server

Copy the `webd` binary into the current directory.

Create a new Dockerfile with the following content:
```
FROM alpine:latest

WORKDIR /app
COPY webd .

CMD ["./webd", "9090"]
EXPOSE 9090
```

And create a new Docker image using:
```
docker build . -t webd
```

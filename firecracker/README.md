# Benchmarking on Firecracker VMM

These are the tools for running our benchmark on the Firecracker VMM.

In order to measure boot-up time, we want to automate the process of starting a VM running our webserver.
We want to be able to run a single command on the host that will create and set up everything.

## Step 0: Prepare the host

Before we can run Firecracker, we have to make sure we have the KVM kernel module loaded on our host machine.

We can verify that using `lsmod | grep kvm`

## Step 1: Getting Firecracker

We will be using:
- A pre-compiled binary of Firecracker's latest official release from their [Github repository](https://github.com/firecracker-microvm/firecracker).
- Firecracker's quick start guide [linux image](https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/aarch64/kernels/vmlinux.bin) and [filesystem](https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/aarch64/rootfs/bionic.rootfs.ext4)

Get all those by simply running the `setup-firecracker.sh` script. It will:
- Download the latest Firecracker binary and copy that into `/usr/local/bin`
- Download the linux image
- Download the root filesystem

## Step 2: Creating a network tap for (each) VM

To connect the Firecracker to the host, and possibly to the global network, one has to create a tap device.

A tap device is a kernel virtual network device, implemented entirely in software.
Network tap devices simulate a link layer device and operates in layer 2 carrying Ethernet frames.

Packets sent by an operating system via a tap device are delivered to a user space program which attaches itself to the device, in this case, the Firecracker VMM.
When the Firecracker VMM passes packets into the tap, the device injects these packets into the OS's network stack, as if they were recieved from an external source.

To create and configure a tap device, we run our `setup-tap.sh` script.
Basically, we receives the a tap name and IP address, and sets everything up.

Because we are going to run multiple VMs simultaneously, our script is already adjusted to creating multiple taps with multiple IDs.

If we examine all addresses assigned to our network adapters, we will find our tap device:
```
3: tap0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 06:8f:e6:cd:d3:a7 brd ff:ff:ff:ff:ff:ff
    inet 169.254.0.2/30 scope global tap0
       valid_lft forever preferred_lft forever
``` 

## Step 3: Create the Firecracker configuration

Now, we prepare a configuration file for our Firecracker instances.
We will use JSON configuration files (rather then the REST API published by Firecracker for improved performance).

We will generate on-the-fly a configuration file for every instance we start based on the following schema:
```
{
  "boot-source": {
    "kernel_image_path": "vmlinux",
    "boot_args": "keep_bootcon console=ttyS0 reboot=k panic=1 pci=off ip=<guest-ip>::<tap-ip>:<tap-long-mask>::eth0:off"
  },
  "drives": [
    {
      "drive_id": "rootfs",
      "path_on_host": "rootfs.ext4",
      "is_root_device": true,
      "is_read_only": false
    }
  ],
  "network-interfaces": [
    {
      "iface_id": "eth0",
      "guest_mac": "<tap-mac>",
      "host_dev_name": "<tap-id>"
    }
  ],
  "machine-config": {
    "vcpu_count": 1,
    "mem_size_mib": 128
  }
}
```

## Step 4: Light up a Firecracker

We'll combine all of those steps together. We'll use a script to light up firecrackers - `run-firecracker.sh`.

The script will receive a firecracker ID (we already know we wanna run many of those simultaneously),
create the network resources (i.e. network tap), configuration file, and run everything.

## Step 5: Preparing our VM

When we run the `firecracker` command, we will see our VM booting (surprisingly fast!):
```
[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.14.174+ (ubuntu@dpopa-arm) (gcc version 7.5.0 (Ubuntu/Linaro 7.5.0-3ubuntu1~18.04)) #14 SMP Mon Nov 23 20:44:24 UTC 2020
[    0.000000] Boot CPU: AArch64 Processor [410fd083]
...
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.
         Starting Update UTMP about System Runlevel Changes...
[  OK  ] Started Update UTMP about System Runlevel Changes.

Ubuntu 18.04.5 LTS ubuntu-fc-uvm ttyS0

ubuntu-fc-uvm login: root (automatic login)

Welcome to Ubuntu 18.04.5 LTS (GNU/Linux 4.14.174+ aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
root@ubuntu-fc-uvm:~#
```

Unfortunately, the SSH public keys are not well configured,
so we have to replace the `~/.ssh/authorized_keys` with a file containing our public key from a set of newly generated SSH keys.
(If you need help with that, check out [this link](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)).

**Note: We only have to do that once! Because we started the OS with our file system in RW mode!**

## Step 6: Configure our webserver inside the VM 

Once SSH is configured correctly, we can easily SCP our `server` application directory into the VM.
(NOTE: The application was compiled on the host, which is using the same ARM architecture).
```
scp -r server root@169.254.0.1:/usr/local/bin/.
```

Now, we can SSH back into the VM and finish the configuration.
We want our VM to behave like a container, i.e. starting our web daemon (`webd`) application the moment it boots.
In order to accomplish that, we are first going to "install" our application and register it to run on startup.
Check out the exact steps in the [server's README](server/README.md), under "Installation" and "Register for startup".

## Step 7: Check everything works end-to-end

Let's shutdown our VM from the inside by running `shutdown now` and see if the configuration worked.

When we now execute `firecracker-run.sh 0`, we expect everything, including our web daemon application to be running on port 9090.
We'll verify that by running `curl 169.254.0.1:9090` from a second terminal window.
Fortunaly, the result is as expected:
```
$ curl 169.254.0.1:9090
Request #1
```
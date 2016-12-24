---
title:  "Building an Centos image, (especially) on a Ubuntu host"
category: recipes
permalink: building-centos-ubuntu-host
---

This recipe describes how to build an Centos image using Singularity on a Ubuntu compatible host. 

**NOTE: this tutorial is intended for [Singularity release 2.2](http://singularity.lbl.gov/release-2-2), and reflects standards for that version.**


In theory, Ubuntu host can create/bootstrap a centos image by installing the 'yum' package.  However, because the rpm tool can only operate on a very specific version of Berkeley DB, which tends to differ from the 'libdb' on the Ubuntu host, this result in a very messy situation for singularity to deal with.  A perfectly working centos.def file that can bootstrap a centos image from a centos compatible host will not work when executed on Ubuntu, yielding an error like this:


```
YumRepo Error: All mirror URLs are not using ftp, http[s] or file.
Eg. Invalid release/
removing mirrorlist with no valid mirrors: /var/cache/yum/x86_64/$releasever/base/mirrorlist.txt
Error: Cannot find a valid baseurl for repo: base
ERROR: Aborting with RETVAL=255   
```

The erros is because during the bootstrae process, Ubuntu would have used its version of Berkeley DB to create the rpm database in the centos image.  Subsequent feature add on the image using 'yum' fails because it is unable parse the Berkeley DB to read the releasever variable, since it is a different version.    

This problem is not exclusive to Ubuntu.  Other flavor of Linux likely have the same problem.  In fact, building Centos image hosted by a newer centos host have the same problem.  

There are a number of solutions:

	1.  Obtain db*_load that match the Berkeley DB version for the version of Centos being imaged, and add a conversion step  during singularity bootstrap process.
	2.  Perform a double bootstrap process: Build a base container containg Centos (eg import from docker) and use this image to build the final desired centos image.  One can run container from within containers with Singularity as long as you are root when you do it.  
	3.  Go to a Centos machine and create a basic singularity image, and copy this image to the ubuntu machine.  Since such image already have a working /bin/sh, an RPM database with the correct version of Berkeley DB, subsequent 'singularity bootstrap' on this image can successfully run 'yum' to update and add additional software to this image.
	4.  Leverate `singularity import centos.img docker://centos:6` to seed the centos image
	5.  Import the container from Singularity Hub, when this feature becomes available.


## Step by step instructions for option 3

	1. Identify a centos machine with the same major version of centos version you want to build.  Don't use a CentOS-7 machine to build a CentOS-6 machine, it won't work.  (Building a CentOS-7 image on a CentOS-6 host works--on the surface, but RPM db is duplicated?)  ++FIXME++
	3. Install singularity on this host.  Locate the centos.def file from the example/ directory.
	2. Run `sudo singularity create /tmp/centos.img`  
	3. Run `sudo singularity bootstrap /tmp/centos.img centos.def`
	4. Copy /tmp/centos.img to host wanting to run the container, eg the Ubuntu host.
	5. On the ubuntu host, can execute the centos container as `singularity shell centos.img`
	6. If further update is desired on this image, update the centos.def as desired, then run `singularity bootstrap centos.img centos.def`.  At this stage, this works because the container already has the minimum ingredients to run yum from its own content.   There isn't even a need to install `yum` on the Ubuntu host.

	* ++ does this really work?  or still have a DB version conflict?
++


## Option 1 and 2

If you decide to pursuade this option, refer to this thread on the mailing list...


## Caveat Emptor

If building CentOS image from an Ubuntu host, one can seemingly use `yum --releasever=6` to get yum to work and get a container build.  This kinda work, but some packages maybe installed twice while others may not be consistent, since `yum` is not able to properly query the rpm database created in the first stage of the bootstrap process.


## Under the hood

(initial bootstrap from an empty image need yum, but after a basic image w/ /bin/sh and yum in place, yum from inside the container is called.  
rpm command is NOT needed during the bootstrap)


++

In order to do this, you will need to first install the 'rpm' and 'yum'  packages onto your host. Then, you will create a definition file that will describe how to build your Ubuntu image. Finally, you will build the image using the Singularity commands 'create' and `bootstrap`.

++

## Preparation
This recipe assumes that you have already installed Singularity on your computer. If you have not, follow the instructions here to install. After Singularity is installed on your computer, you will need to install the 'debootstrap' package. The 'debootstrap' package is a tool that will allow you to create Debian-based distributions such as Ubuntu. In order to install 'debootstrap', you will also need to install 'epel-release'. You will need to download the appropriate RPM from the EPEL website. Make sure you download the correct version of the RPM for your release.

```bash
# First, wget the appropriate RPM from the EPEL website (https://dl.fedoraproject.org/pub/epel/)
# In this example we used RHEL 7, so we downloaded epel-release-latest-7.noarch.rpm
$ wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Then, install your epel-release RPM
$ sudo yum install epel-release-latest-7.noarch.rpm
  
# Finally, install debootstrap
$ sudo yum install debootstrap
```

### Creating the Definition File
You will need to create a definition file to describe how to build your Ubuntu image. Definition files are plaintext files that contain Singularity keywords. By using certain Singularity keywords, you can specify how you want your image to be built. The extension '.def' is recommended for user clarity. Below is a definition file for a minimal Ubuntu image:


      DistType "debian"
      MirrorURL "http://us.archive.ubuntu.com/ubuntu/"
      OSVersion "trusty"
  
      Setup
      Bootstrap
  
      Cleanup
      The following keywords were used in this definition file:


- DistType: DistType specifies the distribution type of your intended operating system. Because we are trying to build an Ubuntu image, the type "debian" was chosen.
- MirrorURL: The MirrorURL specifies the download link for your intended operating system. The Ubuntu archive website is a great mirror link to use if you are building an Ubuntu image.
- OSVersion: The OSVersion is used to specify which release of a Debian-based distribution you are using. In this example we chose "trusty" to specify that we wanted to build an Ubuntu 14.04 (Trusty Tahr) image.
- Setup: Setup creates some of the base files and components for an OS and is highly recommended to be included in your definition file.
- Bootstrap: Bootstrap will call apt-get to install the appropriate package to build your OS.
- Cleanup: Cleanup will remove temporary files from the installation.

While this definition file is enough to create a working Ubuntu image, you may want increased customization of your image. There are several Singularity keywords that allow the user to do things such as install packages or files. Some of these keywords are used in the example below:

      DistType "debian"
      MirrorURL "http://us.archive.ubuntu.com/ubuntu/"
      OSVersion "trusty"
  
      Setup 
      Bootstrap
  
      InstallPkgs python
      InstallPkgs wget
      RunCmd wget https://bootstrap.pypa.io/get-pip.py
      RunCmd python get-pip.py
      RunCmd ln -s /usr/local/bin/pip /usr/bin/pip
      RunCmd pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp27-none-linux_x86_64.whl

      Cleanup

Before going over exactly what image this definition file specifies, the remaining Singularity keywords should be introduced.

- InstallPkgs: InstallPkgs allows you to install any packages that you want on your newly created image.
- InstallFile: InstallFile allows you to install files from your computer to the image.
- RunCmd: RunCmd allows you to run a command from within the new image during the installation.
- RunScript: RunScript adds a new line to the runscript invoked by the Singularity subcommand 'run'. See the run page for more information.

Now that you are familiar with all of the Singularity keywords, we can take a closer look at the example above. As with the previous example, an Ubuntu image is created with the specified DistType, MirrorURL, and OSVersion. However, after Setup and Bootstrap, we used the InstallPkgs keyword to install 'python' and 'wget'. Then we used the RunCmd keyword to first download the pip installation wheel, and then to install 'pip'. Subsequently, we also used RunCmd to pip install `TensorFlow`. Thus, we have created a definition file that will install 'python', 'pip', and 'Tensorflow' onto the new image.

### Creating your image
Once you have created your definition file, you will be ready to actually create your image. You will do this by utilizing the Singularity 'create' and 'bootstrap' subcommands. The process for doing this can be seen below (note that we have saved our definition file as "ubuntu.def"):

```bash
# First we will create an empty image container called ubuntu.img
$ sudo singularity create ubuntu.img
Creating a sparse image with a maximum size of 1024MiB...
INFO   : Using given image size of 1024
Formatting image (/sbin/mkfs.ext3)
Done. Image can be found at: ubuntu.img
  
# Next we will bootstrap the image with the operating system specified in our definition file
$ sudo singularity bootstrap ubuntu.img ubuntu.def
W: Cannot check Release signature; keyring file not available /usr/share/keyrings/ubuntu-archive-keyring.gpg
I: Retrieving Release 
I: Retrieving Packages 
I: Validating Packages 
I: Resolving dependencies of required packages...
I: Resolving dependencies of base packages...
I: Found additional base dependencies: gcc-4.8-base gnupg gpgv libapt-pkg4.12 libreadline6 libstdc++6 libusb-0.1-4 readline-common ubuntu-keyring 
I: Checking component main on http://us.archive.ubuntu.com/ubuntu...
I: Retrieving adduser 3.113+nmu3ubuntu3
I: Validating adduser 3.113+nmu3ubuntu3
I: Retrieving apt 1.0.1ubuntu2
I: Validating apt 1.0.1ubuntu2
snip...
Downloading pip-8.1.2-py2.py3-none-any.whl (1.2MB)
  100% |################################| 1.2MB 1.1MB/s 
Collecting setuptools
Downloading setuptools-24.0.2-py2.py3-none-any.whl (441kB)
  100% |################################| 450kB 2.7MB/s 
Collecting wheel
Downloading wheel-0.29.0-py2.py3-none-any.whl (66kB)
  100% |################################| 71kB 9.9MB/s 
Installing collected packages: pip, setuptools, wheel
Successfully installed pip-8.1.2 setuptools-24.0.2 wheel-0.29.0
At this point, you have successfully created an Ubuntu image with 'python', 'pip', and 'TensorFlow' on your RHEL computer.
Tips and Tricks
Here are some tips and tricks that you can use to create more efficient definition files:
```

### Use here documents with RunCmd
Using here documents with conjunction with RunCmd can be a great way to decrease the number of RunCmd keywords that you need to include in your definition file. For example, we can substitute a here document into the previous example:

      DistType "debian"
      MirrorURL "http://us.archive.ubuntu.com/ubuntu/"
      OSVersion "trusty"
  
      Setup 
      Bootstrap
  
      InstallPkgs python
      InstallPkgs wget
      RunCmd /bin/sh <<EOF
      wget https://bootstrap.pypa.io/get-pip.py
      python get-pip.py
      ln -s /usr/local/bin/pip /usr/bin/pip
      pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp27-none-linux_x86_64.whl
      EOF

      Cleanup
    

As you can see, using a here document allowed us to decrease the number of RunCmd keywords from 4 to 1. This can be useful when your definition file has a lot of RunCmd keywords and can also ease copying and pasting command line recipes from other sources.

### Use InstallPkgs with multiple packages
The InstallPkgs keyword is able to install multiple packages with a single keyword. Thus, another way you can increase the efficiency of your code is to use a single InstallPkgs keyword to install multiple packages, as seen below:

      DistType "debian"
      MirrorURL "http://us.archive.ubuntu.com/ubuntu/"
      OSVersion "trusty"
  
      Setup 
      Bootstrap
  
      InstallPkgs python wget
      RunCmd /bin/sh <<EOF
      wget https://bootstrap.pypa.io/get-pip.py
      python get-pip.py
      ln -s /usr/local/bin/pip /usr/bin/pip
      pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp27-none-linux_x86_64.whl
      EOF

      Cleanup
    
Using a single InstallPkgs keyword to install both 'python' and 'wget' allowed to decrease the number of InstallPkgs keywords we had to use in our definition file. This slimmed down our definition file and helped reduce clutter.

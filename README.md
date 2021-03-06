# Stork
[![Build Status](https://travis-ci.org/ctxswitch/stork.png?branch=master)](https://travis-ci.org/ctxswitch/stork)
[![Coverage Status](https://coveralls.io/repos/ctxswitch/stork/badge.png)](https://coveralls.io/r/ctxswitch/stork)
[![Code Climate](https://codeclimate.com/github/ctxswitch/stork.png)](https://codeclimate.com/github/ctxswitch/stork)
[![Gem Version](http://img.shields.io/gem/v/stork.svg)](https://rubygems.org/gems/stork)

Stork is a autoinstall utility, kickstart generation tool and server for CentOS and Redhat systems.  It aims to fill the gap in the bare metal systems deployment that many of the other tools for cloud and virtual systems excel at.

##### ***Stork is currently under heavy development, but I hope to release the first stable version soon.  Please be aware that the DSL and/or API may change significantly during this time.***

## Installation

Installation using rubygems:

    $ gem install stork --pre

Install the latest version from the github:

    $ git clone https://github.com/rlyon/stork.git

If you are installing the latest version from github, you have two choices to run stork.  First, you can run ```rake install``` and build/install the gem, or you can run the executables direcly from the **bin** directory.

## Usage

### Control the server
    storkctl start restart stop [options]

### Commands
    stork host install [name]
    stork host list
    stork host localboot [name]
    stork host reload
    stork host show [name]

## Defining a host

### ```host```

#### Syntax:

The syntax for **host** is as follows:

```ruby 
host "fqdn" do
  attribute "value"
end
```

where

* ```fqdn``` is the fully qualified domain name of the host.
* ```attribute``` is the attributes available for this resource.

#### Attributes:

* ```layout``` - Disk layout containing partition and volume group information.  You can supply a string or a block value.  If a string is supplied stork will attempt to find the id matching a previously defined layout.
* ```template``` - The kickstart template to use when generating the autoinstallation instructions
* ```pxemac``` - The mac address of the PXE enabled interface.  Used to create the boot configuration files.
* ```pre_snippet``` - Scripts that will be run in the **pre** section before the install begins.  Snippets are accessed by the basename of the file they are stored in.
* ```post_snippet``` - Scripts that will be run in the **post** section afer the install has successfully completed.  Snippets are accessed by the basename of the file they are stored in.
* ```interface``` - Network interface information. Takes only a block value.
* ```distro``` - Install distribution information.  You can supply a string or a block value.  If a string is supplied stork will attempt to find the id matching a previously defined distribution.
* ```timezone``` - The IANA zone name (e.g. 'America/Chicago').
* ```firewall``` - Initial firewall settings.  Block only.
* ```selinux``` - String or symbol value representing the three selinux states. The only valid values are:  enforcing, permissive, or disabled.  Default is enforcing.
* ```package``` - Adds a package to the install.  Generally not needed as the minimal set of packages that are installed by default will be enough to install the configuration management software.
* ```repos``` - Add a new repo to the host.
* ```stork``` - Url.  Override the stork server location.

#### Examples:

Typical hosts will look like:

```ruby
host "server.example.org" do
  template    "default"
  pxemac      "00:11:22:33:44:55"
  layout      "home"
  distro      "centos"
  repo        "whamcloud-client", baseurl: "http://yum.example.com/eln/x86_64"
  package     "foo"


  interface "eth0" do
    bootproto :static
    ip        "99.99.1.8"
    network   "org"
  end

  interface "eth1" do
    bootproto :static
    ip        "192.168.1.10"
    netmask   "255.255.255.0"
    gateway   "192.168.1.1"
    nameserver "192.168.1.253"
    nameserver "192.168.1.252"
  end

  pre_snippet    "setup"
  post_snippet   "ntp"
  post_snippet   "resolv-conf"
  post_snippet   "notify"
end
```

Or you define hosts programatically with common ruby techniques:

```ruby
hosts=[
  [10, "00:11:22:33:44:01"],
  [11, "00:11:22:33:44:02"],
  [12, "00:11:22:33:44:03"],
  [13, "00:11:22:33:44:04"],
  [14, "00:11:22:33:44:05"],
  [15, "00:11:22:33:44:06"],
  [16, "00:11:22:33:44:07"],
  [17, "00:11:22:33:44:08"],
  [18, "00:11:22:33:44:09"],
  [19, "00:11:22:33:44:10"]
]

hosts.each do |octet, mac|
  host "c0#{octet}.example.org" do
    template    "default"
    distro      "centos"
    pxemac      mac
    layout      "home"


    interface "eth0" do
      bootproto :static
      ip        "192.168.10.#{octet}"
      network   "org"
    end
  end
end
```
## Defining the disk layout

### ```layout```

#### Syntax:

The syntax for **layout** is as follows:

```ruby
layout "name", part: "physical_volume" do
  attribute "value"
end
```

where

* ```name``` is a unique name that can be used to define global resources that can be referenced from other resources by the defined name.
* ```part``` is the physical_volume that the volume group will be placed on.
* ```attribute``` is the attributes available for this resource.

#### Attributes:

* ```zerombr``` - Initialize invalid partition tables.
* ```clearpart``` - Remove partitions prior to the creation of new partitions.
* ```partition``` or ```part``` - Partition information (see Partition Resource).
* ```volume_group``` or ```vg``` - Volume group information (see Volume Group Resource).

### ```partition``` or ```part```

#### Syntax:

The syntax for **partition** is as follows:

```ruby
partition "mountpoint" do
  attribute "value"
end
```

where

* ```mountpoint``` is the filesystem path where the partition will be mounted. When a volume group will be associated with the partition, use the *pv.n* naming scheme to specify that the partition is a physical volume.
* ```attribute``` is the attributes available for this resource

#### Attributes:

* ```size``` - Size of the partition in MB.
* ```type``` - Set the file system type.
* ```primary``` - Force allocation of the partition as a primary partition.
* ```grow``` - Grow the partition to the maximum amount.
* ```recommended``` - Let the installer determine the recommended size.

See ```layout``` for an example of how partition can be used to define disk partitions. 

### ```volume_group``` or ```volgroup```

#### Syntax:

The syntax for **volume_group** is as follows:

```ruby
volume_group "name" do
  block_attribute "value" do
    attribute "value"
  end
end
```

where

* ```name``` is the name of the volume group.
* ```attribute``` is the attributes available for this resource

#### Attributes:

* ```logical_volume``` - Add a logical volume to the volume group.

### ```logical_volume``` or ```logvol``` 

#### Syntax:

The syntax for **logical_volume** is as follows:

```ruby 
logical_volume "name" do
  attribute "value"
end
```

where

* ```name``` is the name of the logical volume.
* ```attribute``` is the attributes available for this resource

#### Attributes:

* ```path``` - Mount point.
* ```size``` - Size of the logical volume in MB.
* ```type``` - Set the file system type.
* ```grow``` - Grow the logical volume to the maximum amount.
* ```recommended``` - Let the installer determine the recommended size.

#### Examples:
Layouts can be defined seperately from hosts and referenced in hosts by name.  A typical layout will look like this:

```ruby
layout "root_and_home" do
  clearpart
  zerombr
  part "/boot" do
    size 100
    type "ext4"
    primary
  end

  part "swap" do
    recommended
    type "swap"
    primary
  end

  part "pv.01" do
    grow
    primary
  end

  volume_group "vg", part: "pv.01" do
    logical_volume "lv_root" do
      path "/"
      type "ext4"
      size 4096
    end

    logical_volume "lv_home" do
      path "/home"
      type "ext4"
      grow
    end
  end
end
``` 

## Defining the install distribution

### ```distro```

#### Syntax:

The syntax for **distro** is as follows:

```ruby
distro "name" do
  attribute "value"
end
```

where

* ```name``` is a unique name that can be used to define global resources that can be referenced from other resources by the defined name.
* ```attribute``` is the attributes available for this resource

#### Attributes:

* ```kernel``` - Name of the kernel.  This is the kernel that will be transfered via tftp to the host at install time.
* ```image``` - Name of the RAM disk image of the installer.
* ```url``` - Install url for network install (only supports http - at least thats the only one I'm testing with)

#### Examples:
```ruby
distro "centos" do
  kernel "vmlinuz"
  image "initrd.img"
  url "http://mirror.example.com/centos"
end
```

## Adding network interfaces

### ```network```

#### Syntax:

The syntax for **network** is as follows:

```ruby
network "name" do
  attribute "value"
end
```

where

* ```name``` is a unique name that can be used to define global resources that can be referenced from other resources by the defined name.
* ```attribute``` is one or more of the attributes available for this resource.

#### Attributes:

* ```netmask``` - the netmask of the network.
* ```gateway``` - the ip address of the network's gateway.
* ```nameserver``` - add a nameserver to the network.
* ```search_path``` - add a search_path to the network.

#### Examples:

```ruby
network "org" do
  netmask "255.255.255.0"
  gateway "99.99.1.1"
  nameserver "99.99.1.253"
  nameserver "99.99.1.252"
  search_path "example.org"
end

```

### ```interface```

#### Syntax:

The syntax for **interface** is as follows:

```ruby
interface "device" do
  attribute "value"
end
```

where

* ```device``` is the device that is being configured
* ```attribute``` is one or more of the attributes available for this resource.

#### Attributes:

* ```onboot``` - enables the interface on boot.
* ```ipv4``` or ```noipv4``` - enable or disable ipv4 support.
* ```ipv6``` or ```noipv6``` - enable or disable ipv6 support.
* ```defroute``` or ```nodefroute``` - use or don't use the interface for the default route.
* ```ethtool``` - a string value representing the ethtool options for the interface.
* ```bootproto``` - a string or symbol representing the boot protocol.  Allowed values include :static and :dhcp.

For statically configured interfaces: ```bootproto :static```

* ```ip``` - the ip address of the interface.
* ```netmask``` - the netmask of the network.
* ```gateway``` - the ip address of the network's gateway.
* ```nameserver``` - add a nameserver to the network.
* ```search_path``` - add a search_path to the network.
* ```network``` - set the netmask, gateway, nameservers, and search paths with the values found in the specified network resource. 

For dynamically configured interfaces: ```bootproto :dhcp```

* ```dns``` or ```nodns``` - allow or disallow dhcpd to update resolv.conf.

#### Examples:

```ruby
interface "eth0" do
  onboot
  bootproto :dhcp
end

interface "eth1" do
  bootproto :static
  ip        "99.99.1.8"
  network   "org"
end

interface "eth2" do
  bootproto :static
  ip        "192.168.1.10"
  netmask   "255.255.255.0"
  gateway   "192.168.1.1"
  nameserver "192.168.1.253"
  nameserver "192.168.1.252"
end
```

## Setting the host firewall

### ```firewall```

#### Syntax:

The syntax for **firewall** is as follows:

```ruby
firewall do
  attribute "value"
end
```

where

* ```attribute``` is one or more of the attributes available for this resource.

#### Attributes:

* ```enabled``` - enable the firewall.
* ```disable``` - disable the firewall.
* ```ssh``` - allow the ssh protocol through the firewall.
* ```telnet``` - allow the telnet protocol through the firewall.
* ```smtp``` - allow the smtp protocol through the firewall.
* ```http``` - allow the http protocol through the firewall.
* ```ftp``` - allow the ftp protocol through the firewall.
* ```trust``` - add a device (e.g. eth1, eth2, p1p2, etc) as a trusted device.
* ```allow``` - allow a port and using the **port:protocol** format

#### Examples:

```ruby
firewall do
  enabled
  ssh
  allow "8080:tcp"
  trust "eth1"
end
```

## Templates and Snippet Scripts

Templates and snippets use the ERB templating system.  When the ERB files are rendered, binding are created to expose ruby the underlying ruby objects.  

In kickstart templates, the generated kickstart commands can be accessed:

* ```url``` - Outputs the kickstart command assigning the URL for network installs.
* ```network``` - Outputs each interface kickstart command for all defined interfaces.
* ```password``` - Outputs the 'rootpw' command with a randomized password.
* ```firewall``` - Outputs the firewall command.
* ```timezone``` - Outputs the timezone command for the installer.
* ```selinux``` - Outputs the selinux command.
* ```layout``` - Outputs all of the partition, volume groups and logical volume commands.
* ```bootloader``` - Outputs the bootloader config information.
* ```zerombr``` - Outputs the zerombr command.
* ```clearpart``` - Outputs the clearpart command.
* ```repos``` - Outputs all additional repo commands.
* ```packages``` - Outputs the packages section.
* ```pre_snippets``` - Renders and outputs all pre snippets in the %pre section.
* ```post_snippets``` - Renders and outputs all post snippets in the %post section.

In addition to the kickstart command generators, the following objects are exposed and can be used:

* ```host``` - The complete host object for the current host.

Snippets expose the following objects to the template:

* ```host``` - The current host.
* ```authorized_keys``` - A string containing all the public keys.
* ```first_boot_content``` - A string representation of the json content that will make up the first_boot file.
* ```nameservers``` - An array of all unique nameservers.
* ```search_paths``` - An array of all unique search_paths.
* ```stork_server``` - The IP address or hostname of the stork server.
* ```stork_port``` - The port that the stork server is running on.
* ```stork_bind``` - The bind IP address of the stork server.


## Contributing

### Grab the source and make a branch

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Setting up for the kickstart validation tests

To run the kickstart validation tests on your local system, you
will need to install python and the python virtualenv module.  
I'm currently using 2.7, and I don't know if it makes a difference.  
On Linux you can use your favorite package manager if by some chance 
your distribution didn't come with it installed.  On Mac use homebrew 
or macports to avoid using the system python which is bound to be 
a very old version.

    $ brew install python
    $ pip install virtualenv

Once python and virtualenv has been installed, run

    $ rake validator:setup

This will create the directories that you need, set up a virtual
environment and get everything ready for the integration tests.

### Run the tests to see if it breaks

    $ rake test

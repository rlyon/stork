###############################################################################
### Kickstart generated by midwife
###############################################################################
install
reboot
text

###############################################################################
### Partitioning
###############################################################################
zerombr yes
clearpart --all --initlabel
part /boot --size 100 --fstype ext4 --asprimary
part swap --recommended --fstype swap --asprimary
part / --size 1 --fstype ext4 --grow


###############################################################################
### Networking
###############################################################################

network --device=eth0 --bootproto=dhcp --onboot=yes

firewall --disabled

###############################################################################
### Environment
###############################################################################
lang en_US
langsupport --default=en_US
timezone America/Los_Angeles

###############################################################################
### SELinux
###############################################################################
selinux --disabled

###############################################################################
### Packages
###############################################################################
%packages 
@core
curl
openssh-clients
openssh-server
finger
pciutils
yum
at
acpid
vixie-cron
cronie-noanacron
crontabs
logrotate
ntp
ntpdate
tmpwatch
rsync
mailx
which
wget
man

###############################################################################
### Post
###############################################################################
%post --log=/root/midwife-post.log
chvt 3
echo "Executing post installation"
echo "Contacting midwife to notify of a successful install"
/usr/bin/curl http://localhost:9293/notify/other1.private/installed
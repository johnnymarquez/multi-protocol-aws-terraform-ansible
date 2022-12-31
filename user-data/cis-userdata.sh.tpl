#!/usr/bin/bash
set -e -x

#Script for apply hardening for CIS Benchmark Linux generic on a Amazon Linux 2 box
# 0. Install Dependencies
sudo su
sudo yum update -y;
sudo amazon-linux-extras install epel -y
sudo amazon-linux-extras install nginx1 -y
sudo yum install python3 git -y
sudo yum install aide -y
sudo yum install sysstat -y


# install systat atop
sudo yum -y install sysstat atop --enablerepo=epel
sudo sed -i 's/^LOGINTERVAL=600.*/LOGINTERVAL=60/' /etc/sysconfig/atop
sudo sed -i -e 's|*/10|*/1|' -e 's|every 10 minutes|every 1 minute|' /etc/cron.d/sysstat
sudo systemctl enable atop.service crond.service sysstat.service
sudo systemctl restart atop.service crond.service sysstat.service

# 1. Initial Setup
### set welcome banner
sudo su
cat >/etc/update-motd.d/30-banner <<EOF
cat << EOF
   # MILLICOM: Authorized use only. All activity may be monitored and reported.
   #
   #      __  ____ _____                                  ____  _       _ __       __
   #     /  |/  (_) / (_)________  ____ ___              / __ \(_)___ _(_) /_____ / /
   #    / /|_/ / / / / / ___/ __ \/ __  __ \   ______   / / / / / __ / / __/ __  / /
   #   / /  / / / / / / /__/ /_/ / / / / / /  /_____/  / /_/ / / /_/ / / /_/ /_ / /
   #  /_/  /_/_/_/_/_/\___/\____/_/ /_/ /_/           /_____/_/\__, /_/\__/\__//_/
   #                                                             / /
   \nEOF                                                       /____/
EOF
cat /etc/update-motd.d/30-banner


## 1.1 Filesystem Configuration

## From 1.1.1.1 to 1.1.1.8
MODPROBED_DIR="/etc/modprobe.d"
FS_HARDENING_FILE="$MODPROBED_DIR/cis.conf"
echo $FS_HARDENING_FILE
FS_FORMATS="cramfs freevxfs jffs2 hfs hfsplus squashfs udf"
if [[ ! -d $MODPROBED_DIR ]]; then
  echo $MODPROBED_DIR
  mkdir -p "$MODPROBED_DIR"
fi
if [[ ! -e $FS_HARDENING_FILE ]]; then
  for fs_format in $FS_FORMATS; do
    echo -e "install $fs_format /bin/true" >> "$FS_HARDENING_FILE"
  done
fi
for fs_format in $FS_FORMATS; do
  FS_MODULE=$(lsmod | awk "/$fs_format/")
  if [[ -n $FS_MODULE ]]; then
    modprobe -v --remove-dependencies "$fs_format"
  fi
done
##  1.1.2

systemctl unmask tmp.mount
systemctl enable tmp.mount
systemctl is-enabled tmp.mount

sed -i 's/Options=mode=1777,strictatime/Options=mode=1777,strictatime,noexec,nodev,nosuid/g'  /etc/systemd/system/local-fs.target.wants/tmp.mount

##  1.3.1
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

## 1.4.1

chown root:root /boot/grub2/grub.cfg
chmod og-rwx /boot/grub2/grub.cfg

## 1.5.1 - 1.5.2 - 3.1.1 - 

echo "* hard core 0" > /etc/security/limits.d/cis.conf
echo "net.ipv4.ip_forward = 0" > /etc/sysctl.d/cis.conf
echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.d/cis.conf
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.d/cis.conf
echo "fs.suid_dumpable = 0" >>  /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.default.send_redirects = 0" >>  /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.default.send_redirects = 0" >>  /etc/sysctl.d/cis.conf

 
### 3.2.1
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >>  /etc/sysctl.d/cis.conf
echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv6.conf.default.accept_source_route = 0" >>  /etc/sysctl.d/cis.conf


### 3.2.2
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >>  /etc/sysctl.d/cis.conf
echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv6.conf.default.accept_redirects = 0" >>  /etc/sysctl.d/cis.conf

### 3.2.3
echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.default.secure_redirects = 0" >>  /etc/sysctl.d/cis.conf

### 3.2.4
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.default.log_martians = 1" >>  /etc/sysctl.d/cis.conf

### 3.2.5
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/cis.conf

### 3.2.6
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.d/cis.conf

### 3.2.7
echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/cis.conf
echo "net.ipv4.conf.default.rp_filter = 1" >>  /etc/sysctl.d/cis.conf

### 3.2.8
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.d/cis.conf

### 3.2.9
echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.d/cis.conf
echo "net.ipv6.conf.default.accept_ra = 0" >>  /etc/sysctl.d/cis.conf

### 3.2.1 - 3.2.9
echo "
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0" >>  /etc/sysctl.d/cis.conf


## 2.1.7
systemctl disable nfs
systemctl disable nfs-server
systemctl disable rpcbind

### 4.2.1.3

sed -i '/#### RULES ####/ i$FileCreateMode 0640' /etc/rsyslog.conf

### 4.2.4
find /var/log -type f -exec chmod g-wx,o-rwx {} +
 
 #Hardening 5.1 to 5.6
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
chown root:root /etc/cron.weekly
chmod 600 /etc/cron.weekly
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d
 
rm -f /etc/cron.deny
rm -f /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow

### 5.2.2
/usr/bin/ssh-keygen -A
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:ssh_keys {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0640 {} \;
find /var/log -type f -exec chmod g-wx,o-rwx {} + 
echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab



rm -f /etc/ssh/sshd_config
touch /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config

echo "
ClientAliveCountMax 0
HostbasedAuthentication no
PermitRootLogin no
ClientAliveInterval 300
Protocol 2
LogLevel INFO
X11Forwarding no
MaxAuthTries 4
IgnoreRhosts yes
PermitEmptyPasswords no
PermitUserEnvironment no
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256
LoginGraceTime 60
AllowUsers ec2-user
AllowGroups ec2-user
DenyUsers <userlist>
DenyGroups <grouplist>
Banner /etc/issue.net

" >> /etc/ssh/sshd_config
sudo systemctl restart sshd
sed -i s/ec2-user:!/"ec2-user:*"/g /etc/shadow

sudo su
yum install amazon-cloudwatch-agent -y
echo '
{
        "agent": {
                "run_as_user": "root"
        },
        "logs": {
                "logs_collected": {
                        "files": {
                                "collect_list": [
                                        {
                                                "file_path": "/var/log/nginx/*.log",
                                                "log_group_name": "infra-instance-log-${HOSTNAME}-nginx",
                                                "log_stream_name": "{local_hostname}"
                                        }
                                ]
                        }
                }
        }
}
' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

rm -f /etc/logrotate.d/nginx
echo '
/var/log/nginx/*log {
    daily
    rotate 3
    maxsize 1024M
    missingok
    notifempty
    compress
    sharedscripts
    nodelaycompress
    postrotate
        /bin/kill -USR1 `cat /run/nginx.pid 2>/dev/null` 2>/dev/null || true
        /usr/bin/systemctl reload nginx.service
    endscript
}
' > /etc/logrotate.d/nginx
## Test
##logrotate -f /etc/logrotate.d/nginx
mv /etc/cron.daily/logrotate /etc/cron.hourly/
sudo logrotate -v -f /etc/logrotate.conf
sudo systemctl restart crond

sudo systemctl enable nginx
sudo systemctl enable amazon-ssm-agent
sudo systemctl enable amazon-cloudwatch-agent.service

##  1.3.2  y 1.8

echo "0 5 * * * /usr/sbin/aide --check" > crontab_new
echo "0 5 * * * /usr/sbin/yum update --security -y" >> crontab_new
echo "0 4 * * 7 /etc/init.d/nginx restart"  >> crontab_new
echo "* * * * * sudo /bin/live_site.sh >/dev/null 2>&1" >>  crontab_new
crontab crontab_new

# Disable Ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.d/cis.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >>  /etc/sysctl.d/cis.conf

# Additional configurations
sed -i 's/rotate 10/rotate 5/g' /etc/logrotate.d/nginx
sed -i 's/#SystemMaxUse=/SystemMaxUse=50/g' /etc/systemd/journald.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf
#sudo systemctl disable firewalld

#sudo hostnamectl set-hostname ${HOSTNAME}

sudo hostnamectl set-hostname ${HOSTNAME}-$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id/)

aws ec2 delete-tags \
  --resources $(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id/) \
  --tags Key=Name \
  --region us-east-1

aws ec2 create-tags \
  --resources $(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id/) \
  --tags Key=Name,Value=${HOSTNAME}-$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id/) \
--region us-east-1
            
# New Relic Agent Installation
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=NRAK-9GTILKP1BQRV200VX3OMXMFQ312 NEW_RELIC_ACCOUNT_ID=1955494 /usr/local/bin/newrelic install -n nginx-open-source-integration

reboot
#!/bin/bash
##
# SUSE Linux Enterprise 11 基线检测脚本，基于 CIS_SUSE_Linux_Enterprise_11_Benchmark_v2.1.0
# By l3e0x7b
# Version: 1.0
##

clear
LANG_OLD=$LANG
export LANG=en_US.UTF-8
REPORT="/tmp/report.`date +%Y%m%d_%H%M%S`"

echo "主机信息" | tee -a ${REPORT}
echo "--------------------------------------------------" | tee -a ${REPORT}
echo "主机名：`hostname`" | tee -a ${REPORT}
echo "主机IP：`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/'`" | tee -a ${REPORT}
echo "系统版本：`uname -a`" | tee -a ${REPORT}
echo "主机时间：`date`" | tee -a ${REPORT}
echo "--------------------------------------------------" | tee -a ${REPORT}

echo
echo "开始执行检测..."
echo "" >> ${REPORT}
echo "检测结果" >> ${REPORT}
echo "--------------------------------------------------" | tee -a ${REPORT}
echo "1 初始设置" | tee -a ${REPORT}
echo "1.1 文件系统配置"
echo "1.1.1 检查禁用未使用的文件系统"
echo -n "1.1.1.1 检查 cramfs 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v cramfs 2> /dev/null`
lsmod | grep cramfs &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tcramfs 文件系统已禁用。" >> ${REPORT}

	# echo -e "\n\t_________" >> ${REPORT}
	# echo -e "\n\t整改建议：" >> ${REPORT}
	# echo -e "\n\techo \"install cramfs /bin/true\" >> /etc/modprobe.d/CIS.conf" >> ${REPORT}
	# echo -e "\n\trmmod cramfs &> /dev/null" >> ${REPORT}
	# echo -e "\n\t__________________" >> ${REPORT}
else
	echo -e "\n\tcramfs 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.1.2 检查 freevxfs 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v freevxfs 2> /dev/null`
lsmod | grep freevxfs &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tfreevxfs 文件系统已禁用。" >> ${REPORT}
else
	echo -e "\n\tfreevxfs 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.1.3 检查 jffs2 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v jffs2 2> /dev/null`
lsmod | grep jffs2 &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tjffs2 文件系统已禁用。" >> ${REPORT}
else
	echo -e "\n\tjffs2 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.1.4 检查 hfs 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v hfs 2> /dev/null`
lsmod | grep hfs &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\thfs 文件系统已禁用。" >> ${REPORT}
else
	echo -e "\n\thfs 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.1.5 检查 hfsplus 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v hfsplus 2> /dev/null`
lsmod | grep hfsplus &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\thfsplus 文件系统已禁用。" >> ${REPORT}
else
	echo -e "\n\thfsplus 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.1.6 检查 squashfs 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v squashfs 2> /dev/null`
lsmod | grep squashfs &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tsquashfs 文件系统已禁用。" >> ${REPORT}
else
	echo -e "\n\tsquashfs 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.1.7 检查 udf 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v udf 2> /dev/null`
lsmod | grep udf &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tudf 文件系统已禁用。" >> ${REPORT}
else
	echo -e "\n\tudf 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.1.8 检查 FAT 文件系统是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v vfat 2> /dev/null`
lsmod | grep vfat &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tFAT 文件系统已禁用。" >> ${REPORT}
else
	echo -e "\n\tFAT 文件系统未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.2 检查 /tmp 是否为独立分区" | tee -a ${REPORT}
mount | grep /tmp &> /dev/null
if [[ $? -eq 0 ]]; then
	tmpid=0
	echo -e "\n\t/tmp 为独立分区。" >> ${REPORT}
else
	tmpid=1
	echo -e "\n\t/tmp 非独立分区。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.3 检查是否已在 /tmp 分区设置 nodev 选项" | tee -a ${REPORT}
if [[ ${tmpid} -eq 1 ]]; then
	echo -e "\n\t/tmp 非独立分区，跳过检查。" >> ${REPORT}
else
	mount | grep /tmp | grep nodev &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\t已在 /tmp 分区设置 nodev 选项。" >> ${REPORT}
	else
		echo -e "\n\t未在 /tmp 分区设置 nodev 选项。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.4 检查是否已在 /tmp 分区设置 nosuid 选项" | tee -a ${REPORT}
if [[ ${tmpid} -eq 1 ]]; then
	echo -e "\n\t/tmp 非独立分区，跳过检查。" >> ${REPORT}
else
	mount | grep /tmp | grep nosuid &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\t已在 /tmp 分区设置 nosuid 选项。" >> ${REPORT}
	else
		echo -e "\n\t未在 /tmp 分区设置 nosuid 选项。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.5 检查是否已在 /tmp 分区设置 noexec 选项" | tee -a ${REPORT}
if [[ ${tmpid} -eq 1 ]]; then
	echo -e "\n\t/tmp 非独立分区，跳过检查。" >> ${REPORT}
else
	mount | grep /tmp | grep noexec &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\t已在 /tmp 分区设置 noexec 选项。" >> ${REPORT}
	else
		echo -e "\n\t未在 /tmp 分区设置 noexec 选项。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.6 检查 /var 是否为独立分区" | tee -a ${REPORT}
mount | grep /var &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/var 为独立分区。" >> ${REPORT}
else
	echo -e "\n\t/var 非独立分区。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.7 检查 /var/tmp 是否为独立分区" | tee -a ${REPORT}
mount | grep /var/tmp &> /dev/null
if [[ $? -eq 0 ]]; then
	vtmpid=0
	echo -e "\n\t/var/tmp 为独立分区。" >> ${REPORT}
else
	vtmpid=1
	echo -e "\n\t/var/tmp 非独立分区。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.8 检查是否已在 /var/tmp 分区设置 nodev 选项" | tee -a ${REPORT}
if [[ ${vtmpid} -eq 1 ]]; then
	echo -e "\n\t/var/tmp 非独立分区，跳过检查。" >> ${REPORT}
else
	mount | grep /var/tmp | grep nodev &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\t已在 /var/tmp 分区设置 nodev 选项。" >> ${REPORT}
	else
		echo -e "\n\t未在 /var/tmp 分区设置 nodev 选项。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.9 检查是否已在 /var/tmp 分区设置 nosuid 选项" | tee -a ${REPORT}
if [[ ${vtmpid} -eq 1 ]]; then
	echo -e "\n\t/var/tmp 非独立分区，跳过检查。" >> ${REPORT}
else
	mount | grep /var/tmp | grep nosuid &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\t已在 /var/tmp 分区设置 nosuid 选项。" >> ${REPORT}
	else
		echo -e "\n\t未在 /var/tmp 分区设置 nosuid 选项。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.10 检查是否已在 /var/tmp 分区设置 noexec 选项" | tee -a ${REPORT}
if [[ ${vtmpid} -eq 1 ]]; then
	echo -e "\n\t/var/tmp 非独立分区，跳过检查。" >> ${REPORT}
else
	mount | grep /var/tmp | grep noexec &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\t已在 /var/tmp 分区设置 noexec 选项。" >> ${REPORT}
	else
		echo -e "\n\t未在 /var/tmp 分区设置 noexec 选项。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.11 检查 /var/log 是否为独立分区" | tee -a ${REPORT}
mount | grep /var/log &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/var/log 为独立分区。" >> ${REPORT}
else
	echo -e "\n\t/var/log 非独立分区。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.12 检查 /var/log/audit 是否为独立分区" | tee -a ${REPORT}
mount | grep /var/log/audit &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/var/log/audit 为独立分区。" >> ${REPORT}
else
	echo -e "\n\t/var/log/audit 非独立分区。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.13 检查 /home 是否为独立分区" | tee -a ${REPORT}
mount | grep /home &> /dev/null
if [[ $? -eq 0 ]]; then
	homeid=0
	echo -e "\n\t/home 为独立分区。" >> ${REPORT}
else
	homeid=1
	echo -e "\n\t/home 非独立分区。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.14 检查是否已在 /home 分区设置 nodev 选项" | tee -a ${REPORT}
if [[ ${homeid} -eq 1 ]]; then
	echo -e "\n\t/home 非独立分区，跳过检查。" >> ${REPORT}
else
	mount | grep /home | grep nodev &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\t已在 /home 分区设置 nodev 选项。" >> ${REPORT}
	else
		echo -e "\n\t未在 /home 分区设置 nodev 选项。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.15 检查是否已在 /dev/shm 分区设置 nodev 选项" | tee -a ${REPORT}
mount | grep /dev/shm | grep nodev &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t已在 /dev/shm 分区设置 nodev 选项。" >> ${REPORT}
else
	echo -e "\n\t未在 /dev/shm 分区设置 nodev 选项。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.16 检查是否已在 /dev/shm 分区设置 nosuid 选项" | tee -a ${REPORT}
mount | grep /dev/shm | grep nosuid &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t已在 /dev/shm 分区设置 nosuid 选项。" >> ${REPORT}
else
	echo -e "\n\t未在 /dev/shm 分区设置 nosuid 选项。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.17 检查是否已在 /dev/shm 分区设置 noexec 选项" | tee -a ${REPORT}
mount | grep /dev/shm | grep noexec &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t已在 /dev/shm 分区设置 noexec 选项。" >> ${REPORT}
else
	echo -e "\n\t未在 /dev/shm 分区设置 noexec 选项。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.18 检查是否已在可移动媒体分区上设置 nodev 选项" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否存在可移动媒体，并检查是否已为其设置 nodev 选项。" >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.19 检查是否已在可移动媒体分区上设置 nosuid 选项" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否存在可移动媒体，并检查是否已为其设置 nosuid 选项。" >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.20 检查是否已在可移动媒体分区上设置 noexec 选项" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否存在可移动媒体，并检查是否已为其设置 noexec 选项。" >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.21 检查是否已在所有全局可写的目录上设置粘滞位" | tee -a ${REPORT}
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) > /tmp/wwd_nsb_list 2> /dev/null
if [[ -s /tmp/wwd_nsb_list ]]; then
	echo -e "\n\t未设置粘滞位的全局可写目录信息如下：" >> ${REPORT}
	cat /tmp/wwd_nsb_list | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t不存在未设置粘滞位的全局可写目录。" >> ${REPORT}
fi
rm -f /tmp/wwd_nsb_list
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.1.22 检查是否已禁用自动挂载" | tee -a ${REPORT}
rpm -q autofs &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t已禁用自动挂载 (autofs 未安装)。" >> ${REPORT}
else
	systemctl is-enabled autofs &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\t已禁用自动挂载。" >> ${REPORT}
	else
		echo -e "\n\t未禁用自动挂载。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "1.2 配置软件更新"
echo -n "1.2.1 检查包管理器仓库是否已配置" | tee -a ${REPORT}
yum repolist | grep 'repolist: 0' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t包管理器仓库配置如下：" >> ${REPORT}
	yum repolist | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t包管理器仓库未配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.2.2 检查 GPG 密钥是否已配置" | tee -a ${REPORT}
rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tGPG 密钥未配置。" >> ${REPORT}
else
	echo -e "\n\tGPG 密钥配置如下：" >> ${REPORT}
	rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.2.3 检查 gpgcheck 是否已全局激活" | tee -a ${REPORT}
grep -r ^gpgcheck /etc/yum* > /tmp/gpgchk
if grep -q gpgcheck=0 /tmp/gpgchk; then
	echo -e "\n\tgpgcheck 未全局激活。未激活 gpgcheck 的 repo 信息如下：" >> ${REPORT}
	if grep -q '/etc/yum\.conf' /tmp/gpgchk; then
		echo -e "\n\t/etc/yum.conf" >> ${REPORT}
	fi
	IFS_OLD=$IFS
	IFS=$'\n'
	for repofile in `grep gpgcheck=0 /tmp/gpgchk | cut -d: -f1 | uniq`; do
		for reponame in `grep -B5 ^gpgcheck=0 ${repofile} |grep name`; do
			echo -e "\t${repofile}:\t${reponame}" >> ${REPORT}
		done
	done
	IFS=$IFS_OLD
else
	echo -e "\n\tgpgcheck 已全局激活。" >> ${REPORT}
fi
rm -f /tmp/gpgchk
echo "..........[OK]"
echo "" >> ${REPORT}

echo "1.3 文件系统完整性检查"
echo -n "1.3.1 检查 AIDE 是否已安装" | tee -a ${REPORT}
rpm -q aide &> /dev/null
if [[ $? -eq 0 ]]; then
	aideid=0
	echo -e "\n\tAIDE 已安装。" >> ${REPORT}
else
	aideid=1
	echo -e "\n\tAIDE 未安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.3.2 检查是否已配置文件系统完整性定期检查" | tee -a ${REPORT}
if [[ ${aideid} -eq 1 ]]; then
	echo -e "\n\t未配置文件系统完整性定期检查 (AIDE 未安装)。" >> ${REPORT}
else
	output1=`crontab -u root -l 2> /dev/null | grep aide`
	output2=`grep -r aide /etc/cron.* /etc/crontab`
	if [[ ${output1} = "" && ${output2} = "" ]]; then
		echo -e "\n\t未配置文件系统完整性定期检查。" >> ${REPORT}
	else
		echo -e "\n\t已配置文件系统完整性定期检查。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "1.4 安全启动设置"
echo -n "1.4.1 检查 bootloader 配置文件的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /boot/grub2/grub.cfg`
if [[ ${perm} != "600/-rw-------/0/root/0/root" ]]; then
	echo -e "\n\tbootloader 配置文件 (/boot/grub2/grub.cfg) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /boot/grub2/grub.cfg | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\tbootloader 配置文件 (/boot/grub2/grub.cfg) 的权限已配置。" >> ${REPORT}
fi

if [[ -f /boot/grub2/user.cfg ]]; then
	userid=0
	perm=`stat -c %a/%A/%u/%U/%g/%G /boot/grub2/user.cfg`
	if [[ ${perm} != "600/-rw-------/0/root/0/root" ]]; then
		echo -e "\n\tbootloader 配置文件 (/boot/grub2/user.cfg) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
		stat /boot/grub2/user.cfg | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
	else
		echo -e "\n\tbootloader 配置文件 (/boot/grub2/user.cfg) 的权限已配置。" >> ${REPORT}
	fi
else
	userid=1
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.4.2 检查 bootloader 密码是否已设置" | tee -a ${REPORT}
if [[ ${userid} -eq 0 ]]; then
	output=`grep ^GRUB2_PASSWORD /boot/grub2/grub.cfg /boot/grub2/user.cfg`
else
	output=`grep ^GRUB2_PASSWORD /boot/grub2/grub.cfg`
fi

if [[ ${output} = "" ]]; then
	echo -e "\n\tbootloader 密码未设置。" >> ${REPORT}
else
	echo -e "\n\tbootloader 密码已设置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.4.3 检查是否已配置单用户模式要求认证" | tee -a ${REPORT}
output1=`grep /sbin/sulogin /usr/lib/systemd/system/rescue.service`
output2=`grep /sbin/sulogin /usr/lib/systemd/system/emergency.service`
if [[ ${output1} = "" || ${output2} = "" ]]; then
	echo -e "\n\t未配置单用户模式要求认证。" >> ${REPORT}
else
	echo -e "\n\t已配置单用户模式要求认证。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "1.5 额外流程强化"
echo -n "1.5.1 检查是否已限制核心转储" | tee -a ${REPORT}
output=`ulimit -c 2> /dev/null`
if [[ ${output} -eq 0 ]]; then
	echo -e "\n\t未开启核心转储，跳过检查。" >> ${REPORT}
else
	output1=`egrep '^\*\s+hard\s+core\s+0' /etc/security/limits.conf /etc/security/limits.d/*`
	output2=`sysctl fs.suid_dumpable | cut -d" " -f3`
	output3=`grep '^fs\.suid_dumpable\s*=\s*0' /etc/sysctl.conf /etc/sysctl.d/*`

	if [[ ${output1} = "" || ${output2} -ne "0" || ${output3} = "" ]]; then
		echo -e "\n\t未限制核心转储。" >> ${REPORT}
	else
		echo -e "\n\t已限制核心转储。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.5.2 检查 XD/NX 支持是否已启用" | tee -a ${REPORT}
dmesg | grep NX | grep -w active &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t XD/NX 支持已启用。" >> ${REPORT}
else
	echo -e "\n\t XD/NX 支持未启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.5.3 检查 ASLR 是否已启用" | tee -a ${REPORT}
output1=`sysctl kernel.randomize_va_space | cut -d" " -f3`
output2=`grep 'kernel\.randomize_va_space\s*=\s*2' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -ne 2 || ${output2} = "" ]]; then
	echo -e "\n\tASLR 未启用。" >> ${REPORT}
else
	echo -e "\n\tASLR 已启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.5.4 检查 prelink 是否已禁用" | tee -a ${REPORT}
rpm -q prelink &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tprelink 已禁用。" >> ${REPORT}
else
	echo -e "\n\tprelink 未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "1.6 强制访问控制"
echo "1.6.1 配置 SELinux"
echo -n "1.6.1.1 检查在 bootloader 配置中是否未禁用 Selinux" | tee -a ${REPORT}
grep '^\s*linux' /boot/grub2/grub.cfg | egrep 'selinux=0|enforcing=0' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tbootloader 配置中未禁用 Selinux。" >> ${REPORT}
else
	echo -e "\n\tbootloader 配置中禁用了 Selinux。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.6.1.2 检查 SELinux 状态是否为 enforcing" | tee -a ${REPORT}
output=`getenforce`
if [[ ${output} = "Disabled" ]]; then
	echo -e "\n\tSELinux 未启用，跳过检查。" >> ${REPORT}
else
	output1=`grep SELINUX=enforcing /etc/selinux/config`
	output2=`sestatus | egrep 'Current mode|config file' | grep -v enforcing`
	if [[ ${output1} = "" || ${output2} = !"" ]]; then
		echo -e "\n\tSELinux 状态非 enforcing。" >> ${REPORT}
	else
		echo -e "\n\tSELinux 状态为 enforcing。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.6.1.3 检查 SELinux 策略是否已配置" | tee -a ${REPORT}
output1=`grep SELINUXTYPE=minimum /etc/selinux/config`
output2=`sestatus | grep 'Loaded policy name' | cut -d: -f2 | xargs`
if [[ ${output1} != "" || ${output2} = "minimum" ]]; then
	echo -e "\n\tSELinux 策略未配置。" >> ${REPORT}
else
	echo -e "\n\tSELinux 策略已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.6.1.4 检查 SETroubleshoot 是否未安装" | tee -a ${REPORT}
rpm -q setroubleshoot &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSETroubleshoot 未安装。" >> ${REPORT}
else
	echo -e "\n\tSETroubleshoot 已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.6.1.5 检查 mcstrans 是否未安装" | tee -a ${REPORT}
rpm -q mcstrans &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tmcstrans 未安装。" >> ${REPORT}
else
	echo -e "\n\tmcstrans 已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.6.1.6 检查是否存在未在 SELinux 策略中定义的守护进程" | tee -a ${REPORT}
ps -eZ | grep initrc | egrep -vw 'tr|ps|egrep|bash|awk' | tr ':' ' ' | awk '{print $NF}' > /tmp/unconfined_daemons 2> /dev/null
if [[ -s /tmp/unconfined_daemons ]]; then
	echo -e "\n\t未在 SELinux 策略中定义的守护进程如下：" >> ${REPORT}
	cat /tmp/unconfined_daemons | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t不存在未在 SELinux 策略中定义的守护进程。" >> ${REPORT}
fi
rm -f /tmp/unconfined_daemons
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.6.2 检查 SELinux 是否已安装" | tee -a ${REPORT}
rpm -q libselinux &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSELinux 未安装。" >> ${REPORT}
else
	echo -e "\n\tSELinux 已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "1.7 警告横幅"
echo "1.7.1 命令行警告横幅"
echo -n "1.7.1.1 检查今日消息是否已正确配置" | tee -a ${REPORT}
egrep '(\\v|\\r|\\m|\\s)' /etc/motd &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t今日消息未正确配置，配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/motd:" >> ${REPORT}
	cat /etc/motd | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t今日消息已正确配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.7.1.2 检查本地登录的警告横幅是否已正确配置" | tee -a ${REPORT}
egrep '(\\v|\\r|\\m|\\s)' /etc/issue &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t本地登录的警告横幅未正确配置，配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/issue:" >> ${REPORT}
	cat /etc/issue | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t本地登录的警告横幅已正确配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.7.1.3 检查远程登录的警告横幅是否已正确配置" | tee -a ${REPORT}
egrep '(\\v|\\r|\\m|\\s)' /etc/issue.net &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t远程登录的警告横幅未正确配置，配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/issue.net:" >> ${REPORT}
	cat /etc/issue.net | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t远程登录的警告横幅已正确配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.7.1.4 检查 /etc/motd 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/motd`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/motd 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/motd | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/motd 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.7.1.5 检查 /etc/issue 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/issue`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/issue 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/issue | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/issue 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.7.1.6 检查 /etc/issue.net 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/issue.net`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/issue.net 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/issue.net | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/issue.net 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.7.2 检查 GDM 的登录横幅是否已配置" | tee -a ${REPORT}
rpm -q gdm &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tGDM 未安装，跳过检查。" >> ${REPORT}
else
	if [[ -f /etc/dconf/profile/gdm ]]; then
		cat /etc/dconf/profile/gdm > /tmp/gdm
		if grep -q user-db:user /tmp/gdm && grep -q system-db:gdm /tmp/gdm && grep -q file-db:/usr/share/gdm/greeter-dconf-defaults /tmp/gdm; then
			echo -e "\n\t/etc/dconf/profile/gdm 文件配置正确。" >> ${REPORT}

			if [[ -d /etc/dconf/db/gdm.d ]]; then
				output1=`grep -r banner-message-enable=true /etc/dconf/db/gdm.d/* 2> /dev/null`
				output2=`grep -r banner-message-text /etc/dconf/db/gdm.d/* 2> /dev/null`
				if [[ ${output1} = "" || ${output2} = "" ]]; then
					echo -e "\tGDM 的登录横幅配置不正确。" >> ${REPORT}
				else
					echo -e "\tGDM 的登录横幅已配置。" >> ${REPORT}
				fi
			else
				echo -e "\t/etc/dconf/db/gdm.d 目录不存在。" >> ${REPORT}
			fi
		else
			echo -e "\n\t/etc/dconf/profile/gdm 文件配置不正确。" >> ${REPORT}
		fi
	else
		echo -e "\n\t/etc/dconf/profile/gdm 文件不存在。" >> ${REPORT}
	fi
fi
rm -f /tmp/gdm
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.8 检查更新、补丁和额外的安全软件是否已安装" | tee -a ${REPORT}
output1=`yum check-update --security | grep 'needed for security' | cut -d ";" -f1`
output2=`yum check-update | egrep -v 'Load|\*'`
if [[ ${output1} = "No packages needed for security" ]]; then
	echo -e "\n\t补丁和额外的安全软件均已安装。" >> ${REPORT}
else
	echo -e "\n\t需要更新的补丁或安全软件信息如下：" >> ${REPORT}
	yum check-update --security | egrep -v 'Load|\*|updateinfo' | sed 's/^/\t/g' >> ${REPORT}
fi

if [[ ${output2} = "" ]]; then
	echo -e "\n\t软件包均已更新。" >> ${REPORT}
else
	echo -e "\n\t需要更新的软件包信息如下：" >> ${REPORT}
	yum check-update | egrep -v 'Load|\*' | awk '{print $1}' | sed -e '/^$/d; s/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "2 服务" | tee -a ${REPORT}
echo "2.1 inetd 服务"
rpm -q xinetd.service &> /dev/null
if [[ $? -eq 0 ]]; then
	xinetdid=0
else
	xinetdid=1
fi

echo -n "2.1.1 检查 chargen 服务是否未启用" | tee -a ${REPORT}
if [[ ${xinetdid} -eq 1 ]]; then
	echo -e "\n\txinetd 未安装，跳过检查。" >> ${REPORT}
else
	chkconfig --list 2> /dev/null | grep chargen | grep on &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\tchargen 服务已启用。" >> ${REPORT}
	else
		echo -e "\n\tchargen 服务未启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.1.2 检查 daytime 服务是否未启用" | tee -a ${REPORT}
if [[ ${xinetdid} -eq 1 ]]; then
	echo -e "\n\txinetd 未安装，跳过检查。" >> ${REPORT}
else
	chkconfig --list 2> /dev/null | grep daytime | grep on &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\tdaytime 服务已启用。" >> ${REPORT}
	else
		echo -e "\n\tdaytime 服务未启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.1.3 检查 discard 服务是否未启用" | tee -a ${REPORT}
if [[ ${xinetdid} -eq 1 ]]; then
	echo -e "\n\txinetd 未安装，跳过检查。" >> ${REPORT}
else
	chkconfig --list 2> /dev/null | grep discard | grep on &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\tdiscard 服务已启用。" >> ${REPORT}
	else
		echo -e "\n\tdiscard 服务未启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.1.4 检查 echo 服务是否未启用" | tee -a ${REPORT}
if [[ ${xinetdid} -eq 1 ]]; then
	echo -e "\n\txinetd 未安装，跳过检查。" >> ${REPORT}
else
	chkconfig --list 2> /dev/null | grep echo | grep on &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\techo 服务已启用。" >> ${REPORT}
	else
		echo -e "\n\techo 服务未启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.1.5 检查 time 服务是否未启用" | tee -a ${REPORT}
if [[ ${xinetdid} -eq 1 ]]; then
	echo -e "\n\txinetd 未安装，跳过检查。" >> ${REPORT}
else
	chkconfig --list 2> /dev/null | grep time | grep on &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\ttime 服务已启用。" >> ${REPORT}
	else
		echo -e "\n\ttime 服务未启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

# CIS_CentOS_Linux_7_Benchmark_v2.2.0 中原为 tftp server，实际查看 xinetd 判断此处应为 tcpmux。
echo -n "2.1.6 检查 tcpmux 服务是否未启用" | tee -a ${REPORT}
if [[ ${xinetdid} -eq 1 ]]; then
	echo -e "\n\txinetd 未安装，跳过检查。" >> ${REPORT}
else
	chkconfig --list 2> /dev/null | grep tcpmux | grep on &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "\n\ttcpmux 服务器已启用。" >> ${REPORT}
	else
		echo -e "\n\ttcpmux 服务器未启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.1.7 检查 xinetd 是否未启用" | tee -a ${REPORT}
if [[ ${xinetdid} -eq 1 ]]; then
	echo -e "\n\txinetd 未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled xinetd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\txinetd 未启用。" >> ${REPORT}
	else
		echo -e "\n\txinetd 已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "2.2 特殊用途服务"
echo "2.2.1 时间同步"
echo -n "2.2.1.1 检查时间同步是否启用" | tee -a ${REPORT}
rpm -q ntp &> /dev/null
if [[ $? -eq 0 ]]; then
	ntpid=0
else
	ntpid=1
fi
rpm -q chrony &> /dev/null
if [[ $? -eq 0 ]]; then
	chronyid=0
else
	chronyid=1
fi

if [[ ${ntpid} -eq 1 && ${chronyid} -eq 1 ]]; then
	echo -e "\n\t时间同步未启用。" >> ${REPORT}
else
	echo -e "\n\t时间同步已启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.1.2 检查 ntp 是否已配置" | tee -a ${REPORT}
if [[ ${ntpid} -eq 1 ]]; then
	echo -e "\n\tntp 未安装，跳过检查。" >> ${REPORT}
else
	echo -e "\n\tntp 配置如下，请手动检查是否合规：" >> ${REPORT}
	cat /etc/ntp.conf | grep -v '#' | sed -e '/^$/d;s/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.1.3 检查 chrony 是否已配置" | tee -a ${REPORT}
if [[ ${chronyid} -eq 1 ]]; then
	echo -e "\n\tchrony 未安装，跳过检查。" >> ${REPORT}
else
	echo -e "\n\tchrony 配置如下，请手动检查是否合规：" >> ${REPORT}
	cat /etc/chrony.conf | grep -v '#' | sed -e '/^$/d;s/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.2 检查 X Window System 是否未安装" | tee -a ${REPORT}
output=`rpm -qa xorg-x11*`
if [[ ${output} = "" ]]; then
	echo -e "\n\tX Window System 未安装。" >> ${REPORT}
else
	echo -e "\n\tX Window System 已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.3 检查 Avahi 服务器是否未启用" | tee -a ${REPORT}
rpm -q avahi &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tAvahi 服务未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled avahi-daemon &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tAvahi 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tAvahi 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.4 检查 CUPS 服务是否未启用" | tee -a ${REPORT}
rpm -q cups &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tCUPS 服务未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled cups &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tCUPS 服务未启用。" >> ${REPORT}
	else
		echo -e "\n\tCUPS 服务已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.5 检查 DHCP 服务器是否未启用" | tee -a ${REPORT}
rpm -q dhcp &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tDHCP 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled dhcpd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tDHCP 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tDHCP 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.6 检查 LDAP 服务器是否未启用" | tee -a ${REPORT}
rpm -q openldap-servers &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tLDAP 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled slapd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tLDAP 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tLDAP 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.7 检查 NFS 和 RPC 是否未启用" | tee -a ${REPORT}
rpm -q nfs-utils &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tNFS 服务未安装，跳过检查。" >> ${REPORT}
else
	output1=`systemctl is-enabled nfs`
	output2=`systemctl is-enabled nfs-server`
	if [[ ${output1} = "disbaled" && ${output2} = "disabled" ]]; then
		echo -e "\n\tNFS 服务未启用。" >> ${REPORT}
	else
		echo -e "\n\tNFS 服务已启用。" >> ${REPORT}
	fi
fi

rpm -q rpcbind &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tRPC 服务未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled rpcbind &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tRPC 服务未启用。" >> ${REPORT}
	else
		echo -e "\n\tRPC 服务已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.8 检查 DNS 服务器是否未启用" | tee -a ${REPORT}
rpm -q bind &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tDNS 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled named &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tDNS 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tDNS 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.9 检查 FTP (vsftpd) 服务器是否未启用" | tee -a ${REPORT}
rpm -q vsftpd &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tFTP (vsftpd) 服务器未安装，跳过检查。可能存在其他 FTP 服务器，请手动检查。" >> ${REPORT}
else
	systemctl is-enabled vsftpd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tFTP (vsftpd) 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tFTP (vsftpd) 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.10 检查 HTTP (httpd) 服务器是否未启用" | tee -a ${REPORT}
rpm -q httpd &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tHTTP (httpd) 服务器未安装，跳过检查。可能存在其他类似服务如apache, apache2, lighttpd 和 nginx 等，请手动检查。" >> ${REPORT}
else
	systemctl is-enabled httpd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tHTTP (httpd) 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tHTTP (httpd) 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.11 检查 IMAP 和 POP3 服务器 (dovecot) 是否未启用" | tee -a ${REPORT}
rpm -q dovecot &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tIMAP 和 POP3 服务器 (dovecot) 未安装，跳过检查。可能存在其他 IMAP 和 POP3 服务器，请手动检查。" >> ${REPORT}
else
	systemctl is-enabled dovecot &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tIMAP 和 POP3 服务器 (dovecot) 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tIMAP 和 POP3 服务器 (dovecot) 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.12 检查 Samba 是否未启用" | tee -a ${REPORT}
rpm -q samba &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSamba 未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled smb &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tSamba 未启用。" >> ${REPORT}
	else
		echo -e "\n\tSamba 已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.13 检查 HTTP 代理服务器 (squid) 是否未启用" | tee -a ${REPORT}
rpm -q squid &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tHTTP 代理服务器 (squid) 未安装，跳过检查。可能存在其他 HTTP 代理服务器，请手动检查。" >> ${REPORT}
else
	systemctl is-enabled squid &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tHTTP 代理服务器 (squid) 未启用。" >> ${REPORT}
	else
		echo -e "\n\tHTTP 代理服务器 (squid) 已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.14 检查 SNMP 服务器是否未启用" | tee -a ${REPORT}
rpm -q net-snmp &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSNMP 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled snmpd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tSNMP 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tSNMP 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.15 检查邮件传输代理是否已配置为 local-only 模式" | tee -a ${REPORT}
netstat -an | grep LIST | grep :25 | egrep  '127\.0\.0\.1|::1' &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t邮件传输代理未配置为 local-only 模式。" >> ${REPORT}
else
	echo -e "\n\t邮件传输代理已配置为 local-only 模式。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.16 检查 NIS 服务器是否未启用" | tee -a ${REPORT}
rpm -q ypserv &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tNIS 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled ypserv &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tNIS 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\tNIS 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.17 检查 rsh 服务器是否未启用" | tee -a ${REPORT}
rpm -q rsh-server &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\trsh 服务器未安装，跳过检查。" >> ${REPORT}
else
	output1=`systemctl is-enabled rsh.socket`
	output2=`systemctl is-enabled rlogin.socket`
	output3=`systemctl is-enabled rexec.socket`
	if [[ ${output1} = "disabled" && ${output2} = "disabled" && ${output3} = "disabled" ]]; then
		echo -e "\n\trsh 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\trsh 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.18 检查 telnet 服务器是否未启用" | tee -a ${REPORT}
rpm -q telnet-server &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\ttelnet 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled telnet.socket &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\ttelnet 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\ttelnet 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.19 检查 tftp 服务器是否未启用" | tee -a ${REPORT}
rpm -q tftp-server &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\ttftp 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled tftp.socket &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\ttftp 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\ttftp 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.20 检查 rsync 服务是否未启用" | tee -a ${REPORT}
rpm -q rsync &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\trsync 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled rsyncd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\trsync 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\trsync 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.2.21 检查 talk 服务器是否未启用" | tee -a ${REPORT}
rpm -q talk-server &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\ttalk 服务器未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled ntalk &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\ttalk 服务器未启用。" >> ${REPORT}
	else
		echo -e "\n\ttalk 服务器已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "2.3 服务客户端"
echo -n "2.3.1 检查 NIS 客户端是否未安装" | tee -a ${REPORT}
rpm -q ypbind &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tNIS 客户端未安装。" >> ${REPORT}
else
	echo -e "\n\tNIS 客户端已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.3.2 检查 rsh 客户端是否未安装" | tee -a ${REPORT}
rpm -q rsh &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\trsh 客户端未安装。" >> ${REPORT}
else
	echo -e "\n\trsh 客户端已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.3.3 检查 talk 客户端是否未安装" | tee -a ${REPORT}
rpm -q talk &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\ttalk 客户端未安装。" >> ${REPORT}
else
	echo -e "\n\ttalk 客户端已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.3.4 检查 telnet 客户端是否未安装" | tee -a ${REPORT}
rpm -q telnet &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\ttelnet 客户端未安装。" >> ${REPORT}
else
	echo -e "\n\ttelnet 客户端已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "2.3.5 检查 LDAP 客户端是否未安装" | tee -a ${REPORT}
rpm -q openldap-clients &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tLDAP 客户端未安装。" >> ${REPORT}
else
	echo -e "\n\tLDAP 客户端已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "3 网络配置" | tee -a ${REPORT}
echo "3.1 网络参数 (Host Only)"
echo -n "3.1.1 检查 IP 转发是否已禁用" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/ip_forward`
output2=`grep 'net\.ipv4\.ip_forward\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 0 && ${output2} = "" ]]; then
	echo -e "\n\tIP 转发已禁用。" >> ${REPORT}
else
	echo -e "\n\tIP 转发未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.1.2 检查数据包重定向发送是否已禁用" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/conf/all/send_redirects`
output2=`cat /proc/sys/net/ipv4/conf/default/send_redirects`
output3=`grep 'net\.ipv4\.conf\.all\.send_redirects\s*=\s*1' /etc/sysctl.conf`
output4=`grep 'net\.ipv4\.conf\.default\.send_redirects\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 0 && ${output2} -eq 0 && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\t数据包重定向发送已禁用。" >> ${REPORT}
else
	echo -e "\n\t数据包重定向发送未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "3.2 网络参数 (Host and Router)"
echo -n "3.2.1 检查是否已禁用源路由数据包" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/conf/default/accept_source_route`
output2=`cat /proc/sys/net/ipv4/conf/default/send_redirects`
output3=`grep 'net\.ipv4\.conf\.all\.accept_source_route\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
output4=`grep 'net\.ipv4\.conf\.default\.accept_source_route\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 0 && ${output2} -eq 0 && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\t源路由数据包已禁用。" >> ${REPORT}
else
	echo -e "\n\t源路由数据包未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2.2 检查是否已禁用 ICMP 重定向" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/conf/all/accept_redirects`
output2=`cat /proc/sys/net/ipv4/conf/default/accept_redirects`
output3=`grep 'net\.ipv4\.conf\.all\.accept_redirects\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
output4=`grep 'net\.ipv4\.conf\.default\.accept_redirects\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 0 && ${output2} -eq 0 && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\tICMP 重定向已禁用。" >> ${REPORT}
else
	echo -e "\n\tICMP 重定向未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2.3 检查是否已禁用安全的 ICMP 重定向" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/conf/all/secure_redirects`
output2=`cat /proc/sys/net/ipv4/conf/default/secure_redirects`
output3=`grep 'net\.ipv4\.conf\.all\.secure_redirects\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
output4=`grep 'net\.ipv4\.conf\.default\.secure_redirects\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 0 && ${output2} -eq 0 && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\t安全的 ICMP 重定向已禁用。" >> ${REPORT}
else
	echo -e "\n\t安全的 ICMP 重定向未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2.4 检查可疑数据包是否被记录" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/conf/all/log_martians`
output2=`cat /proc/sys/net/ipv4/conf/default/log_martians`
output3=`grep 'net\.ipv4\.conf\.all\.log_martians\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
output4=`grep 'net\.ipv4\.conf\.default\.log_martians\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 1 && ${output2} -eq 1 && ${output3} != "" && ${output4} != "" ]]; then
	echo -e "\n\t记录可疑数据包已启用。" >> ${REPORT}
else
	echo -e "\n\t记录可疑数据包已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2.5 检查广播 ICMP 请求是否被忽略" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts`
output2=`grep 'net\.ipv4\.icmp_echo_ignore_broadcasts\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 1 && ${output2} != "" ]]; then
	echo -e "\n\t忽略广播 ICMP 请求已启用。" >> ${REPORT}
else
	echo -e "\n\t忽略广播 ICMP 请求已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2.6 检查虚假 ICMP 响应是否被忽略" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses`
output2=`grep 'net\.ipv4\.icmp_ignore_bogus_error_responses\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 1 && ${output2} != "" ]]; then
	echo -e "\n\t忽略虚假 ICMP 响应已启用。" >> ${REPORT}
else
	echo -e "\n\t忽略虚假 ICMP 响应已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2.7 检查反向路径过滤是否已启用" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/conf/all/rp_filter`
output2=`cat /proc/sys/net/ipv4/conf/default/rp_filter`
output3=`grep 'net\.ipv4\.conf\.all\.rp_filter\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
output4=`grep 'net\.ipv4\.conf\.default\.rp_filter\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 1 && ${output2} -eq 1 && ${output3} != "" && ${output4} != "" ]]; then
	echo -e "\n\t反向路径过滤已启用。" >> ${REPORT}
else
	echo -e "\n\t反向路径过滤未启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2.8 检查 TCP SYN Cookies 是否已启用" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv4/tcp_syncookies`
output2=`grep 'net\.ipv4\.tcp_syncookies\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 1 && ${output2} != "" ]]; then
	echo -e "\n\tTCP SYN Cookies 已启用。" >> ${REPORT}
else
	echo -e "\n\tTCP SYN Cookies 未启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "3.3 IPv6"
echo -n "3.3.1 检查是否已拒绝 IPv6 路由广播" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv6/conf/all/accept_ra`
output2=`cat /proc/sys/net/ipv6/conf/default/accept_ra`
output3=`grep 'net\.ipv6\.conf\.all\.accept_ra\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
output4=`grep 'net\.ipv6\.conf\.default\.accept_ra\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 0 && ${output2} -eq 0 && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\tIPv6 路由广播已禁用。" >> ${REPORT}
else
	echo -e "\n\tIPv6 路由广播未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.3.2 检查是否已拒绝 IPv6 重定向" | tee -a ${REPORT}
output1=`cat /proc/sys/net/ipv6/conf/all/accept_redirects`
output2=`cat /proc/sys/net/ipv6/conf/default/accept_redirects`
output3=`grep 'net\.ipv6\.conf\.all\.accept_redirect\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
output4=`grep 'net\.ipv6\.conf\.default\.accept_redirect\s*=\s*1' /etc/sysctl.conf /etc/sysctl.d/*`
if [[ ${output1} -eq 0 && ${output2} -eq 0 && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\tIPv6 重定向已禁用。" >> ${REPORT}
else
	echo -e "\n\tIPv6 重定向未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.3.3 检查 IPv6 是否已禁用" | tee -a ${REPORT}
grep '^\s*linux' /boot/grub2/grub.cfg | grep 'ipv6\.disable=1' &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tIPv6 已禁用。" >> ${REPORT}
else
	echo -e "\n\tIPv6 未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "3.4 TCP Wrappers"
echo -n "3.4.1 检查 TCP Wrappers 是否已安装" | tee -a ${REPORT}
rpm -q tcp_wrappers &> /dev/null
if [[ $? -eq 0 ]]; then
	tcpwrap=0
fi
rpm -q tcp_wrappers-libs &> /dev/null
if [[ $? -eq 0 ]]; then
	libwrap=0
fi
if [[ ${tcpwrap} -eq 0 && ${libwrap} -eq 0 ]]; then
	echo -e "\n\tTCP Wrappers 已安装。" >> ${REPORT}
elif [[ ${tcpwrap} -eq 0 && ${libwrap} -ne 0 ]]; then
	echo -e "\n\tTCP Wrappers 已安装 (libwrap.so 未安装)。" >> ${REPORT}
else
	echo -e "\n\tTCP Wrappers 未安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.4.2 检查 /etc/hosts.allow 是否已配置" | tee -a ${REPORT}
cat /etc/hosts.allow | grep -v '#' &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/etc/hosts.allow 配置如下：" >> ${REPORT}
	cat /etc/hosts.allow | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/hosts.allow 未配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.4.3 检查 /etc/hosts.deny 是否已配置" | tee -a ${REPORT}
cat /etc/hosts.deny | grep -v '#' | grep -i 'ALL\s*:\s*ALL' &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/etc/hosts.deny 已配置。" >> ${REPORT}
else
	echo -e "\n\t/etc/hosts.deny 未配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.4.4 检查 /etc/hosts.allow 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/hosts.allow`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/hosts.allow 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/hosts.allow | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/hosts.allow 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.4.5 检查 /etc/hosts.deny 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/hosts.deny`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/hosts.deny 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/hosts.deny | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/hosts.deny 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "3.5 稀有网络协议"
echo -n "3.5.1 检查 DCCP 是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v dccp 2> /dev/null`
lsmod | grep dccp &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tDCCP 已禁用。" >> ${REPORT}
else
	echo -e "\n\tDCCP 未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.5.2 检查 SCTP 是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v sctp 2> /dev/null`
lsmod | grep sctp &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tSCTP 已禁用。" >> ${REPORT}
else
	echo -e "\n\tSCTP 未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.5.3 检查 RDS 是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v rds 2> /dev/null`
lsmod | grep rds &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tRDS 已禁用。" >> ${REPORT}
else
	echo -e "\n\tRDS 未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.5.4 检查 TIPC 是否已禁用" | tee -a ${REPORT}
output=`modprobe -n -v tipc 2> /dev/null`
lsmod | grep tipc &> /dev/null
if [[ $? -ne 0 && ${output} = "install /bin/true" ]]; then
	echo -e "\n\tTIPC 已禁用。" >> ${REPORT}
else
	echo -e "\n\tTIPC 未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "3.6 防火墙配置"
echo -n "3.6.1 检查 iptables 是否已安装" | tee -a ${REPORT}
rpm -q iptables-services &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tiptables 未安装，跳过检查。" >> ${REPORT}
else
	systemctl is-enabled iptables &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tiptables 已安装但未启用。" >> ${REPORT}
	else
		echo -e "\n\tiptables 已安装且已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.6.2 检查防火墙的默认策略是否为拒绝" | tee -a ${REPORT}
iptables -L | grep policy | grep INPUT | grep ACCEPT &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tINPUT 链的默认策略为 DROP/REJECT。" >> ${REPORT}
else
	echo -e "\n\tINPUT 链的默认策略为 ACCEPT。" >> ${REPORT}
fi
iptables -L | grep policy | grep FORWARD | grep ACCEPT &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\tFORWARD 链的默认策略为 DROP/REJECT。" >> ${REPORT}
else
	echo -e "\tFORWARD 链的默认策略为 ACCEPT。" >> ${REPORT}
fi
iptables -L | grep policy | grep OUTPUT | grep ACCEPT &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\tFORWARD 链的默认策略为 DROP/REJECT。" >> ${REPORT}
else
	echo -e "\tFORWARD 链的默认策略为 ACCEPT。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.6.3 检查环回流量的防火墙规则是否已配置" | tee -a ${REPORT}
iptables -L -v -n | egrep 'lo|127\.0\.0\.0/8' &> /null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t环回流量的防火墙规则未配置。" >> ${REPORT}
else
	echo -e "\n\t环回流量的防火墙规则如下：" >> ${REPORT}
	iptables -L -v -n | egrep 'Chain|pkts|lo|127\.0\.0\.0/8' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.6.4 检查出站和已建立连接的防火墙规则是否已配置" | tee -a ${REPORT}
iptables -L OUTPUT -v -n | egrep -v 'Chain|pkts' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t出站防火墙规则未配置。" >> ${REPORT}
else
	echo -e "\n\t出站防火墙规则配置信息如下：" >> ${REPORT}
	iptables -L OUTPUT -v -n | sed 's/^/\t/g' >> ${REPORT}
fi
iptables -L -v -n | grep ESTABLISHED &> /null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t已建立连接的防火墙规则未配置。" >> ${REPORT}
else
	echo -e "\n\t已建立连接的防火墙规则配置信息如下：" >> ${REPORT}
	iptables -L -v -n | egrep 'Chain|pkts|ESTABLISHED' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.6.5 检查是否所有开放端口都存在防火墙规则" | tee -a ${REPORT}
iptables-save | egrep -v '#|\*|^:|COMMIT|lo|127\.0\.0\.0/8' &> /null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t不存在任何防火墙规则。" >> ${REPORT}
else
	output=`netstat -lnt | grep -w tcp | awk '{print $4}' | cut -d: -f2`
	for port in ${output}; do
		iptables -L -n -v | grep ${port} &> /dev/null
		if [[ $? -ne 0 ]]; then
			echo -e -n "\n\t端口 ${port} 不存在防火墙规则。" >> /tmp/portrules
		fi
	done
fi

if [[ -f /tmp/portrules ]]; then
	cat /tmp/portrules  >> ${REPORT}
else
	echo -e "\n\t所有开放端口都存在防火墙规则。" >> ${REPORT}
fi
rm -f /tmp/portrules
echo "..........[OK]"
echo "" >> ${REPORT}

# 待补完
echo -n "3.7 检查无线接口是否已禁用" | tee -a ${REPORT}
output=`nmcli device wifi 2> /dev/null`
if [[ ${output} = "" ]]; then
	echo -e "\n\t未检测到无线接口，跳过检查。" >> ${REPORT}
else
	echo "" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "4 日志和审计" | tee -a ${REPORT}
echo "4.1 配置系统审计 (auditd)"
echo "4.1.1 配置数据保留"
echo -n "4.1.1.1 检查审计日志存储大小是否已配置" | tee -a ${REPORT}
grep -w ^max_log_file /etc/audit/auditd.conf &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t审计日志存储大小未配置。" >> ${REPORT}
else
	echo -e "\n\t审计日志存储大小已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.1.2 检查审计日志满时系统是否会被禁用" | tee -a ${REPORT}
grep -i '^space_left_action\s*=\s*email' /etc/audit/auditd.conf &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未配置审计日志将满时发送邮件告警。" >> ${REPORT}
fi
grep -i '^action_mail_acct\s*=\s*root' /etc/audit/auditd.conf &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t电子邮件地址非 root。" >> ${REPORT}
fi
grep -i '^admin_space_left_action\s*=\s*halt' /etc/audit/auditd.conf &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未配置审计日志满时禁用系统。" >> ${REPORT}
else
	echo -e "\n\t已配置审计日志满时禁用系统。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.1.3 检查审计日志是否不会被自动删除" | tee -a ${REPORT}
grep -i '^max_log_file_action\s*=\s*keep_logs' /etc/audit/auditd.conf &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未配置审计日志不被自动删除。" >> ${REPORT}
else
	echo -e "\n\t已配置审计日志不被自动删除。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.2 检查 auditd 服务是否已启用" | tee -a ${REPORT}
rpm -q audit &> /dev/null
if [[ $? -eq 0 ]]; then
	systemctl is-enabled auditd &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tauditd 服务未启用。" >> ${REPORT}
	else
		echo -e "\n\tauditd 服务已启用。" >> ${REPORT}
	fi
else
	echo -e "\n\tauditd 服务未安装，跳过检查。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.3 检查是否已启用对先于 auditd 启动的进程的审计" | tee -a ${REPORT}
grep '^\s*linux' /boot/grub2/grub.cfg | grep audit=1 &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未启用对先于 auditd 启动的进程的审计。" >> ${REPORT}
else
	echo -e "\n\t已启用对先于 auditd 启动的进程的审计。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.4 检查修改日期和时间信息的事件是否会被采集" | tee -a ${REPORT}
output1=`grep time-change /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep time-change`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集修改日期和时间信息的事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep time-change /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep time-change /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep time-change | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.5 检查修改用户/组信息的事件是否被采集" | tee -a ${REPORT}
output1=`grep identity /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep identity`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集修改用户/组信息的事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep identity /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep identity /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep identity | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.6 检查修改系统网络环境的事件是否被采集" | tee -a ${REPORT}
output1=`grep system-locale /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep system-locale`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集修改系统网络环境的事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep system-locale /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep system-locale /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep system-locale | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.7 检查修改系统强制访问控制的事件是否被采集" | tee -a ${REPORT}
grep MAC-policy /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未配置采集修改系统强制访问控制的事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep MAC-policy /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep MAC-policy /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.8 检查登录和登出事件是否被采集" | tee -a ${REPORT}
grep logins /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | egrep '/var/log/lastlog|/var/run/faillock/' | grep -v '#' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未配置采集登录和登出事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep logins /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep logins /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.9 检查会话发起信息是否被采集" | tee -a ${REPORT}
output1=`grep session /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep session`
output3=`grep logins /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | egrep "/var/log/wtmp|/var/log/btmp" | grep -v '#'`
output4=`auditctl -l | grep logins | egrep '/var/log/wtmp|/var/log/btmp'`
if [[ ${output1} = "" && ${output2} = "" && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\t未配置采集会话发起信息。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	egrep 'session|logins' /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	egrep 'session|logins' /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | egrep 'session|logins' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.10 检查修改自主访问控制权限的事件是否被采集" | tee -a ${REPORT}
output1=`grep perm_mod /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep perm_mod`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集修改自主访问控制权限的事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep perm_mod /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep perm_mod /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep perm_mod | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.11 检查失败的文件非法访问企图是否被采集" | tee -a ${REPORT}
output1=`grep access /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep access`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集失败的文件非法访问企图。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep access /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep access /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep access | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.12 检查特权命令的使用记录是否被采集" | tee -a ${REPORT}
output1=`grep privileged /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep privileged`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集特权命令的使用记录。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep privileged /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep privileged /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep privileged | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.13 检查成功的系统挂载事件是否被采集" | tee -a ${REPORT}
output1=`grep mounts /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep mounts`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集成功的系统挂载事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep mounts /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep mounts /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep mounts | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.14 检查用户删除文件的事件是否被采集" | tee -a ${REPORT}
output1=`grep delete /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep delete`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集用户删除文件的事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep delete /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep delete /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep delete | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.15 检查变更系统管理范围 (sudoers) 的事件是否被采集" | tee -a ${REPORT}
output1=`grep scope /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep scope`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集变更系统管理范围 (sudoers) 的事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep scope /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep scope /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep scope | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.16 检查系统管理员操作 (sudolog) 是否被采集" | tee -a ${REPORT}
output1=`grep actions /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep actions`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集系统管理员操作 (sudolog)。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep actions /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep actions /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep actions | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.17 检查内核模块加载和卸载事件是否被采集" | tee -a ${REPORT}
output1=`grep modules /etc/audit/audit.rules /etc/audit/rules.d/audit.rules | grep -v '#'`
output2=`auditctl -l | grep modules`
if [[ ${output1} = "" && ${output2} = "" ]]; then
	echo -e "\n\t未配置采集内核模块加载和卸载事件。" >> ${REPORT}
else
	echo -e "\n\t配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/audit/audit.rules:" >> ${REPORT}
	grep modules /etc/audit/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/audit/rules.d/audit.rules:" >> ${REPORT}
	grep modules /etc/audit/rules.d/audit.rules | grep -v '#' | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\tauditctl:" >> ${REPORT}
	auditctl -l | grep modules | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.1.18 检查审计配置是否不可修改" | tee -a ${REPORT}
tail -1 /etc/audit/rules.d/audit.rules | grep '\-e 2' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未配置审计配置不可修改。" >> ${REPORT}
else
	echo -e "\n\t已配置审计配置不可修改。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "4.2 配置日志"
echo "4.2.1 配置 rsyslog"
echo -n "4.2.1.1 检查 rsyslog 服务是否已启用" | tee -a ${REPORT}
rpm -q rsyslog &> /dev/null
if [[ $? -ne 0 ]]; then
	rsyslogid=1
	echo -e "\n\trsyslog 未安装，跳过检查。" >> ${REPORT}
else
	rsyslogid=0
	systemctl is-enabled rsyslog &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\trsyslog 服务已启用。" >> ${REPORT}
	else
		echo -e "\n\trsyslog 服务未启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.1.2 检查日志是否已配置" | tee -a ${REPORT}
if [[ ${rsyslogid} -eq 1 ]]; then
	echo -e "\n\trsyslog 未安装，跳过检查。" >> ${REPORT}
else
	grep -v '#' /etc/rsyslog.conf /etc/rsyslog.d/* &> /dev/null
	if [[ $? -ne 0 ]]; then
		rsysconfid=1
		echo -e "\n\t未检测到任何日志配置。" >> ${REPORT}
	else
		echo -e "\n\t日志配置信息如下：" >> ${REPORT}
		echo -e "\t/etc/rsyslog.conf:" >> ${REPORT}
		grep -v '#' /etc/rsyslog.conf | sed -e '/^$/d;s/^/\t/g' >> ${REPORT}
		for file in `ls /etc/rsyslog.d`; do
			echo -e "\n\t/etc/rsyslog.d/${file}:" >> ${REPORT}
			grep -v '#' /etc/rsyslog.d/${file} | sed -e '/^$/d;s/^/\t/g' >> ${REPORT}
		done
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.1.3 检查 rsyslog 默认文件权限是否已配置" | tee -a ${REPORT}
if [[ ${rsyslogid} -eq 1 ]]; then
	echo -e "\n\trsyslog 未安装，跳过检查。" >> ${REPORT}
else
	if [[ ${rsysconfid} -eq 1 ]]; then
		echo -e "\n\t未检测到任何日志配置，跳过检查。" >> ${REPORT}
	else
		grep '^${file}CreateMode' /etc/rsyslog.conf /etc/rsyslog.d/*.conf &> /dev/null
		if [[ $? -ne 0 ]]; then
			echo -e "\n\trsyslog 默认文件权限未配置。" >> ${REPORT}
		else
			echo -e "\n\trsyslog 默认文件权限配置如下：" >> ${REPORT}
			grep '^${file}CreateMode' /etc/rsyslog.conf /etc/rsyslog.d/*.conf | sed 's/^/\t/g' >> ${REPORT}
		fi
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.1.4 检查 rsyslog 是否配置将日志发送到远程日志主机" | tee -a ${REPORT}
if [[ ${rsyslogid} -eq 1 ]]; then
	echo -e "\n\trsyslog 未安装，跳过检查。" >> ${REPORT}
else
	if [[ ${rsysconfid} -eq 1 ]]; then
		echo -e "\n\t未检测到任何日志配置，跳过检查。" >> ${REPORT}
	else
		grep '^\*\.\*[^I][^I]*@' /etc/rsyslog.conf /etc/rsyslog.d/*.conf &> /dev/null
		if [[ $? -ne 0 ]]; then
			echo -e "\n\t未配置将日志发送到远程日志主机。" >> ${REPORT}
		else
			echo -e "\n\t远程日志主机配置如下：" >> ${REPORT}
			grep '^\*\.\*[^I][^I]*@' /etc/rsyslog.conf /etc/rsyslog.d/*.conf | sed 's/^/\t/g' >> ${REPORT}
		fi
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.1.5 检查远程 rsyslog 消息是否仅在指定的日志主机上接收" | tee -a ${REPORT}
if [[ ${rsyslogid} -eq 1 ]]; then
	echo -e "\n\trsyslog 未安装，跳过检查。" >> ${REPORT}
else
	if [[ ${rsysconfid} -eq 1 ]]; then
		echo -e "\n\t未检测到任何日志配置，跳过检查。" >> ${REPORT}
	else
		egrep '^\$ModLoad imtcp|^\$InputTCPServerRun' /etc/rsyslog.conf /etc/rsyslog.d/*.conf &> /dev/null
		if [[ $? -ne 0 ]]; then
			echo -e "\n\t未在本机上配置接收远程 rsyslog 消息。" >> ${REPORT}
		else
			echo -e "\n\t已在本机上配置接收远程 rsyslog 消息。" >> ${REPORT}
		fi
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "4.2.2 配置 syslog-ng"
echo -n "4.2.2.1 检查 syslog-ng 服务是否已启用" | tee -a ${REPORT}
rpm -q syslog-ng &> /dev/null
if [[ $? -ne 0 ]]; then
	syslogngid=1
	echo -e "\n\tsyslog-ng 未安装，跳过检查。" >> ${REPORT}
else
	syslogngid=0
	systemctl is-enabled syslog-ng &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "\n\tsyslog-ng 服务未启用。" >> ${REPORT}
	else
		echo -e "\n\tsyslog-ng 服务已启用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.2.2 检查日志是否已配置" | tee -a ${REPORT}
if [[ ${syslogngid} -eq 1 ]]; then
	echo -e "\n\tsyslog-ng 未安装，跳过检查。" >> ${REPORT}
else
	grep -v '#' /etc/syslog-ng/syslog-ng.conf &> /dev/null
	if [[ $? -ne 0 ]]; then
		sysngconfid=1
		echo -e "\n\t未检测到任何日志配置。" >> ${REPORT}
	else
		sysngconfid=0
		echo -e "\n\t日志配置信息如下：" >> ${REPORT}
		grep -v '#' /etc/syslog-ng/syslog-ng.conf | sed '/^$/d;s/^/\t/g' >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.2.3 检查 syslog-ng 默认文件权限是否已配置" | tee -a ${REPORT}
if [[ ${syslogngid} -eq 1 ]]; then
	echo -e "\n\tsyslog-ng 未安装，跳过检查。" >> ${REPORT}
else
	if [[ ${sysngconfid} -eq 1 ]]; then
		echo -e "\n\t未检测到任何日志配置。" >> ${REPORT}
	else
		grep ^options /etc/syslog-ng/syslog-ng.conf &> /dev/null
		if [[ $? -ne 0 ]]; then
			echo -e "\n\t未检测到\"options\"相关配置，跳过检查。" >> ${REPORT}
		else
			grep ^options /etc/syslog-ng/syslog-ng.conf | grep 'perm(0640)' &> /dev/null
			if [[ $? -ne 0 ]]; then
				echo -e "\n\t默认文件权限未配置。" >> ${REPORT}
			else
				echo -e "\n\t默认文件权限配置信息如下：" >> ${REPORT}
				grep ^options /etc/syslog-ng/syslog-ng.conf | sed 's/^/\t/g' >> ${REPORT}
			fi
		fi
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.2.4 检查 syslog-ng 是否配置为将日志发送到远程日志主机" | tee -a ${REPORT}
if [[ ${syslogngid} -eq 1 ]]; then
	echo -e "\n\tsyslog-ng 未安装，跳过检查。" >> ${REPORT}
else
	if [[ ${sysngconfid} -eq 1 ]]; then
		echo -e "\n\t未检测到任何日志配置。" >> ${REPORT}
	else
		grep '^destination logserver' /etc/syslog-ng/syslog-ng.conf &> /dev/null
		if [[ $? -ne 0 ]]; then
			echo -e "\n\t未配置将日志发送到远程日志主机。" >> ${REPORT}
		else
			echo -e "\n\t远程日志主机配置如下：" >> ${REPORT}
			grep '^destination logserver' /etc/syslog-ng/syslog-ng.conf | sed 's/^/\t/g' >> ${REPORT}
		fi
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.2.5 检查远程 syslog-ng 消息是否仅在指定的日志主机上接收" | tee -a ${REPORT}
if [[ ${syslogngid} -eq 1 ]]; then
	echo -e "\n\tsyslog-ng 未安装，跳过检查。" >> ${REPORT}
else
	if [[ ${sysngconfid} -eq 1 ]]; then
		echo -e "\n\t未检测到任何日志配置。" >> ${REPORT}
	else
		output1=`grep '^source net' /etc/syslog-ng/syslog-ng.conf`
		output2=`grep '^destination remote' /etc/syslog-ng/syslog-ng.conf`
		output3=`grep '^log { source(net)' /etc/syslog-ng/syslog-ng.conf`
		if [[ ${output1} = "" && ${output2} = "" && {output3} = "" ]]; then
			echo -e "\n\t未在本机上配置接收远程 syslog-ng 消息。" >> ${REPORT}
		else
			echo -e "\n\t已在本机上配置接收远程 syslog-ng 消息。" >> ${REPORT}
		fi
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.3 检查 rsyslog 或 syslog-ng 是否已安装" | tee -a ${REPORT}
if [[ ${rsyslogid} -eq 1 ]]; then
	echo -e "\n\trsyslog 未安装。" >> ${REPORT}
else
	echo -e "\n\trsyslog 已安装。" >> ${REPORT}
fi
if [[ ${syslogngid} -eq 1 ]]; then
	echo -e "\n\tsyslog-ng 未安装。" >> ${REPORT}
else
	echo -e "\n\tsyslog-ng 已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2.4 检查所有日志文件的权限是否已配置" | tee -a ${REPORT}
output=`find /var/log -type f \( -perm -640 -a ! -perm 640 \) | wc -l`
if [[ ${output} -eq 0 ]]; then
	echo -e "\n\t所有日志文件的权限均已配置。" >> ${REPORT}
else
	echo -e "\n\t以下日志文件的权限未按建议配置：" >> ${REPORT}
	find /var/log -type f \( -perm -640 -a ! -perm 640 \) -ls | awk '{print $3"\t"$11}' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.3 检查 logrotate 是否已配置" | tee -a ${REPORT}
grep -v '#' /etc/logrotate.conf /etc/logrotate.d/* &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未检测到任何 logrotate 配置。" >> ${REPORT}
else
	echo -e "\n\tlogrotate 配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/logrotate.conf:" >> ${REPORT}
	grep -v '#' /etc/logrotate.conf | sed -e '/^$/d;s/^/\t/g' >> ${REPORT}
	for file in `ls /etc/logrotate.d`; do
		echo -e "\n\t/etc/logrotate.d/${file}:" >> ${REPORT}
		grep -v '#' /etc/logrotate.d/${file} | sed -e '/^$/d;s/^/\t/g' >> ${REPORT}
	done
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "5 访问、认证和授权" | tee -a ${REPORT}
echo "5.1 配置 cron"
echo -n "5.1.1 检查 cron 守护进程是否已启用" | tee -a ${REPORT}
systemctl is-enabled crond &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tcron 守护进程未启用。" >> ${REPORT}
else
	echo -e "\n\tcron 守护进程已启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.1.2 检查 /etc/crontab 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/crontab`
if [[ ${perm} != "600/-rw-------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/crontab 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/crontab | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/crontab 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.1.3 检查 /etc/cron.hourly 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/cron.hourly`
if [[ ${perm} != "700/drwx------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/cron.hourly 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/cron.hourly | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/cron.hourly 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.1.4 检查 /etc/cron.daily 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/cron.daily`
if [[ ${perm} != "700/drwx------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/cron.daily 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/cron.daily | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/cron.daily 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.1.5 检查 /etc/cron.weekly 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/cron.weekly`
if [[ ${perm} != "700/drwx------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/cron.weekly 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/cron.weekly | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/cron.weekly 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.1.6 检查 /etc/cron.monthly 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/cron.monthly`
if [[ ${perm} != "700/drwx------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/cron.monthly 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/cron.monthly | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/cron.monthly 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.1.7 检查 /etc/cron.d 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/cron.d`
if [[ ${perm} != "700/drwx------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/cron.d 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/cron.d | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/cron.d 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.1.8 检查 at/cron 是否仅限授权用户使用" | tee -a ${REPORT}
if [[ -f /etc/at.deny ]]; then
	echo -e "\n\t检测到文件 /etc/at.deny。" >> ${REPORT}
fi
if [[ -f /etc/cron.deny ]]; then
	echo -e "\n\t检测到文件 /etc/cron.deny。" >> ${REPORT}
fi

if [[ ! -f /etc/at.allow ]]; then
	echo -e "\n\tcron 未配置为仅限授权用户使用 (/etc/at.allow 文件不存在)。" >> ${REPORT}
else
	perm=`stat -c %a/%A/%u/%U/%g/%G /etc/at.allow`
	if [[ ${perm} != "600/-rw-------/0/root/0/root" ]]; then
		echo -e "\n\tat 未配置为仅限授权用户使用，当前权限如下：" >> ${REPORT}
		stat /etc/at.allow | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
	else
		echo -e "\n\tat 已配置为仅限授权用户使用。" >> ${REPORT}
	fi
fi
if [[ ! -f /etc/cron.allow ]]; then
	echo -e "\n\tcron 未配置为仅限授权用户使用 (/etc/cron.allow 文件不存在)。" >> ${REPORT}
else
	perm=`stat -c %a/%A/%u/%U/%g/%G /etc/cron.allow`
	if [[ ${perm} != "600/-rw-------/0/root/0/root" ]]; then
		echo -e "\n\tcron 未配置为仅限授权用户使用，当前权限如下：" >> ${REPORT}
		stat /etc/cron.allow | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
	else
		echo -e "\n\tcron 已配置为仅限授权用户使用。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "5.2 SSH 服务配置"
echo -n "5.2.1 检查 /etc/ssh/sshd_config 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/ssh/sshd_config`
if [[ ${perm} != "600/-rw-------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/ssh/sshd_config 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/sshd_config | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/ssh/sshd_config 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.2 检查 SSH Protocol 是否设置为 2" | tee -a ${REPORT}
egrep '^Protocol\s+2' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH Protocol 未设置为 2。" >> ${REPORT}
else
	echo -e "\n\tSSH Protocol 已设置为 2。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.3 检查 SSH LogLevel 是否设置为 INFO" | tee -a ${REPORT}
egrep '^LogLevel\s+INFO' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH LogLevel 未设置为 INFO。" >> ${REPORT}
else
	echo -e "\n\tSSH LogLevel 已设置为 INFO。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.4 检查 SSH X11 forwarding 是否已禁用" | tee -a ${REPORT}
egrep '^X11Forwarding\s+no' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH X11 forwarding 未禁用。" >> ${REPORT}
else
	echo -e "\n\tSSH X11 forwarding 已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.5 检查 SSH MaxAuthTries 是否设置为 4 或更低" | tee -a ${REPORT}
egrep '^MaxAuthTries\s+\b[0-4]\b' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH MaxAuthTries 未设置为 4 或更低。" >> ${REPORT}
else
	echo -e "\n\tSSH MaxAuthTries 已设置为 4 或更低。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.6 检查 SSH IgnoreRhosts 是否已启用" | tee -a ${REPORT}
egrep '^IgnoreRhosts\s+yes' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH IgnoreRhosts 未启用。" >> ${REPORT}
else
	echo -e "\n\tSSH IgnoreRhosts 已启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.7 检查 SSH HostbasedAuthentication 是否已禁用" | tee -a ${REPORT}
egrep '^HostbasedAuthentication\s+no' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH HostbasedAuthentication 未禁用。" >> ${REPORT}
else
	echo -e "\n\tSSH HostbasedAuthentication 已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.8 检查 SSH root 登录是否已禁用" | tee -a ${REPORT}
egrep '^PermitRootLogin\s+no' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH root 登录未禁用。" >> ${REPORT}
else
	echo -e "\n\tSSH root 登录已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.9 检查 SSH PermitEmptyPasswords 是否已禁用" | tee -a ${REPORT}
egrep '^PermitEmptyPasswords\s+no' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH PermitEmptyPasswords 未禁用。" >> ${REPORT}
else
	echo -e "\n\tSSH PermitEmptyPasswords 已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.10 检查 SSH PermitUserEnvironment 是否已禁用" | tee -a ${REPORT}
egrep '^PermitUserEnvironment\s+no' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH PermitUserEnvironment 未禁用。" >> ${REPORT}
else
	echo -e "\n\tSSH PermitUserEnvironment 已禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.11 检查是否仅使用允许的 MAC 算法" | tee -a ${REPORT}
grep ^MACs /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH 未配置允许的 MAC 算法。" >> ${REPORT}
else
	echo -e "\n\tSSH 被允许使用的 MAC 算法配置如下：" >> ${REPORT}
	grep ^MACs /etc/ssh/sshd_config | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.12 检查 SSH Idle Timeout Interval 是否已配置" | tee -a ${REPORT}
output1=`egrep '^ClientAliveInterval\s+(\b[1-9][0-9]{0,1}\b|\b1[0-9]{2}\b|\b2[0-9]{2}\b|\b300\b)' /etc/ssh/sshd_config`
output2=`egrep '^ClientAliveCountMax\s+\b[0-3]\b' /etc/ssh/sshd_config`
if [[ ${output1} = "" || ${output2} = "" ]]; then
	echo -e "\n\tSSH Idle Timeout Interval 未配置。" >> ${REPORT}
else
	echo -e "\n\tSSH Idle Timeout Interval 已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.13 检查 SSH LoginGraceTime 是否设置为 1 分钟或更低" | tee -a ${REPORT}
egrep '^LoginGraceTime\s+(\b[0-5]{0,1}[0-9]{0,1}\b|\b60\b)' /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH LoginGraceTime 已设置为 1 分钟或更低。" >> ${REPORT}
else
	echo -e "\n\tSSH LoginGraceTime 未设置为 1 分钟或更低。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.14 检查 SSH 访问是否受限" | tee -a ${REPORT}
output1=`grep ^AllowUsers /etc/ssh/sshd_config`
output2=`grep ^AllowGroups /etc/ssh/sshd_config`
output3=`grep ^DenyUsers /etc/ssh/sshd_config`
output4=`grep ^DenyGroups /etc/ssh/sshd_config`
if [[ ${output1} = "" && ${output2} = "" && ${output3} = "" && ${output4} = "" ]]; then
	echo -e "\n\t未配置 SSH 访问限制。" >> ${REPORT}
else
	echo -e "\n\t已配置 SSH 访问限制。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2.15 检查 SSH 警告横幅是否已配置" | tee -a ${REPORT}
grep ^Banner /etc/ssh/sshd_config &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\tSSH 警告横幅未配置。" >> ${REPORT}
else
	echo -e "\n\tSSH 警告横幅已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "5.3 配置 PAM"
echo -n "5.3.1 检查密码创建规则是否已配置" | tee -a ${REPORT}
output1=`grep 'pam_pwquality\.so' /etc/pam.d/password-auth | xargs`
output2=`grep 'pam_pwquality\.so' /etc/pam.d/system-auth | xargs`
output3=`grep '^minlen\s*=\s*(\b1[4-9]\b|\b[2-9][0-9]\b|\b[1-9][0-9]{2,}\b)' /etc/security/pwquality.conf`
output4=`egrep '^dcredit|^lcredit|^ocredit|^ucredit' /etc/security/pwquality.conf`
if [[ ${output1} = "password requisite pam_pwquality.so try_first_pass retry=3" && ${output2} = "password requisite pam_pwquality.so try_first_pass retry=3" && ${output3} != "" && ${output4} != "" ]]; then
	echo -e "\n\t密码创建规则已配置。" >> ${REPORT}
else
	echo -e "\n\t密码创建规则未配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.3.2 检查密码尝试失败锁定是否已配置" | tee -a ${REPORT}
output1=`grep 'pam_faillock\.so' /etc/pam.d/password-auth /etc/pam.d/system-auth`
output2=`grep 'auth \[success=1 default=bad\] pam_unix\.so' /etc/pam.d/password-auth /etc/pam.d/system-auth`
if [[ ${output1} = "" || ${output2} = "" ]]; then
	echo -e "\n\t密码尝试失败锁定未配置。" >> ${REPORT}
else
	echo -e "\n\t密码尝试失败锁定配置信息如下：" >> ${REPORT}
	echo -e "\t/etc/pam.d/password-auth:" >> ${REPORT}
	egrep 'pam_faillock\.so|auth \[success=1 default=bad\] pam_unix\.so' /etc/pam.d/password-auth | sed 's/^/\t/g' >> ${REPORT}
	echo -e "\n\t/etc/pam.d/system-auth:" >> ${REPORT}
	egrep 'pam_faillock.\so|auth \[success=1 default=bad\] pam_unix\.so' /etc/pam.d/system-auth | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.3.3 检查密码重用是否受限" | tee -a ${REPORT}
output1=`egrep '^password\s+sufficient\s+pam_unix\.so' /etc/pam.d/password-auth | egrep 'remember=([5-9]|[0-9]{2,})'`
output1=`egrep '^password\s+sufficient\s+pam_unix\.so' /etc/pam.d/system-auth | egrep 'remember=([5-9]|[0-9]{2,})'`
output1=`egrep '^password\s+required\s+pam_pwhistory\.so' /etc/pam.d/password-auth | egrep 'remember=([5-9]|[0-9]{2,})'`
output1=`egrep '^password\s+required\s+pam_pwhistory\.so' /etc/pam.d/system-auth | egrep 'remember=([5-9]|[0-9]{2,})'`
if [[ ${output1} != "" && ${output2} != "" ]] || [[ ${output3} != "" && ${output4} != "" ]]; then
	echo -e "\n\t已配置密码重用限制。" >> ${REPORT}
else
	echo -e "\n\t未配置密码重用限制。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.3.4 检查密码哈希算法是否为 SHA-512" | tee -a ${REPORT}
output1=`egrep '^password\s+sufficient\s+pam_unix\.so' /etc/pam.d/password-auth | grep sha512`
output2=`egrep '^password\s+sufficient\s+pam_unix\.so' /etc/pam.d/system-auth | grep sha512`
if [[ ${output1} != "" && ${output2} != "" ]]; then
	echo -e "\n\t密码哈希算法已配置为 SHA-512。" >> ${REPORT}
else
	echo -e "\n\t密码哈希算法未配置为 SHA-512。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "5.4 用户帐户和环境"
echo "5.4.1 设置 Shadow Password Suite 参数"
echo -n "5.4.1.1 检查密码有效期是否为 365 天或更短" | tee -a ${REPORT}
egrep '^PASS_MAX_DAYS\s+(\b[0-9]{1,2}\b|\b1[0-9]{2}\b|\b2[0-9]{2}\b|\b3[0-5][0-9]\b|\b36[0-5]\b)' /etc/login.defs &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t密码有效期未配置为 365 天或更短。" >> ${REPORT}
else
	echo -e "\n\t密码有效期已配置为 365 天或更短。" >> ${REPORT}
fi

users=`egrep '^[^:]+:[^\!*]' /etc/shadow | cut -d: -f1`
for user in ${users}; do
	days=`chage --list ${user} | grep Maximum | cut -d: -f2 | xargs`
	if [[ ${days} -gt 365 ]]; then
		echo "${user}: ${days}" >> /tmp/users
	fi
done

if [[ -f /tmp/users ]]; then
	echo -e "\n\t下列用户的最大密码更改间隔未配置为 365 天或更短：" >> ${REPORT}
	cat /tmp/users | sed 's/^/\t/g' >> ${REPORT}
fi
rm -f /tmp/users
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.1.2 检查最小密码更改间隔是否为 7 天或更长" | tee -a ${REPORT}
egrep '^PASS_MIN_DAYS\s+\b[0-6]\b' /etc/login.defs &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t未将 /etc/login.defs 中最小密码更改间隔配置为 7 天或更长。" >> ${REPORT}
else
	echo -e "\n\t已将 /etc/login.defs 中最小密码更改间隔配置为 7 天或更长。" >> ${REPORT}
fi

for user in ${users}; do
	days=`chage --list ${user} | grep Minimum | cut -d: -f2 | xargs`
	if [[ ${days} -lt 7 ]]; then
		echo "${user}: ${days}" >> /tmp/users
	fi
done

if [[ -f /tmp/users ]]; then
	echo -e "\n\t下列用户的最小密码更改间隔未配置为 7 天或更长：" >> ${REPORT}
	cat /tmp/users | sed 's/^/\t/g' >> ${REPORT}
fi
rm -f /tmp/users
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.1.3 检查密码过期告警时间是否为 7 天或更长" | tee -a ${REPORT}
egrep '^PASS_WARN_AGE\s+\b[0-6]\b' /etc/login.defs &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t未将 /etc/login.defs 中密码过期告警时间配置为 7 天或更长。" >> ${REPORT}
else
	echo -e "\n\t已将 /etc/login.defs 中密码过期告警时间配置为 7 天或更长。" >> ${REPORT}
fi

for user in ${users}; do
	days=`chage --list ${user} | grep warning | cut -d: -f2 | xargs`
	if [[ ${days} -lt 7 ]]; then
		echo "${user}: ${days}" >> /tmp/users
	fi
done

if [[ -f /tmp/users ]]; then
	echo -e "\n\t下列用户的密码过期告警时间未配置为 7 天或更长：" >> ${REPORT}
	cat /tmp/users | sed 's/^/\t/g' >> ${REPORT}
fi
rm -f /tmp/users
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.1.4 检查失效密码锁定是否为 30 天或更短" | tee -a ${REPORT}
output=`useradd -D | grep INACTIVE | cut -d "=" -f2`
if [[ ${output} -gt 30 ]]; then
	echo -e "\n\t失效密码锁定未配置为 30 天或更短。" >> ${REPORT}
else
	echo -e "\n\t失效密码锁定已配置为 30 天或更短。" >> ${REPORT}
fi

for user in ${users}; do
	days=`chage --list ${user} | grep inactive | cut -d: -f2 | xargs`
	if [[ ${days} = "nerver" || ${days} -gt 30 ]]; then
		echo "${user}: ${days}" >> /tmp/users
	fi
done

if [[ -f /tmp/users ]]; then
	echo -e "\n\t下列用户的密码失效时间未配置为 30 天或更短：" >> ${REPORT}
	cat /tmp/users | sed 's/^/\t/g' >> ${REPORT}
fi
rm -f /tmp/users
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.1.5 检查是否所有用户的最后密码修改日期都在过去" | tee -a ${REPORT}
for user in ${users}; do
	date=`chage --list ${user} | grep Last | cut -d: -f2 | sed 's/^[ \t]*//g'`
	if [[ ${date} != "never" ]]; then
		time=`date -d "$date" +%s`
		now=`date +%s`
		if [[ ${time} -gt ${now} ]]; then
			echo "${user}: ${date}" >> /tmp/users
		fi
	fi
done

if [[ -f /tmp/users ]]; then
	echo -e "\n\t下列用户的最后密码修改日期不在过去：" >> ${REPORT}
	cat /tmp/users | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t所有用户的最后密码修改日期都在过去。" >> ${REPORT}
fi
rm -f /tmp/users
unset user
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.2 检查系统账号是否为 non-login" | tee -a ${REPORT}
output=`grep -v ^+ /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/sbin/nologin" && $7!="/bin/false") {print}'`
if [[ ${output} = "" ]]; then
	echo -e "\n\t系统账号均为 non-login。" >> ${REPORT}
else
	echo -e "\n\t下列系统账号非 non-login：" >> ${REPORT}
	grep -v ^+ /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/sbin/nologin" && $7!="/bin/false") {print}' | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.3 检查 root 的默认组是否为 GID 0" | tee -a ${REPORT}
output=`grep ^root: /etc/passwd | cut -f4 -d:`
if [[ ${output} -eq 0 ]]; then
	echo -e "\n\troot 的默认组为 GID 0。" >> ${REPORT}
else
	echo -e "\n\troot 的默认组为 GID ${output}，非 GID 0。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.4 检查默认 umask 是否为 027 或更高限制" | tee -a ${REPORT}
grep -v '#' /etc/bashrc /etc/profile /etc/profile.d/*.sh | grep umask | sed 's/\s\+umask\s\+/umask:/' | awk -F: '{print $1 " " $3}' | while read file umask; do
if [[ ${umask} -lt 027 ]]; then
echo -e "\t${file}" >> /tmp/files
fi
done

if [[ -f /tmp/files ]]; then
	echo -e "\n\t下列文件中的 umask 未配置为 027 或更高限制：" >> ${REPORT}
	cat /tmp/files | uniq >> ${REPORT}
else
	echo -e "\n\t默认 umask 已配置为 027 或更高限制。" >> ${REPORT}
fi
rm -f /tmp/files
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4.5 检查默认 shell 超时时间是否为 900 秒或更短" | tee -a ${REPORT}
grep ^TMOUT /etc/bashrc &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t/etc/bashrc 中未配置默认 shell 超时时间，跳过检查。" >> ${REPORT}
else
	output=`grep ^TMOUT /etc/bashrc | cut -d "=" -f2`
	if [[ ${output} -le 900 ]]; then
		echo -e "\n\t/etc/bashrc 中默认 shell 超时时间已配置为 900 秒或更短。" >> ${REPORT}
	else
		echo -e "\n\t/etc/bashrc 中默认 shell 超时时间未配置为 900 秒或更短。" >> ${REPORT}
	fi
fi
grep ^TMOUT /etc/profile &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t/etc/profile 中未配置默认 shell 超时时间，跳过检查。" >> ${REPORT}
else
	output=`grep ^TMOUT /etc/profile | cut -d "=" -f2`
	if [[ ${output} -le 900 ]]; then
		echo -e "\n\t/etc/profile 中默认 shell 超时时间已配置为 900 秒或更短。" >> ${REPORT}
	else
		echo -e "\n\t/etc/profile 中默认 shell 超时时间未配置为 900 秒或更短。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.5 检查 root 是否仅限系统控制台登录" | tee -a ${REPORT}
echo -e "\n\t/etc/securetty 中列出的控制台信息如下，请手动检查是否存在不安全的控制台设备：" >> ${REPORT}
cat /etc/securetty | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.6 检查是否限制 su 命令访问" | tee -a ${REPORT}
grep 'pam_wheel\.so' /etc/pam.d/su | grep required | grep -v '#' &> /dev/null
if [[ $? -ne 0 ]]; then
	echo -e "\n\t未限制 su 命令访问。" >> ${REPORT}
else
	echo -e "\n\t已限制 su 命令访问。" >> ${REPORT}
fi

output=`grep wheel /etc/group | cut -d: -f4`
if [[ ${output} != "" ]]; then
	echo "wheel 组存在下列用户：" >> ${REPORT}
	echo ${output} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "6 系统维护" | tee -a ${REPORT}
echo "6.1 系统文件权限"
echo -n "6.1.1 审计系统文件权限" | tee -a ${REPORT}
rpm -Va --nomtime --nosize --nomd5 --nolinkto > /tmp/audit
if [[ -s /tmp/audit ]]; then
	echo -e "\n\t下列系统文件权限异常：" >> ${REPORT}
	cat /tmp/audit | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t系统文件无异常。" >> ${REPORT}
fi
rm -f /tmp/audit
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.2 检查 /etc/passwd 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/passwd`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/passwd 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/passwd | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/passwd 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.3 检查 /etc/shadow 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/shadow`
if [[ ${perm} != "000/----------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/shadow 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/shadow | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/shadow 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.4 检查 /etc/group 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/group`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/group 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/group | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/group 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.5 检查 /etc/gshadow 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/gshadow`
if [[ ${perm} != "000/----------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/gshadow 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/gshadow | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/gshadow 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.6 检查 /etc/passwd- 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/passwd-`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/passwd- 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/passwd- | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/passwd- 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.7 检查 /etc/shadow- 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/shadow-`
if [[ ${perm} != "000/----------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/shadow- 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/shadow- | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/shadow- 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.8 检查 /etc/group- 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/group-`
if [[ ${perm} != "644/-rw-r--r--/0/root/0/root" ]]; then
	echo -e "\n\t/etc/group- 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/group- | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/group- 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.9 检查 /etc/gshadow- 的权限是否已配置" | tee -a ${REPORT}
perm=`stat -c %a/%A/%u/%U/%g/%G /etc/gshadow-`
if [[ ${perm} != "000/----------/0/root/0/root" ]]; then
	echo -e "\n\t/etc/gshadow- 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat /etc/gshadow- | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/gshadow- 的权限已配置。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.10 检查是否存在全局可写文件" | tee -a ${REPORT}
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002 > /tmp/wfile
if [[ -s /tmp/wfile ]]; then
	echo -e "\n\t存在下列全局可写文件：" >> ${REPORT}
	cat /tmp/wfile | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t不存在全局可写文件。" >> ${REPORT}
fi
rm -f /tmp/wfile
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.11 检查是否存在无主文件或目录" | tee -a ${REPORT}
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -nouser > /tmp/ufile
if [[ -s /tmp/ufile ]]; then
	echo -e "\n\t存在下列无主文件或目录：" >> ${REPORT}
	cat /tmp/ufile | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t不存在无主文件或目录。" >> ${REPORT}
fi
rm -f /tmp/ufile
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.12 检查是否存在未分组文件或目录" | tee -a ${REPORT}
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -nogroup > /tmp/gfile
if [[ -s /tmp/ufile ]]; then
	echo -e "\n\t存在下列未分组文件或目录：" >> ${REPORT}
	cat /tmp/gfile | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t不存在未分组文件或目录。" >> ${REPORT}
fi
rm -f /tmp/gfile
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.13 审计 SUID 可执行文件" | tee -a ${REPORT}
echo -e "\n\tSUID 可执行文件信息如下：" >> ${REPORT}
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -4000 | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.1.14 审计 SGID 可执行文件" | tee -a ${REPORT}
echo -e "\n\tSGID 可执行文件信息如下：" >> ${REPORT}
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -2000 | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo "6.2 用户和组设置"
echo -n "6.2.1 检查密码字段是否不为空" | tee -a ${REPORT}
output=`cat /etc/shadow | awk -F: '($2 == "") {print $1}'`
if [[ ${output} != "" ]]; then
	echo -e "\n\t下列用户未设置密码：" >> ${REPORT}
	cat /etc/shadow | awk -F: '($2 == "") {print $1}' | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t所有用户均已设置密码。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.2 检查 /etc/passwd 中是否存在遗留的 \"+\" 条目" | tee -a ${REPORT}
grep ^+: /etc/passwd &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/etc/passwd 中存在下列 \"+\" 条目：" >> ${REPORT}
	grep ^+: /etc/passwd | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/passwd 中不存在遗留的 \"+\" 条目。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.3 检查检查 /etc/shadow 中是否存在遗留的 \"+\" 条目" | tee -a ${REPORT}
grep ^+: /etc/shadow &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/etc/shadow 中存在下列 \"+\" 条目：" >> ${REPORT}
	grep ^+: /etc/shadow | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/shadow 中不存在遗留的 \"+\" 条目。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.4 检查检查 /etc/group 中是否存在遗留的 \"+\" 条目" | tee -a ${REPORT}
grep ^+: /etc/group &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t/etc/group 中存在下列 \"+\" 条目：" >> ${REPORT}
	grep ^+: /etc/group | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t/etc/group 中不存在遗留的 \"+\" 条目。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.5 检查 root 是否是唯一的 UID 0 帐户" | tee -a ${REPORT}
cat /etc/passwd | awk -F: '($3 == 0) {print $1}' | grep -v root &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\troot 非唯一的 UID 0 帐户，还存在以下 UID 0 帐户：" >> ${REPORT}
	cat /etc/passwd | awk -F: '($3 == 0) {print $1}' | grep -v root | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\troot 是唯一的 UID 0 帐户。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.6 检查 root PATH 完整性" | tee -a ${REPORT}
echo -e "\n\t当前 PATH 信息：`echo $PATH`" >> ${REPORT}
echo $PATH | egrep '::|:$' &> /dev/null
if [[ $? -eq 0 ]]; then
  echo "PATH 中存在空目录或 PATH 结尾为\":\"。" >> ${REPORT}
fi
p=`echo $PATH | sed -e 's/::/:/g; s/:$//; s/:/ /g'`
set -- $p
while [[ $1 != "" ]]; do
  if [[ $1 = "." ]]; then
	echo -e "\n\tPATH 中存在 \".\"。" >> ${REPORT}
	shift
	continue
  fi
  if [[ -d $1 ]]; then
	dirperm=`ls -ldH $1 | cut -f1 -d" "`
	if [[ `echo ${dirperm} | cut -c6` != "-" ]]; then
	  echo -e "\n\t目录 $1 设置了组可写权限。" >> ${REPORT}
	fi
	if [[ `echo ${dirperm} | cut -c9` != "-" ]]; then
	  echo -e "\n\t目录 $1 设置了其他人可写权限。" >> ${REPORT}
	fi
	dirown=`ls -ldH $1 | awk '{print $3}'`
	if [[ ${dirown} != "root" ]] ; then
	  echo -e "\n\t$1 的属主非 root。" >> ${REPORT}
	fi
  else
	echo -e "\n\t$1 不存在或不是一个目录。" >> ${REPORT}
  fi
  shift
done
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.7 检查所有用户是否都存在家目录" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ ! -d ${dir} ]]; then
echo -e "\t${user}" >> /tmp/output
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户不存在家目录：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t所有用户都存在家目录。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.8 检查用户家目录的权限是否为 750 或更高限制" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ -d ${dir} ]]; then
dirperm=`ls -ld ${dir} | cut -f1 -d" "`
if [[ `echo ${dirperm} | cut -c6` != "-" ]]; then
	echo -e "\t用户 ${user} 的家目录 ${dir} 设置了组可写权限。" >> /tmp/output
fi
if [[ `echo ${dirperm} | cut -c8` != "-" ]]; then
	echo -e "\t用户 ${user} 的家目录 ${dir} 设置了其他人可读权限。" >> /tmp/output
fi
if [[ `echo ${dirperm} | cut -c9` != "-" ]]; then
	echo -e "\t用户 ${user} 的家目录 ${dir} 设置了其他人可写权限。" >> /tmp/output
fi
if [[ `echo ${dirperm} | cut -c10` != "-" ]]; then
	echo -e "\t用户 ${user} 的家目录 ${dir} 设置了其他人可执行权限。" >> /tmp/output
fi
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户家目录的权限存在异常：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t用户家目录的权限均为 750 或更高限制。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.9 检查用户家目录的属主是否为自己" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ -d ${dir} ]]; then
owner=`stat -L -c %U ${dir}`
if [[ ${owner} != ${user} ]]; then
	echo -e "\t用户 ${user} 家目录 ${dir} 的属主为 {owner}。" >> /tmp/output
fi
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户家目录的权限存在异常：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t用户家目录的属主均为自己。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.10 检查用户的 dot files 是否非组可写或全局可写" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ -d ${dir} ]]; then
for file in ${dir}/.[A-Za-z0-9]*; do
if [[ ! -h ${file} && -f ${file} ]]; then
fileperm=`ls -ld ${file} | cut -f1 -d" "`
if [[ `echo ${fileperm} | cut -c6` != "-" ]]; then
echo -e "\t用户 ${user} 家目录 ${dir} 中的 ${file} 文件设置了组可写权限。" >> ${REPORT}
fi
if [[ `echo ${fileperm} | cut -c9` != "-" ]]; then
echo -e "\t用户 ${user} 家目录 ${dir} 中的 ${file} 文件设置了其他人可写权限。" >> ${REPORT}
fi
fi
done
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户的 dotfiles 权限存在异常：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t用户的 dotfiles 均非组可写或全局可写。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.11 检查是否无用户有 .forward 文件" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ -d ${dir} ]]; then
if [[ ! -h ${dir}/.forward && -f ${dir}/.forward ]]; then
echo -e "\t用户 ${user} 有 .forward 文件。" >> /tmp/output
fi
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户有 .forward 文件：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t所有用户均无 .forward 文件。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.12 检查是否无用户有 .netrc 文件" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ -d ${dir} ]]; then
if [[ ! -h ${dir}/.netrc && -f ${dir}/.netrc ]]; then
echo -e "\t用户 ${user} 有 .netrc 文件。" >> /tmp/output
fi
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户有 .netrc 文件：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t所有用户均无 .netrc 文件。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.13 检查用户的 .netrc 文件是否非组访问或全局访问" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ -d ${dir} ]]; then
for file in ${dir}/.netrc; do
if [[ ! -h ${file} && -f ${file} ]]; then
fileperm=`ls -ld ${file} | cut -f1 -d" "`
if [[ `echo ${fileperm} | cut -c5` != "-" ]]; then
echo "用户 ${user} 的 .netrc 文件设置了组可读权限。" >> /tmp/output
fi
if [[ `echo ${fileperm} | cut -c6` != "-" ]]; then
echo "用户 ${user} 的 .netrc 文件设置了组可写权限。" >> /tmp/output
fi
if [[ `echo ${fileperm} | cut -c7` != "-" ]]; then
echo "用户 ${user} 的 .netrc 文件设置了组可执行权限。" >> /tmp/output
fi
if [[ `echo ${fileperm} | cut -c8` != "-" ]]; then
echo "用户 ${user} 的 .netrc 文件设置了其他人可读权限。" >> /tmp/output
fi
if [[ `echo ${fileperm} | cut -c9` != "-" ]]; then
echo "用户 ${user} 的 .netrc 文件设置了其他人可写权限。" >> /tmp/output
fi
if [[ `echo ${fileperm} | cut -c10` != "-" ]]; then
echo "用户 ${user} 的 .netrc 文件设置了其他人可执行权限。" >> /tmp/output
fi
fi
done
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户的 .netrc 文件权限存在异常：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t用户的 .netrc 文件均非组访问或全局访问。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.14 检查是否无用户有 .rhosts 文件" | tee -a ${REPORT}
cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false") {print $1 " " $6}' | while read user dir; do
if [[ -d ${dir} ]]; then
for file in ${dir}/.rhosts; do
if [[ ! -h ${file} && -f ${file} ]]; then
echo -e "\t用户 ${user} 有 .rhosts 文件。" >> /tmp/output
fi
done
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t下列用户有 .rhosts 文件：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t所有用户均无 .rhosts 文件。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.15 检查是否 /etc/passwd 中的所有组都存在于 /etc/group 中" | tee -a ${REPORT}
for group in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
	grep -q -P '^.*?:[^:]*:${group}:' /etc/group
	if [[ $? -ne 0 ]]; then
		echo -e "\t${group}" >> /tmp/group
	fi
done

if [[ -f /tmp/group ]]; then
	echo -e "\n\t/etc/group 中不存在下列组：" >> ${REPORT}
	cat /tmp/group >> ${REPORT}
else
	echo -e "\n\t/etc/passwd 中的所有组都存在于 /etc/group 中。" >> ${REPORT}
fi
rm -f /tmp/group
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.16 检查是否存在重复的 UID" | tee -a ${REPORT}
cat /etc/passwd | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
[[ -z ${x} ]] && break
set -- ${x}
if [[ $1 -gt 1 ]]; then
users=`awk -F: '($3 == n) {print $1}' n=$2 /etc/passwd | xargs`
echo -e "\t重复的 UID：$2 (${users})。" >> /tmp/output
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t存在重复的 UID 如下：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t不存在重复的 UID。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.17 检查是否存在重复的 GID" | tee -a ${REPORT}
cat /etc/group | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
[[ -z ${x} ]] && break
set -- ${x}
if [[ $1 -gt 1 ]]; then
groups=`awk -F: '($3 == n) {print $1}' n=$2 /etc/group | xargs`
echo -e "\t重复的 GID：$2 (${groups})。" >> /tmp/output
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t存在重复的 GID 如下：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t不存在重复的 GID。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.18 检查是否存在重复的用户名" | tee -a ${REPORT}
cat /etc/passwd | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
[[ -z ${x} ]] && break
set -- ${x}
if [[ $1 -gt 1 ]]; then
uids=`awk -F: '($1 == n) {print $3}' n=$2 /etc/passwd | xargs`
echo -e "\t重复的用户名：$2 (${uids})。" >> /tmp/output
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t存在重复的用户名如下：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t不存在重复的用户名。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.2.19 检查是否存在重复的组名" | tee -a ${REPORT}
cat /etc/group | cut -f1 -d":" | sort -n | uniq -c | while read x ; do
[[ -z ${x} ]] && break
set -- ${x}
if [[ $1 -gt 1 ]]; then
gids=`gawk -F: '($1 == n) {print $3}' n=$2 /etc/group | xargs`
echo "重复的组名：$2 (${gids})。" >> /tmp/output
fi
done

if [[ -f /tmp/output ]]; then
	echo -e "\n\t存在重复的组名如下：" >> ${REPORT}
	cat /tmp/output >> ${REPORT}
else
	echo -e "\n\t不存在重复的组名。" >> ${REPORT}
fi
rm -f /tmp/output
echo "..........[OK]"
echo "" >> ${REPORT}
echo "--------------------------------------------------"
echo "执行结束，检测结果已保存至 ${REPORT}。"
echo

export LANG=$LANG_OLD
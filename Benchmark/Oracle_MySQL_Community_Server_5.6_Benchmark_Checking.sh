#!/bin/bash
##
# MySQL 基线检测脚本，基于 CIS_Oracle_MySQL_Community_Server_5.6_Benchmark_v1.1.0
# By l3e0x7b (lyq0x7b@foxmail.com)
# Version: 1.0
##

clear

/usr/bin/id | grep uid=0 &> /dev/null
if [[ $? -ne 0 ]]; then
	echo "当前非 root 登录，请切换至 root 后再执行此脚本！"
	exit
fi

echo -n "请输入 MySQL 管理员用户名：（默认 root）"
read MY_USR
[[ -z ${MY_USR} ]] && MY_USR=root

echo -n "请输入 MySQL 密码："
read -s MY_PWD
echo

if [[ -f /usr/bin/mysql ]]; then
	MY_EXEC=/usr/bin/mysql
else
	echo -n "请输入 mysql 命令路径：（例如 /usr/bin/mysql）"
	read MY_EXEC
fi

cat <<-EOF > ~/.my.cnf
[client]
user=${MY_USR}
password=${MY_PWD}
EOF

${MY_EXEC} -e "quit" &> /dev/null
if [[ $? -ne 0 ]]; then
	echo
	echo "无法连接到 MySQL 数据库，请检查 MySQL 服务是否已启动及用户名或密码是否输入正确！"
	exit
fi

LANG_OLD=${LANG}
export LANG=en_US.UTF-8
REPORT="/tmp/report.`date +%Y%m%d_%H%M%S`"

echo
echo "主机信息" | tee -a ${REPORT}
echo "--------------------------------------------------" | tee -a ${REPORT}
echo "主机名：`hostname`" | tee -a ${REPORT}
echo "主机IP：`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -d"/" -f1`" | tee -a ${REPORT}
echo "系统版本：`uname -a`" | tee -a ${REPORT}
echo "主机时间：`date`" | tee -a ${REPORT}
echo "--------------------------------------------------" | tee -a ${REPORT}

echo
echo "开始执行检测..."
echo "" >> ${REPORT}
echo "检测结果" >> ${REPORT}
echo "--------------------------------------------------" | tee -a ${REPORT}
echo "1 操作系统级配置" | tee -a ${REPORT}
echo -n "1.1 检查是否将数据库放置在非系统分区上" | tee -a ${REPORT}
datadir=`${MY_EXEC} -e "show variables like 'datadir';" | awk '{if (NR!=1) print $2}'`
location=`df -h ${datadir} | awk '{if (NR!=1) print $6}'`
if [[ ${location} =~ /$|/var$|/usr$ ]]; then
	echo -e "\n\t未将数据库 (${datadir}) 放置在非系统分区上。" >> ${REPORT}
else
	echo -e "\n\t已将数据库 (${datadir}) 放置在非系统分区上。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.2 检查是否为 MySQL 守护进程/服务设置了专用的最小特权帐户 (mysql)" | tee -a ${REPORT}
ps -ef | grep '^mysql.*$' &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t已为 MySQL 守护进程/服务设置专用的最小特权帐户 (mysql)。" >> ${REPORT}
else
	echo -e "\n\t未为 MySQL 守护进程/服务设置专用的最小特权帐户 (mysql)。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.3 检查是否已禁用 MySQL 命令历史" | tee -a ${REPORT}
for file in `find /root /home -name ".mysql_history"`; do
	file ${file} | egrep "symbolic link to \`/dev/null'" &> /dev/null
	if [[ $? -ne 0 ]]; then
		echo ${file} >> /tmp/files
	fi
done

if [[ -s /tmp/files ]]; then
	echo -e "\n\t未完全禁用 MySQL 命令历史，以下文件仍可记录 MySQL 历史命令信息：" >> ${REPORT}
	sed 's/^/\t/g' /tmp/files >> ${REPORT}
else
	echo -e "\n\t已禁用 MySQL 命令历史。" >> ${REPORT}
fi
rm -f /tmp/files
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.4 检查 MYSQL_PWD 环境变量是否未使用" | tee -a ${REPORT}
for file in `ls /proc/*/environ`; do
	if [[ -f ${file} ]]; then
		grep MYSQL_PWD ${file} | grep -v grep &> /dev/null
		if [[ $? -eq 0 ]]; then
			echo ${file} >> /tmp/files
		fi
	fi
done

if [[ -s /tmp/files ]]; then
	echo -e "\n\t下列文件包含了 MYSQL_PWD 环境变量：" >> ${REPORT}
	sed 's/^/\t/g' /tmp/files >> ${REPORT}
else
	echo -e "\n\tMYSQL_PWD 环境变量未使用。" >> ${REPORT}
fi
rm -f /tmp/files
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.5 检查是否已禁用交互式登录" | tee -a ${REPORT}
getent passwd mysql | egrep '^.*[/bin/false|/sbin/nologin]$' &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t已禁用交互式登录。" >> ${REPORT}
else
	echo -e "\n\t未禁用交互式登录。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "1.6 检查是否未在用户环境变量文件中设置 MYSQL_PWD" | tee -a ${REPORT}
for dir in `ls /home`; do
	for file in /home/${dir}/.{bashrc,profile,bash_profile}; do
		if [[ -f ${file} ]]; then
			grep MYSQL_PWD ${file} &> /dev/null
			if [[ $? -eq 0 ]]; then
				echo ${file} >> /tmp/files
			fi
		fi
	done
done

if [[ -s /tmp/files ]]; then
		echo -e "\n\t以下用户环境变量文件中设置了 MYSQL_PWD：" >> ${REPORT}
		sed 's/^/\t/g' /tmp/files >> ${REPORT}
else
		echo -e "\n\t未在用户环境变量文件中设置 MYSQL_PWD。" >> ${REPORT}
fi
rm -f /tmp/files
echo "..........[OK]"
echo "" >> ${REPORT}

echo "2 安装与规划 (手动检查)" | tee -a ${REPORT}
echo "2.1 备份与灾难恢复" | tee -a ${REPORT}
echo -n "2.1.1 检查是否配置了备份策略" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否配置了备份策略。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.1.2 检查备份文件是否完好" | tee -a ${REPORT}
echo -e "\n\t请手动检查备份文件是否完好。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.1.3 检查是否有安全的备份凭证" | tee -a ${REPORT}
echo -e "\n\t请手动检查备份文件是否完好。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.1.4 检查备份是否得到妥善保护" | tee -a ${REPORT}
echo -e "\n\t请手动检查备份是否得到妥善保护。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.1.5 检查是否有还原点恢复" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否有还原点恢复。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.1.6 检查是否有灾难恢复计划" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否有灾难恢复计划。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.1.7 检查是否有配置和相关文件的备份" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否有配置和相关文件的备份。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.2 检查是否使用专用服务器运行 MySQL" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否使用专用服务器运行 MySQL。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.3 检查是否未在命令行指定密码" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否未在命令行指定密码。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.4 检查是否未重用用户名" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否未重用用户名。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo -n "2.5 检查是否未使用默认的或非 MySQL 特定的加密密钥" | tee -a ${REPORT}
echo -e "\n\t请手动检查是否未重用用户名。" >> ${REPORT}
echo "..........[SKIP]"
echo "" >> ${REPORT}

echo "3 文件系统权限" | tee -a ${REPORT}
echo -n "3.1 检查数据库目录是否有适当的权限" | tee -a ${REPORT}
perm=`stat -c %a/%U/%G ${datadir}`
if [[ ${perm} != "700/mysql/mysql" ]]; then
	echo -e "\n\t数据库目录 (${datadir}) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat ${datadir} | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t数据库目录 (${datadir}) 有适当的权限。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.2 检查二进制日志文件是否有适当的权限" | tee -a ${REPORT}
binlog_base=`${MY_EXEC} -e "show variables like 'log_bin_basename';" | awk '{if (NR!=1) print $2}'`
if [[ ${binlog_base} = "" ]]; then
	binlogid=1
	echo -e "\n\t二进制日志未启用，跳过检查。" >> ${REPORT}
else
	binlogid=0
	for binlog in ${binlog_base}.*; do
		perm=`stat -c %a/%U/%G ${binlog}`
		if [[ ${perm} != "660/mysql/mysql" ]]; then
			echo ${binlog} >> /tmp/binlog
		fi
	done
fi

if [[ -s /tmp/binlog ]]; then
		echo -e "\n\t下列二进制日志文件的权限未按建议配置：" >> ${REPORT}
		sed 's/^/\t/g' /tmp/binlog >> ${REPORT}
else
		echo -e "\n\t二进制日志文件有适当的权限。" >> ${REPORT}
fi
rm -f /tmp/binlog
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.3 检查错误日志是否有适当的权限" | tee -a ${REPORT}
errlog=`${MY_EXEC} -e "show variables like 'log_error';" | awk '{if (NR!=1) print $2}'`
if [[ ${errlog} = "" ]]; then
	errlogid=1
	echo -e "\n\t错误日志未启用，跳过检查。" >> ${REPORT}
else
	errlogid=0
	perm=`stat -c %a/%U/%G ${errlog}`
	if [[ ${perm} != "660/mysql/mysql" ]]; then
		echo -e "\n\t错误日志 (${errlog}) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
		stat ${errlog} | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
	else
		echo -e "\n\t错误日志 (${errlog}) 有适当的权限。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.4 检查慢查询日志是否有适当的权限" | tee -a ${REPORT}
slowlog_stat=`${MY_EXEC} -e "show variables like 'slow_query_log';" | awk '{if (NR!=1) print $2}'`
if [[ ${slowlog_stat} = "OFF" ]]; then
	slowlogid=1
	echo -e "\n\t慢查询日志未启用，跳过检查。" >> ${REPORT}
else
	slowlogid=0
	slowlog=`${MY_EXEC} -e "show variables like 'slow_query_log_file';" | awk '{if (NR!=1) print $2}'`
	perm=`stat -c %a/%U/%G ${slowlog}`
	if [[ ${perm} != "660/mysql/mysql" ]]; then
		echo -e "\n\t慢查询日志 (${slowlog}) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
		stat ${slowlog} | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
	else
		echo -e "\n\t慢查询日志 (${slowlog}) 有适当的权限。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.5 检查中继日志文件是否有适当的权限" | tee -a ${REPORT}
relaylog_base=`${MY_EXEC} -e "show variables like 'relay_log_basename';" | awk '{if (NR!=1) print $2}'`
if [[ ${relaylog_base} = "" ]]; then
	relaylogid=1
	echo -e "\n\t未配置中继日志，跳过检查。" >> ${REPORT}
else
	relaylogid=0
	count=`ls ${relaylog_base}.* 2> /dev/null | wc -l`
	if [[ ${count} -eq 0 ]]; then
		echo -e "\n\t无中继日志，跳过检查。" >> ${REPORT}
	else
		for relaylog in ${relaylog_base}.*; do
			perm=`stat -c %a/%U/%G ${relaylog}`
			if [[ ${perm} != "660/mysql/mysql" ]]; then
				echo ${relaylog} >> /tmp/relaylog
			fi
		done

		if [[ -s /tmp/relaylog ]]; then
			echo -e "\n\t下列中继日志文件的权限未按建议配置：" >> ${REPORT}
			sed 's/^/\t/g' /tmp/relaylog >> ${REPORT}
		else
			echo -e "\n\t中继日志文件有适当的权限。" >> ${REPORT}
		fi
		rm -f /tmp/relaylog
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.6 检查普通查询日志是否有适当的权限" | tee -a ${REPORT}
genlog_stat=`${MY_EXEC} -e "show variables like 'general_log';" | awk '{if (NR!=1) print $2}'`
if [[ ${genlog_stat} = "OFF" ]]; then
	genlogid=1
	echo -e "\n\t普通查询日志未启用，跳过检查。" >> ${REPORT}
else
	genlogid=0
	genlog=`${MY_EXEC} -e "show variables like 'general_log_file';" | awk '{if (NR!=1) print $2}'`
	perm=`stat -c %a/%U/%G ${genlog}`
	if [[ ${perm} != "660/mysql/mysql" ]]; then
		echo -e "\n\t普通查询日志 (${genlog}) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
		stat ${genlog} | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
	else
		echo -e "\n\t普通查询日志 (${genlog}) 有适当的权限。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.7 检查 SSL Key 文件是否有适当的权限" | tee -a ${REPORT}
sslkey=`${MY_EXEC} -e "show variables like 'ssl_key';" | awk '{if (NR!=1) print $2}'`
if [[ ${sslkey} = "" ]]; then
	echo -e "\n\t未配置SSL Key，跳过检查。" >> ${REPORT}
else
	perm=`stat -c %a/%U/%G ${sslkey}`
	if [[ ${perm} != "400/mysql/mysql" ]]; then
		echo -e "\n\tSSL Key 文件 (${sslkey}) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
		stat ${sslkey} | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
	else
		echo -e "\n\tSSL Key 文件 (${sslkey}) 有适当的权限。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "3.8 检查插件目录是否有适当的权限" | tee -a ${REPORT}
plugindir=`${MY_EXEC} -e "show variables like 'plugin_dir';" | awk '{if (NR!=1) print $2}'`
perm=`stat -c %a/%U/%G ${plugindir}`
if [[ ${perm} =~ '775/mysql/mysql'|'755/mysql/mysql' ]]; then
	echo -e "\n\t插件目录 (${plugindir}) 有适当的权限。" >> ${REPORT}
else
	echo -e "\n\t插件目录 (${plugindir}) 的权限未按建议配置，当前权限如下：" >> ${REPORT}
	stat ${plugindir} | grep Access | head -n1 | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "4 通用" | tee -a ${REPORT}
echo -n "4.1 检查是否应用了最新的安全补丁" | tee -a ${REPORT}
ver=`${MY_EXEC} -e "show variables like 'version';" | awk '{if (NR!=1) print $2}'`
ver_latest=`curl -s --connect-timeout 10 --retry 0 https://dev.mysql.com/downloads/mysql/5.6.html#downloads | grep '<h1>MySQL Community Server' | sed -e 's/.*Server //; s/ <\/h1>//'`
if [[ ${ver_latest} = "" ]]; then
	echo -e "\n\t当前 MySQL 数据库版本：${ver}，最新版本：（获取失败）。" >> ${REPORT}
else
	echo -e "\n\t当前 MySQL 数据库版本：${ver}，最新版本：${ver_latest}。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.2 检查 test 数据库是否未安装" | tee -a ${REPORT}
testdb=`${MY_EXEC} -e "show databases like 'test';" | awk '{if (NR!=1) print}'`
if [[ ${testdb} = "" ]]; then
	echo -e "\n\ttest 数据库未安装。" >> ${REPORT}
else
	echo -e "\n\ttest 数据库已安装。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.3 检查 allow-suspicious-udfs 选项是否已设置为 FALSE" | tee -a ${REPORT}
ps -ef | grep -v grep | grep mysqld | grep allow-suspicious-udfs &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tmysqld 启动命令行中使用了 --allow-suspicious-udfs 选项。" >> ${REPORT}
else
	echo -e "\n\tmysqld 启动命令行中未使用 --allow-suspicious-udfs 选项。" >> ${REPORT}
fi

my_print_defaults mysqld | grep allow-suspicious-udfs=ON &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tallow-suspicious-udfs 选项未设置为 FALSE。" >> ${REPORT}
else
	echo -e "\n\tallow-suspicious-udfs 选项已设置为 FALSE。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.4 检查 local_infile 是否已禁用" | tee -a ${REPORT}
local_infile=`${MY_EXEC} -e "show variables like 'local_infile';" | awk '{if (NR!=1) print $2}'`
if [[ ${local_infile} = "OFF" ]]; then
	echo -e "\n\tlocal_infile 已禁用。" >> ${REPORT}
else
	echo -e "\n\tlocal_infile 未禁用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.5 检查 mysqld 启动时是否不带 --skip-grant-tables 选项" | tee -a ${REPORT}
ps -ef | grep -v grep | grep mysqld | grep skip-grant-tables &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tmysqld 启动命令行中使用了 --skip-grant-tables 选项。" >> ${REPORT}
else
	echo -e "\n\tmysqld 启动命令行中未使用 --skip-grant-tables 选项。" >> ${REPORT}
fi

my_print_defaults mysqld | grep skip-grant-tables=ON &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tskip-grant-tables 选项未设置为 FALSE。" >> ${REPORT}
else
	echo -e "\n\tskip-grant-tables 选项已设置为 FALSE。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.6 检查 --skip-symbolic-links 选项是否已启用" | tee -a ${REPORT}
symlink=`${MY_EXEC} -e "show variables like 'have_symlink';" | awk '{if (NR!=1) print $2}'`
if [[ ${symlink} = "DISABLED" ]]; then
	echo -e "\n\t--skip-symbolic-links 选项已启用。" >> ${REPORT}
else
	echo -e "\n\t--skip-symbolic-links 选项未启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.7 检查 daemon_memcached 插件是否已禁用" | tee -a ${REPORT}
dae_mem=`${MY_EXEC} -e "select plugin_status from information_schema.plugins where plugin_name='daemon_memcached';" | awk '{if (NR!=1) print}'`
if [[ ${dae_mem} = "ACTIVE" ]]; then
 	echo -e "\n\tdaemon_memcached 插件未禁用。" >> ${REPORT}
else
	echo -e "\n\tdaemon_memcached 插件已禁用。" >> ${REPORT}
fi 
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.8 检查 secure_file_priv 是否不为空" | tee -a ${REPORT}
sec_file_priv=`${MY_EXEC} -e "show variables where variable_name = 'secure_file_priv' and value <> '';"`
if [[ ${sec_file_priv} = "" ]]; then
	echo -e "\n\tsecure_file_priv 为空。" >> ${REPORT}
else
	echo -e "\n\tsecure_file_priv 不为空。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "4.9 检查 sql_mode 是否包含 STRICT_ALL_TABLES" | tee -a ${REPORT}
${MY_EXEC} -e "show variables like 'sql_mode';" | grep STRICT_ALL_TABLES &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tsql_mode 包含 STRICT_ALL_TABLES。" >> ${REPORT}
else
	echo -e "\n\tsql_mode 不包含 STRICT_ALL_TABLES。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "5 MySQL 权限" | tee -a ${REPORT}
echo -n "5.1 检查是否仅管理员用户有 mysql 库的完全访问权限" | tee -a ${REPORT}
global_priv=`${MY_EXEC} -e "select user, host, select_priv, insert_priv, update_priv, delete_priv, create_priv, drop_priv from mysql.user;"`
db_priv=`${MY_EXEC} -e "select user, host, db, select_priv, insert_priv, update_priv, delete_priv, create_priv, drop_priv from mysql.db where db = 'mysql';"`
echo -e "\n\t所有用户的全局权限信息如下：" >> ${REPORT}
printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" ${global_priv} | sed 's/^/\t/g' >> ${REPORT}

if [[ ${db_priv} = "" ]]; then
	echo -e "\n\t可访问 mysql 库的用户权限信息如下：" >> ${REPORT}
	printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" ${global_priv} | sed 's/^/\t/g' >> ${REPORT}
else
	echo -e "\n\t可访问 mysql 库的用户权限信息如下：" >> ${REPORT}
	printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" ${db_priv} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.2 检查 非管理员用户的 file_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -e "\n\tfile_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
${MY_EXEC} -e "select user, host from mysql.user where file_priv = 'Y';" | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.3 检查 非管理员用户的 process_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -e "\n\tprocess_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
${MY_EXEC} -e "select user, host from mysql.user where process_priv = 'Y';" | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.4 检查 非管理员用户的 super_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -e "\n\tsuper_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
${MY_EXEC} -e "select user, host from mysql.user where super_priv = 'Y';" | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.5 检查 非管理员用户的 shutdown_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -e "\n\tshutdown_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
${MY_EXEC} -e "select user, host from mysql.user where shutdown_priv = 'Y';" | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.6 检查 非管理员用户的 create_user_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -e "\n\tcreate_user_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
${MY_EXEC} -e "select user, host from mysql.user where create_user_priv = 'Y';" | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.7 检查 非管理员用户的 grant_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -e "\n\t全局 grant_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
${MY_EXEC} -e "select user, host from mysql.user where grant_priv = 'Y';" | sed 's/^/\t/g' >> ${REPORT}

grant_priv=`${MY_EXEC} -e "select user, host, db from mysql.db where grant_priv = 'Y';"`
if [[ ${grant_priv} != "" ]]; then
	echo -e "\n\t针对指定数据库的 grant_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
	printf "%-10s %-10s %-10s\n" ${db_priv} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.8 检查 Non-Slave 用户的 repl_slave_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -e "\n\trepl_slave_priv 设置为 Y 的用户信息如下：" >> ${REPORT}
${MY_EXEC} -e "select user, host from mysql.user where repl_slave_priv = 'Y';" | sed 's/^/\t/g' >> ${REPORT}
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "5.9 检查 DML/DDL 授权是否仅限于特定数据库和用户" | tee -a ${REPORT}
global_priv=`${MY_EXEC} -e "select user, host, select_priv, insert_priv, update_priv, delete_priv, create_priv, drop_priv, alter_priv from mysql.user;"`
db_priv=`${MY_EXEC} -e "select user, host, db, select_priv, insert_priv, update_priv, delete_priv, create_priv, drop_priv, alter_priv from mysql.db;"`
echo -e "\n\t所有用户的全局 DML/DDL 权限信息如下：" >> ${REPORT}
printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" ${global_priv} | sed 's/^/\t/g' >> ${REPORT}

if [[ ${db_priv} != "" ]]; then
	echo -e "\n\t用户针对指定数据库的 DML/DDL 权限信息如下：" >> ${REPORT}
	printf "%-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" ${db_priv} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "6 审计与记录" | tee -a ${REPORT}
echo -n "6.1 检查 log_error 是否不为空" | tee -a ${REPORT}
if [[ ${errlogid} -eq 0 ]]; then
	echo -e "\n\tlog_error 不为空。" >> ${REPORT}
else
	echo -e "\n\tlog_error 为空。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

# CIS Benchmark 中只要求检查二进制日志文件，此处扩展为检查所有日志文件
echo -n "6.2 检查日志文件是否存储在非系统分区" | tee -a ${REPORT}
if [[ ${binlogid} -eq 1 ]]; then
	echo -e "\n\t二进制日志未启用，跳过检查。" >> ${REPORT}
else
	binlog_loc=`df -h ${binlog_base}.* | awk '{if (NR!=1) print $6}'`
	if [[ ${binlog_loc} =~ /$|/var$|/usr$ ]]; then
		echo -e "\n\t二进制日志文件 (${binlog_base}) 未存储在非系统分区。" >> ${REPORT}
	else
		echo -e "\n\t二进制日志文件 (${binlog_base}) 存储在非系统分区。" >> ${REPORT}
	fi
fi

if [[ ${errlogid} -eq 1 ]]; then
	echo -e "\t错误日志未启用，跳过检查。" >> ${REPORT}
else
	errlog_loc=`df -h ${errlog} | awk '{if (NR!=1) print $6}'`
	if [[ ${errlog} =~ /$|/var$|/usr$ ]]; then
		echo -e "\t错误日志文件 (${errlog}) 未存储在非系统分区。" >> ${REPORT}
	else
		echo -e "\t错误日志文件 (${errlog}) 存储在非系统分区。" >> ${REPORT}
	fi	
fi

if [[ ${slowlogid} -eq 1 ]]; then
	echo -e "\t慢查询日志未启用，跳过检查。" >> ${REPORT}
else
	slowlog_loc=`df -h ${slowlog} | awk '{if (NR!=1) print $6}'`
	if [[ ${slowlog_loc} =~ /$|/var$|/usr$ ]]; then
		echo -e "\t慢查询日志文件 (${slowlog}) 未存储在非系统分区。" >> ${REPORT}
	else
		echo -e "\t慢查询日志文件 (${slowlog}) 存储在非系统分区。" >> ${REPORT}
	fi
fi

if [[ ${relaylogid} -eq 1 ]]; then
	echo -e "\t未配置中继日志，跳过检查。" >> ${REPORT}
else
	relaylog_loc=`df -h ${relaylog_base} | awk '{if (NR!=1) print $6}'`
	if [[ ${relaylog_loc} =~ /$|/var$|/usr$ ]]; then
		echo -e "\t中继日志文件 (${relaylog_base}) 未存储在非系统分区。" >> ${REPORT}
	else
		echo -e "\t中继日志文件 (${relaylog_base}) 存储在非系统分区。" >> ${REPORT}
	fi
fi

if [[ ${genlogid} -eq 1 ]]; then
	echo -e "\t普通查询日志未启用，跳过检查。" >> ${REPORT}
else
	genlog_loc=`df -h ${genlog} | awk '{if (NR!=1) print $6}'`
	if [[ ${genlog_loc} =~ /$|/var$|/usr$ ]]; then
		echo -e "\t普通查询日志文件 (${genlog}) 未存储在非系统分区。" >> ${REPORT}
	else
		echo -e "\t普通查询日志文件 (${genlog}) 存储在非系统分区。" >> ${REPORT}
	fi
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.3 检查 log_warnings 是否已设置为 2" | tee -a ${REPORT}
log_warn=`${MY_EXEC} -e "show variables like 'log_warnings';" | awk '{if (NR!=1) print $2}'`
if [[ ${log_warn} -eq 2 ]]; then
	echo -e "\n\tlog_warnings 已设置为 2。" >> ${REPORT}
else
	echo -e "\n\tlog_warnings 未设置为 2。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.4 检查审计记录是否已启用" | tee -a ${REPORT}
if [[ ${genlogid} -eq 1 ]]; then
	echo -e "\n\t审计记录 (general log) 未启用。" >> ${REPORT}
	echo -e "\n\t若安装了第三方审计记录工具，请手动检查审计记录是否已启用。" >> ${REPORT}
else
	echo -e "\n\t审计记录 (general log) 已启用。" >> ${REPORT}
	echo -e "\n\t若安装了第三方审计记录工具，请手动检查审计记录是否已启用。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "6.5 检查 log-raw 是否已设置为 OFF" | tee -a ${REPORT}
ps -ef | grep -v grep | grep mysqld | grep log-raw &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tmysqld 启动命令行中使用了 --log-raw 选项。" >> ${REPORT}
else
	echo -e "\n\tmysqld 启动命令行中未使用 --log-raw 选项。" >> ${REPORT}
fi

my_print_defaults mysqld | grep log-raw=ON &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tlog-raw 选项未设置为 OFF。" >> ${REPORT}
else
	echo -e "\n\tlog-raw 选项已设置为 OFF。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "7 认证" | tee -a ${REPORT}
echo -n "7.1 检查 old_passwords 是否未设置为 1 或 ON" | tee -a ${REPORT}
old_pass=`${MY_EXEC} -e "show variables like 'old_passwords';" | awk '{if (NR!=1) print $2}'`
if [[ ${old_pass} =~ 0|OFF ]]; then
	echo -e "\n\told_passwords 未设置为 1 或 ON。" >> ${REPORT}
else
	echo -e "\n\told_passwords 已设置为 1 或 ON。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "7.2 检查 secure_auth 是否已设置为 ON" | tee -a ${REPORT}
sec_auth=`${MY_EXEC} -e "show variables like 'secure_auth';" | awk '{if (NR!=1) print $2}'`
if [[ ${sec_auth} = "ON" ]]; then
	echo -e "\n\tsecure_auth 已设置为 ON。" >> ${REPORT}
else
	echo -e "\n\tsecure_auth 未设置为 ON。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "7.3 检查密码是否没有存储在全局配置中" | tee -a ${REPORT}
my_print_defaults client | grep password &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\t密码是否存储在全局配置中。" >> ${REPORT}
else
	echo -e "\n\t密码是否没有存储在全局配置中。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "7.4 检查 sql_mode 是否包含 NO_AUTO_CREATE_USER" | tee -a ${REPORT}
${MY_EXEC} -e "show variables like 'sql_mode';" | grep NO_AUTO_CREATE_USER &> /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\n\tsql_mode 包含 NO_AUTO_CREATE_USER。" >> ${REPORT}
else
	echo -e "\n\tsql_mode 不包含 NO_AUTO_CREATE_USER。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "7.5 检查是否已为所有 MySQL 帐户设置密码" | tee -a ${REPORT}
output=`${MY_EXEC} -e "select user, host from mysql.user where (plugin in('mysql_native_password', 'mysql_old_password', '') and (length(password)=0 or password is null)) or (plugin='sha256_password' and length(authentication_string)=0);"`
if [[ ${output} = "" ]]; then
	echo -e "\n\t已为所有 MySQL 帐户设置密码。" >> ${REPORT}
else
	echo -e "\n\t下列 MySQL 帐户未设置密码：" >> ${REPORT}
	printf "%-10s %-10s\n" ${output} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "7.6 检查密码策略是否配置到位" | tee -a ${REPORT}
valid_pass=`${MY_EXEC} -e "select plugin_status from information_schema.plugins where plugin_name='validate_password';" | awk '{if (NR!=1) print}'`
if [[ ${valid_pass} = "ACTIVE" ]]; then
	pass_len=`${MY_EXEC} -e "show variables like 'validate_password_length';" | awk '{if (NR!=1) print $2}'`
	if [[ ${pass_len} -lt 14 ]]; then
		echo -e "\n\tvalidate_password_length 值未设置为 14 或以上。" >> ${REPORT}
	else
		echo -e "\n\tvalidate_password_length 值已设置为 14 或以上。" >> ${REPORT}
	fi

	pass_mixed_case_count=`${MY_EXEC} -e "show variables like 'validate_password_mixed_case_count';" | awk '{if (NR!=1) print $2}'`
	if [[ ${pass_mixed_case_count} -lt 1 ]]; then
		echo -e "\tvalidate_password_mixed_case_count 值未设置为 1 或以上。" >> ${REPORT}
	else
		echo -e "\tvalidate_password_mixed_case_count 值已设置为 1 或以上。" >> ${REPORT}
	fi

	pass_num_count=`${MY_EXEC} -e "show variables like 'validate_password_number_count';" | awk '{if (NR!=1) print $2}'`
	if [[ ${pass_num_count} -lt 1 ]]; then
		echo -e "\tvalidate_password_number_count 值未设置为 1 或以上。" >> ${REPORT}
	else
		echo -e "\tvalidate_password_number_count 值已设置为 1 或以上。" >> ${REPORT}
	fi

	pass_spec_char_count=`${MY_EXEC} -e "show variables like 'validate_password_special_char_count';" | awk '{if (NR!=1) print $2}'`
	if [[ ${pass_spec_char_count} -lt 1 ]]; then
		echo -e "\tvalidate_password_special_char_count 值未设置为 1 或以上。" >> ${REPORT}
	else
		echo -e "\tvalidate_password_special_char_count 值已设置为 1 或以上。" >> ${REPORT}
	fi

	pass_policy=`${MY_EXEC} -e "show variables like 'validate_password_policy';" | awk '{if (NR!=1) print $2}'`
	if [[ ${pass_policy} =~ MEDIUM|STRONG ]]; then
		echo -e "\tvalidate_password_policy 值已设置为 MEDIUM 或 STRONG。" >> ${REPORT}
	else
		echo -e "\tvalidate_password_policy 值未设置为 MEDIUM 或 STRONG。" >> ${REPORT}
	fi
else
	echo -e "\n\t未配置密码策略 (validate_password 插件未启用)。" >> ${REPORT}
fi 
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "7.7 检查是否没有用户使用通配符主机名" | tee -a ${REPORT}
wildcard_host=`${MY_EXEC} -e "select user, host from mysql.user where host = '%';"`
if [[ ${wildcard_host} = "" ]]; then
	echo -e "\n\t没有用户使用通配符主机名。" >> ${REPORT}
else
	echo -e "\n\t下列用户使用了通配符主机名：" >> ${REPORT}
	printf "%-10s %-10s\n" ${wildcard_host} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "7.8 检查是否不存在匿名帐户" | tee -a ${REPORT}
anonymous=`${MY_EXEC} -e "select user, host from mysql.user where user = '';"`
if [[ ${anonymous} = "" ]]; then
	echo -e "\n\t不存在匿名帐户。" >> ${REPORT}
else
	echo -e "\n\t存在下列匿名帐户：" >> ${REPORT}
	printf "%-10s %-10s\n" ${anonymous} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "8 网络" | tee -a ${REPORT}
echo -n "8.1 检查 have_ssl 是否已设置为 YES" | tee -a ${REPORT}
have_ssl=`${MY_EXEC} -e "show variables like 'have_ssl';" | awk '{if (NR!=1) print $2}'`
if [[ ${have_ssl} = "DISABLED" ]]; then
	ssl_id=1
	echo -e "\n\thave_ssl 值未设置为 YES。" >> ${REPORT}
else
	ssl_id=0
	echo -e "\n\thave_ssl 值已设置为 YES。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "8.2 检查是否所有远程用户的 ssl_type 已设置为 ANY, X509, 或其他指定的加密方法" | tee -a ${REPORT}
ssl_type=`${MY_EXEC} -e "select user, host from mysql.user where host not in ('::1', '127.0.0.1', 'localhost') and ssl_type = '';`
if [[ ${ssl_type} = "" ]]; then
	echo -e "\n\t所有远程用户的 ssl_type 已设置为 ANY, X509, 或其他指定的加密方法。" >> ${REPORT}
else
	echo -e "\n\t下列远程用户的 ssl_type 未设置为 ANY, X509, 或其他指定的加密方法：" >> ${REPORT}
	printf "%-10s %-10s\n" ${ssl_type} | sed 's/^/\t/g' >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo "9 主从复制" | tee -a ${REPORT}
echo -n "9.1 检查主从复制流量是否已得到保护" | tee -a ${REPORT}
if [[ ${ssl_id} -eq 0 ]]; then
	echo -e "\n\t MySQL 的 SSL 功能已启用。" >> ${REPORT}
	echo -e "\n\t请手动检查是否还使用了私有网络、VPN、SSL/TLS 或 SSH 通道等保护主从复制流量。" >> ${REPORT}
else
	echo -e "\n\t MySQL 的 SSL 功能未启用。" >> ${REPORT}
	echo -e "\n\t请手动检查是否还使用了私有网络、VPN、SSL/TLS 或 SSH 通道等保护主从复制流量。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "9.2 检查 master_info_repository 是否已设置为 TABLE" | tee -a ${REPORT}
master_info_repo=`${MY_EXEC} -e "show variables like 'master_info_repository';" | awk '{if (NR!=1) print $2}'`
if [[ ${master_info_repo} != "TABLE" ]]; then
	echo -e "\n\tmaster_info_repository 未设置为 TABLE。" >> ${REPORT}
else
	echo -e "\n\tmaster_info_repository 已设置为 TABLE。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "9.3 检查 MASTER_SSL_VERIFY_SERVER_CERT 是否已设置为 YES 或 1" | tee -a ${REPORT}
ssl_ver_ser_cert=`${MY_EXEC} -e "select ssl_verify_server_cert from mysql.slave_master_info;"`
if [[ ${ssl_ver_ser_cert} =~ YES|1 ]]; then
	echo -e "\n\tMASTER_SSL_VERIFY_SERVER_CERT 已设置为 YES 或 1。" >> ${REPORT}
else
	echo -e "\n\tMASTER_SSL_VERIFY_SERVER_CERT 未设置为 YES 或 1。" >> ${REPORT}
fi
echo "..........[OK]"
echo "" >> ${REPORT}

echo -n "9.4 检查主从复制用户的 super_priv 是否未设置为 Y" | tee -a ${REPORT}
echo -n "9.5 检查是否没有主从复制用户使用通配符主机名" | tee -a ${REPORT}

echo "--------------------------------------------------"
echo "执行结束，检测结果已保存至 ${REPORT}。"
echo

rm -f ~/.my.cnf
export LANG=${LANG_OLD}
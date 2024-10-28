#!/bin/bash

# 数据库名称
database_name="wordpress"
mysql_password="123456"
# 备份文件保存地址
backup_dir="/opt/cloudbackup"
# 备份文件名前缀
backup_prefix="wp"
# 备份文件的有效期，单位为day
backup_days="7"

dd=`date +%Y-%m-%d-%H-%M-%S`
backup_file="$backup_dir/$backup_prefix-$dd.sql"

if [ ! -d $backup_dir ];
then
    mkdir -p $backup_dir;
fi

# 备份
mysqldump -h db -u root -p$mysql_password $database_name > $backup_file

# 还原至 Azure for Mysql 命令
# mysql -h mydemoserver.mysql.database.azure.com -u myadmin@mydemoserver -p testdb < testdb_backup.sql

# 压缩sql文件
# gzip -f $backup_file

# 写创建备份日志
echo "create $backup_dir/$database_name-$dd.dupm" >> $backup_dir/dumplog.txt

# 清除过期的文件
find $backup_dir -name "$backup_prefix*.sql" -mtime +$backup_days -exec rm {} \;
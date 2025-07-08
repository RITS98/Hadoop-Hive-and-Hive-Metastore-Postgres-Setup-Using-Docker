export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export HADOOP_SECURE_DN_USER=""
export HDFS_DATANODE_USER=hdfs
export HDFS_SECONDARYNAMENODE_USER=hdfs
export HDFS_NAMENODE_USER=hdfs
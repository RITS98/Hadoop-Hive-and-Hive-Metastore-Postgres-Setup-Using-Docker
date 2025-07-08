#!/bin/bash
set -e

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH
echo "JAVA_HOME dynamically set to $JAVA_HOME"
java -version


# Start Hadoop (necessary for Hive)
$HADOOP_HOME/sbin/start-dfs.sh

# Initialize the Hive Metastore schema if not already initialized
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
if schematool -dbType postgres -info | grep -q "Schema version"; then
    echo "Hive schema already initialized."
else
    echo "Initializing Hive schema..."
    schematool -dbType postgres -initSchema || echo "Schema already initialized or encountered an error"
fi
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

# Start Hive Metastore
hive --service metastore &

# Start HiveServer2
hive --service hiveserver2
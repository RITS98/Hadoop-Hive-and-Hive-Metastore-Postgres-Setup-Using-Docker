# 🐘 Hadoop + 🐝 Hive + 🛢 PostgreSQL Metastore + 🌈 Hue — Dockerized Setup

This repository provides a **Docker Compose** setup for running a local development stack consisting of:

* 🐘 **Hadoop** (NameNode + DataNode)
* 🐝 **Apache Hive** (with HiveServer2 + Metastore)
* 🛢 **PostgreSQL** (as Hive Metastore)
* 🌈 **Hue** (web UI for Hive and HDFS)

> ⚠️ This setup is **intended for development and testing purposes**. It is **not production-ready**.

---

## ✅ Prerequisites

Before using this setup, ensure you have:

* 🐳 [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed
* 📘 Basic understanding of Docker and Docker Compose
* 📊 Familiarity with Hadoop, Hive, and Hue

---

## 🛠️ Project Structure

```bash
.
├── config/           # XML and config files for Hadoop and Hive
├── downloads/        # Hadoop and Hive tarballs
├── postgres/
│   └── init-hive-metastore.sql
├── scripts/              # Entrypoint scripts for containers
├── hadoop.Dockerfile     # Dockerfile for Hadoop base image
├── hive.Dockerfile       # Dockerfile for Hive image
├── docker-compose.yml    # Multi-service orchestration
└── README.md             
```

---

## 📦 Dockerfile Overview

### 📂 Hadoop Image (`hadoop.Dockerfile`)

#### 🧱 Base Image

```dockerfile
FROM debian:bullseye-slim
```

* Lightweight base for faster builds

#### 📦 Installed Packages

```dockerfile
RUN apt-get update && apt-get install -y \
    ssh openjdk-11-jdk wget unzip vim sudo
```

* Java 11 (required for Hadoop)
* SSH (for HDFS daemons)
* Utilities: `wget`, `vim`, `unzip`, `sudo`

#### 🔐 SSH & Hadoop Setup

```dockerfile
RUN mkdir /var/run/sshd && service ssh start
```

* Enables passwordless SSH for Hadoop daemons

#### 📥 Hadoop Installation

```dockerfile
COPY downloads/hadoop-3.4.0.tar.gz /tmp/
RUN mkdir -p /home/hadoop && \
    tar -xf /tmp/hadoop-3.4.0.tar.gz -C /home/hadoop --strip-components=1 && \
    rm /tmp/hadoop-3.4.0.tar.gz
```

#### 🧪 Java Check

```dockerfile
RUN echo $JAVA_HOME && java -version
```

#### 🛠️ Hadoop Configuration

```dockerfile
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
```

#### 👤 HDFS User

```dockerfile
RUN useradd -m hdfs && chown -R hdfs:hdfs /home/hadoop
```

* Creates `hdfs` user and assigns ownership

#### 🌐 Ports

```dockerfile
EXPOSE 9870 9864 9000
```

* `9870`: NameNode UI
* `9864`: DataNode UI
* `9000`: IPC

---

### 🐝 Hive Image (`hive.Dockerfile`)

#### 🧱 Base Image

```dockerfile
FROM debian:bullseye-slim
```

#### 📦 Installed Packages

```dockerfile
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk wget vim postgresql-client-13 unzip sudo ssh
```

#### 📥 Hadoop & Hive Installation

```dockerfile
COPY downloads/hadoop-3.4.0.tar.gz /tmp/
COPY downloads/apache-hive-4.0.1-bin.tar.gz /tmp/
```

* Installs Hadoop and Hive in `/home/hadoop` and `/home/hive`

#### ⚙️ Environment Setup

```dockerfile
ENV HADOOP_HOME=/home/hadoop
ENV HIVE_HOME=/home/hive
ENV PATH=$HIVE_HOME/bin:$PATH
ENV HIVE_CONF_DIR=$HIVE_HOME/conf
```

#### 🔗 PostgreSQL JDBC

```dockerfile
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.23.jar -P $HIVE_HOME/lib/
```

#### ⚙️ Config Files

```dockerfile
COPY config/hive-site.xml /home/hive/conf/
COPY config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
```

#### 🌐 Ports

```dockerfile
EXPOSE 10000 10002
```

* `10000`: HiveServer2 JDBC
* `10002`: Metastore Thrift

#### 👤 HDFS Ownership

```dockerfile
RUN useradd -m hdfs && chown -R hdfs:hdfs /home/hadoop /home/hive
```

---

## 🐳 Docker Compose Services

This setup defines the following services in `docker-compose.yml`:

| 🧱 Service | 🔎 Description                                                                                                 |
| ---------- | -------------------------------------------------------------------------------------------------------------- |
| `postgres` | PostgreSQL database as Hive Metastore. Ports: `5429:5432`                                                      |
| `pgadmin`  | Web UI for PostgreSQL. Access at [localhost:8079](http://localhost:8079). Default: `admin@admin.com` / `admin` |
| `namenode` | Hadoop HDFS NameNode. Ports: `9870` (UI), `9000` (IPC), `9010` (RPC)                                           |
| `datanode` | Hadoop HDFS DataNode. Port: `9864`                                                                             |
| `hive`     | HiveServer2 with Metastore. Ports: `10000` (JDBC), `10002` (Thrift)                                            |
| `hue`      | Web UI for Hive + HDFS. Access at [localhost:8891](http://localhost:8891)                                      |

### 🌐 Network

All containers are connected via the custom bridge network: `hadoop-network`

---

## 🚀 How to Run

1. **Download Hadoop and Hive tarballs** into the `downloads/` directory:

   * Hadoop 3.4.0: [https://downloads.apache.org/hadoop/common/](https://downloads.apache.org/hadoop/common/)
   * Hive 4.0.1: [https://downloads.apache.org/hive/](https://downloads.apache.org/hive/)

2. **Start the services**:

   ```bash
   docker compose up --build
   ```

3. **Access UIs**:

   * 🧠 HiveServer2: `localhost:10000`
   * 🐘 NameNode UI: `localhost:9870`
   * 💾 DataNode UI: `localhost:9864`
   * 🌈 Hue: [http://localhost:8891](http://localhost:8891)
   * 🛢 pgAdmin: [http://localhost:8079](http://localhost:8079)

---

## 📚 Resources

* [Apache Hadoop](https://hadoop.apache.org/)
* [Apache Hive](https://hive.apache.org/)
* [Hue](https://gethue.com/)
* [PostgreSQL](https://www.postgresql.org/)
* [Docker Compose](https://docs.docker.com/compose/)

---

## Screenshots

### NameNode

<img width="1275" alt="image" src="https://github.com/user-attachments/assets/a5d81be2-f39b-4ea9-91b0-6bdf730fdf09" />

### DataNode

![image](https://github.com/user-attachments/assets/22a67c2b-11e9-4292-b038-e64d5ff2e5a6)

### Hive

<img width="1238" alt="image" src="https://github.com/user-attachments/assets/a53cdcbe-3204-417e-aab4-9cb3eb6c5a86" />

### Hive Metastore (PostgreSQL Admin)

<img width="1704" alt="image" src="https://github.com/user-attachments/assets/baec3f04-d664-4fdf-b823-e55aff7cafaa" />

### Hue

<img width="1261" alt="image" src="https://github.com/user-attachments/assets/8e513af4-4116-47f2-975b-2b2cd7a96db3" />

---







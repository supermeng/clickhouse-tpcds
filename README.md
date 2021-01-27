# clickhouse-tpcds
Some queries of tpcds for Clickhouse 

## install clickhouse
```
export repository="deb http://repo.yandex.ru/clickhouse/deb/stable/ main/"
export version=21.1.2.15
export gosu_ver=1.10
groupadd -r clickhouse --gid=1011 \
    && useradd -r -g clickhouse --uid=1011 --home-dir=/var/lib/clickhouse --shell=/bin/bash clickhouse \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        gnupg \
    && mkdir -p /etc/apt/sources.list.d \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4 \
    && echo $repository > /etc/apt/sources.list.d/clickhouse.list \
    && apt-get update \
    && env DEBIAN_FRONTEND=noninteractive \
        apt-get --yes -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade \
    && env DEBIAN_FRONTEND=noninteractive \
        apt-get install --allow-unauthenticated --yes --no-install-recommends \
            clickhouse-common-static=$version \
            clickhouse-client=$version \
            clickhouse-server=$version \
            locales \
            wget \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
        /tmp/* 
```

## generate data
```
cd /root
sudo apt-get update
sudo apt-get -y install gcc make  flex  bison  byacc git
git clone https://github.com/gregrahn/tpcds-kit.git
cd tpcds-kit/tools
make OS=LINUX

mkdir -p /mnt
cd /mnt
mkdir tpcds-data
cd tpcds-data/
echo "cd /root/tpcds-kit/tools/
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 1 &
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 2 &
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 3 &
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 4 &
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 5 &
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 6 &
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 7 &
./dsdgen -scale 150 -dir /mnt/tpcds-data -parallel 8 -child 8 &" > datagen-ch.sh
chmod +x datagen-ch.sh
```

## move file
```
time(for file in $1*.dat ; do mv "$file" "${file%.*}.csv" ; done)
```

## import data
```
export table_name=catalog_sales
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=call_center
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=date_dim
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=household_demographics
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=store
time (for filename in /mnt/tpcds-data/${table_name}_1_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=customer
time (for filename in /mnt/tpcds-data/${table_name}_1_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=store_sales
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=web_sales
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=customer_demographics
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=promotion
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=customer_address
time (for filename in /mnt/tpcds-data/${table_name}_1_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=catalog_returns
time (for filename in /mnt/tpcds-data/${table_name}_1_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=warehouse
time (for filename in /mnt/tpcds-data/${table_name}_1_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=time_dim
time (for filename in /mnt/tpcds-data/${table_name}_1_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename & done)

export table_name=item
time (for filename in /mnt/tpcds-data/${table_name}*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename; done)

export table_name=store_returns
time (for filename in /mnt/tpcds-data/${table_name}_*.csv; do clickhouse-client --format_csv_delimiter="|" --query="INSERT INTO tpcdsch.${table_name} FORMAT CSV" --max_partitions_per_insert_block=0 --password root < $filename; done)

```
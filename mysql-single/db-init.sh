#!/bin/bash

mysql -uroot -p12345679 -h 192.168.49.2 -P 30306 << EOF
source mysql-single/apolloportaldb.sql;
source mysql-single/apolloconfigdb.sql;
EOF

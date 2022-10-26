#!/bin/bash
# set -x
./compare.sh > remove
for i in `cat remove` ;
do
ipset del tor-ddos $i
done;

#!/bin/bash
# set -x
./compare2.sh > remove2
for i in `cat remove2` ;
do
ipset del tor2-ddos $i
done;

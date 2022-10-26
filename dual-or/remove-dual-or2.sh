#!/bin/bash
# set -x
./compare-dual2.sh > remove-dual2
for i in `cat remove-dual2` ;
do
ipset del tor2-ddos $i
done;

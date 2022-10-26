#!/bin/bash
# set -x
./compare-dual.sh > remove-dual
for i in `cat remove-dual` ;
do
ipset del tor-ddos $i
done;

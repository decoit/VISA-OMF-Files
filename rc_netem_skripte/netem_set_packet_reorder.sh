#!/bin/bash

sudo tc qdisc change dev $1 root netem delay $2ms $3 $4

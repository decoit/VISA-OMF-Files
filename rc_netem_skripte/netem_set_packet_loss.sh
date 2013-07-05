#!/bin/bash

sudo tc qdisc change dev $1 root netem loss $2% $3%

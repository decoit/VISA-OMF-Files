#!/bin/bash

sudo tc qdisc add dev $1 root netem

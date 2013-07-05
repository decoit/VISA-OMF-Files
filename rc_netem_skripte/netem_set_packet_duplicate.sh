#!/bin/bash

sudo tc qdisc change dev $1 root netem duplicate $2

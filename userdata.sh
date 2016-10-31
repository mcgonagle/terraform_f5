#!/bin/bash
touch /tmp/file_terraform_test
tmsh create net vlan external interfaces add { 1.1 { untagged } }
tmsh create net vlan internal interfaces add { 1.2 { untagged } }
tmsh create net self 10.0.1.10 address 10.0.1.10/24 vlan external
tmsh create net self 10.0.2.10 address 10.0.2.10/24 vlan internal
tmsh create net route Default_Gateway network 0.0.0.0/0 gw 10.0.1.1
tmsh save sys config

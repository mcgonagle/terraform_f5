#!/bin/bash
touch /tmp/file_terraform_test
tmsh modify sys global-settings gui-setup disabled
tmsh modify sys global-settings hostname f5-bigip.f5customer.com
tmsh modify sys dns name-servers add { 8.8.4.4 }
tmsh modify sys ntp timezone America/New_York servers add { time.apple.com }
tmsh create net vlan external interfaces add { 1.1 { untagged } }
tmsh create net vlan internal interfaces add { 1.2 { untagged } }
tmsh create net self 10.0.1.10 address 10.0.1.10/24 vlan external
tmsh create net self 10.0.2.10 address 10.0.2.10/24 vlan internal
tmsh create net route Default_Gateway network 0.0.0.0/0 gw 10.0.1.1
tmsh save sys config

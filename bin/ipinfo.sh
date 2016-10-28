#!/bin/sh

result() {
	mawk 'd==0 {printf("RES:%02d %s\n", NR, $0) >"/dev/stderr"} d==1 {print} /^\r$/ {d=1}' | jq
}

nc ipinfo.io 80 << EOF | result
GET / HTTP/1.1
Host: ipinfo.io

EOF

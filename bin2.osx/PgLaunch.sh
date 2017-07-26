#!/bin/bash

PG=/Applications/Postgres.app/Contents/Versions/9.4
DATA="/Users/fm/Library/Application Support/Postgres/var-9.4"
PATH=$PG/bin:$PATH

case $1 in
    startfg)
        $PG/bin/pg_ctl start -D "$DATA"
        sleep $(( 1000*1000*1000 ))
        $PG/bin/pg_ctl stop -D "$DATA" -m fast
        ;;
    start)
        $PG/bin/pg_ctl start -D "$DATA"
        ;;
    status)
        $PG/bin/pg_ctl status -D "$DATA"
        ;;
    stop)
        $PG/bin/pg_ctl stop -D "$DATA" -m fast
        ;;
    reload)
        $PG/bin/pg_ctl reload -D "$DATA"
        ;;
    cleanup)
        rm -i "$DATA"/postmaster.pid
        ;;
    *)
        echo "Usage: $0 startfg|status|reload|stop"
        ;;
esac

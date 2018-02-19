#!/bin/bash

PG=/Applications/Postgres.app/Contents/Versions/9.4
PGNEW=/Applications/Postgres-10/Postgres.app/Contents/Versions/10
DATA="/Users/fm/Library/Application Support/Postgres/var-9.4"
DATANEW="/Users/fm/Library/Application Support/Postgres/var-10"
PATH=$PG/bin:$PATH

if [[ "$2" = old ]] ;then
    DATA="$DATAOLD"
    PG=$PGOLD
elif [[ "$2" = new ]] ;then
    DATA="$DATANEW"
    PG=$PGNEW
fi

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
    init)
        mkdir -p "$DATA"
        $PG/bin/initdb -D "$DATA" --locale=en_US.UTF-8
        ;;
    migrate)
        $PG/bin/pg_upgrade -b $PGOLD/bin -B $PG/bin -d "$DATAOLD" -D "$DATA"
        ;;
    cleanup)
        rm -i "$DATA"/postmaster.pid
        ;;
    *)
        echo "Usage: $0 startfg|status|reload|stop"
        ;;
esac

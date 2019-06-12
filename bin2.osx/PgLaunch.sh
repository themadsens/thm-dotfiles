#!/bin/bash

PGOLD=/Applications/Postgres.app/Contents/Versions/9.4
PG=/Applications/Postgres.10/Postgres.app/Contents/Versions/10/
DATAOLD="/Volumes/JetFlash/Postgres/var-9.4"
DATA="/Volumes/JetFlash/Postgres/var-10"

if [[ "$1" = old ]] ;then
    DATA="$DATAOLD"
    PG=$PGOLD
    shift
elif [[ "$1" = new ]] ;then
    DATA="$DATANEW"
    PG=$PGNEW
    shift
fi
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
    init)
        mkdir -p "$DATA"
        $PG/bin/initdb -D "$DATA" --locale=en_US.UTF-8
        ;;
    migrate)
        $PGNEW/bin/pg_upgrade -b $PG/bin -B $PGNEW/bin -d "$DATA" -D "$DATANEW"
        ;;
    cleanup)
        rm -i "$DATA"/postmaster.pid
        ;;
    pgcmd)
        CMD=$2 ; shift 2
        exec $PG/bin/$CMD "$@"
        ;;
    run)
        shift ; exec "$@"
        ;;
    *)
        echo "Usage: $0 startfg|status|reload|stop|pgcmd"
        ;;
esac

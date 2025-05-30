#!/bin/bash

PGOLD=/Applications/Postgres.app/Contents/Versions/10
DATAOLD="/Volumes/Option/Postgres/var-10"
PGNEW=/Applications/Postgres.app/Contents/Versions/14/
DATANEW="/Volumes/Option/Postgres/var-14"
PG=/Applications/Postgres.app/Contents/Versions/14/
DATA="/Volumes/Option/Postgres/var-14"
if [[ ! -d $PG ]] ;then
    PG=/Applications/Postgres.10/Postgres.app/Contents/Versions/14/
    DATA="/Volumes/ToolChain/Postgres/var-14"
fi

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
        trap '' SIGTERM
        ( trap SIGTERM ; sleep $(( 1000*1000*1000 )) )
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
        if [[ ! -f "$DATA" ]] ;then
            mkdir -p "$DATA"
            $PG/bin/initdb -D "$DATA" --locale=en_US.UTF-8
        fi
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
        echo "Usage: $0 [old|new] startfg|start|status|reload|stop|pgcmd"
        ;;
esac

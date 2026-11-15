#!/bin/bash
set -x

PGOLD=/Applications/Postgres.app/Contents/Versions/14
DATAOLD="/Volumes/Option/Postgres/var-14"
PGNEW=/Applications/Postgres.app/Contents/Versions/16/
DATANEW="/Volumes/Option/Postgres/var-16"
[ -f /opt/wildfly/standalone/configuration/PgVer.rc ] && . /opt/wildfly/standalone/configuration/PgVer.rc
: ${VER:=new}
if [[ "$1" = "old" || "$1" = "new" ]] ;then
  VER=$1
  shift
fi

if [[ "$VER" = old ]] ;then
    DATA="$DATAOLD"
    PG=$PGOLD
elif [[ "$VER" = new ]] ;then
    DATA="$DATANEW"
    PG=$PGNEW
fi
PATH=$PG/bin:$PATH

PGOPTIONS='-c timezone=GMT'

case $1 in
    startfg)
        TZ=utc $PG/bin/pg_ctl start -D "$DATA" -o "$PGOPTIONS"
        echo $$ > /opt/wildfly/standalone/tmp/PgLaunch.pid
        trap '' SIGTERM
        ( trap SIGTERM ; sleep $(( 1000*1000*1000 )) )
        rm -f  /opt/wildfly/standalone/tmp/PgLaunch.pid
        $PG/bin/pg_ctl stop -D "$DATA" -m fast
        ;;
    start)
        $PG/bin/pg_ctl start -D "$DATA" -o "$PGOPTIONS"
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

#!bash
read auth server node
exec </dev/null > /tmp/trace 2>/tmp/trace
set -x
set -o errexit
DIR="$1"
echo "$auth $server $node"

(
curl -k -N -s  -XPOST -H 'content-type: application/json'  -H "authorization: Basic $auth" \
        "https://$server/greenwise/rs/subscription?timeout=95000" \
        -d '{"type": "navigation", "data": {"type": "node", "id": '"$node"'}}' \
    | awk '/"type":"light"/ {print $0; flush}' \
    | while read hunk ;do
        echo "$hunk" > /tmp/light_hunk
    done

$DIR/extensions/hs/ipc/bin/hs -c "spoon.LightAndScroll.respawn()"
) &
$DIR/extensions/hs/ipc/bin/hs -c "spoon.LightAndScroll.setNotifierPid($!)"
exit 0

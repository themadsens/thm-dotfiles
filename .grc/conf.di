# Filesystem         Mount               Size     Used    Avail %Used  fs Type
# /dev/disk1s1       /                 233.6G   160.9G    67.0G   71%  apfs
# drivefs            /Volumes/Google    17.0G     5.5G    11.5G   32%  dfsfuse_DFS
# com.apple.TimeMach /Volumes/com.ap   233.6G   159.5G    67.0G   71%  apfs
# /dev/disk1s4       /private/var/vm   233.6G     5.0G    67.0G   71%  apfs
#
# FS
#regexp=^.*?\s
regexp=^(?!Filesystem).*?\s
colours=green
======
# Size 'K'
regexp=\s\d*[.,]?\dKi?\s
colours=green
======
# Size 'M'
regexp=\s\d*[.,]?\dMi?\s
colours=yellow
======
# Size 'G'
regexp=\s\d*[.,]?\dGi?\s
colours=red
======
# Size 'T'
regexp=\s\d*[.,]?\dTi?\s
colours=bold red
======
# Mounted on
regexp=/[-\w\d./]*$
colours=bold green
======
# Use 0-60%
regexp=[1-6][0-9]?%|0%
colours=green
======
# Use 70-90%
regexp=[7-9][0-9]%
colours=yellow
======
# Use 90-95
regexp=[9][0-5]%
colours=red
======
# Use 95-100
regexp=[9][5-9]%|100%
colours=bold red

# tmpfs lines
regexp=^tmpfs.*
colours=bright_black

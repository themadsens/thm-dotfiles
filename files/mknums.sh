gm convert -font helvetica  -size 64x64 xc:'#ffffffff' -strokewidth 2 -stroke black -fill yellow  -draw 'circle 32,32 32,62' -pointsize 40 -stroke black -fill black -draw 'text 8,45 "16"' 16.png && ql 16.png
gm convert -font helvetica  -size 64x64 xc:'#ffffffff' -strokewidth 2 -stroke black -fill yellow  -draw 'circle 32,32 32,62' -pointsize 40 -stroke black -fill black -draw 'text 8,45 "10"' 10.png && ql 10.png
gm convert -font helvetica  -size 64x64 xc:'#ffffffff' -strokewidth 2 -stroke black -fill yellow  -draw 'circle 32,32 32,62' -pointsize 40 -stroke black -fill black -draw 'text 21,45 "2"' 2.png && ql 2.png
gm convert -font helvetica  -size 64x64 xc:'#ffffffff' -strokewidth 2 -stroke black -fill yellow  -draw 'circle 32,32 32,62' -pointsize 40 -stroke black -fill black -draw 'text 21,45 "8"' 8.png && ql 8.png

gm convert -size 64x64 xc:'#ffffffff' -strokewidth 2 -stroke black -fill yellow -draw 'circle 32,32 32,62' -pointsize 40 -stroke black -fill black -draw 'font-weight 9000 text 26,45 "/"' fr.png && ql fr.png
gm convert -font courier -size 64x64 xc:'#ffffffff' -strokewidth 2 -stroke black -fill yellow -draw 'circle 32,32 32,62' -pointsize 40 -stroke black -fill black -draw 'text 20,44 "/"' -pointsize 20 -draw 'text 14,30 "a"' -draw 'text 39,45 "b"' fr.png && ql fr.png

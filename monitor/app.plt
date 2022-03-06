set term png small size 800,600
set output "app.png"

set ylabel "%CPU"
set y2label "RSS"

set ytics nomirror
set y2tics nomirror in

set yrange [0:*]
set y2range [0:*]

plot "./app.log" using 2 with lines axes x1y1 title "%CPU", \
     "./app.log" using 3 with lines axes x1y2 title "RSS"

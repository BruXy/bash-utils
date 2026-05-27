# http://bruxy.regnet.cz/latex/
# Martin Bruchanov, bruxy at regnet dot cz
#set output "graf-11a.mp"
#set term mp "csr10" 10;
# 
#set size square;
set grid;
set data style points;
set yrange [-2:2];
set format y "$%.1f$";
set xrange [0:15];
set xlabel 'Vzorek $k$ [--]';
set ylabel 'Vstupní napětí $U$ [V]';
#set key left top;
#set samples 2500;
#set xtics ();
plot sin(x);

#plot "" using 1:2 notitle with boxes, \
#     "" using 1:2 smooth csplines notitle 8;

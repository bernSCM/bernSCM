if ! test -f ./output/389ppm_Pulse100GtC_Res0.1yr_D0.1_BernSCM_t_f_CS30.dat
then
    echo "Use run_examples.sh to generate model and example output first!" >/dev/stderr
    exit
fi

xmgrace -printfile ./plots/c_389ppm_Pulse100GtC_Res01yr_D01_BernSCM_t_f_CS30.eps -hdevice EPS -free -noask \
 -pexec 'default font 0' \
-pexec 'title " Airborne fraction (100GtC Pulse on 389ppm)"; LEGEND CHAR SIZE 1 ; yaxis label "Atm. conc. (ppm)" ; yaxis label char size 1.3; xaxis label "Time (yr)"; xaxis label char size 1.3' \
-block ./output/389ppm_Pulse100GtC_Res0.1yr_D0.1_BernSCM_t_f_CS30.dat -bxy 1:8 \
-pexec 's0.y=s0.y*2.123/100 ; autoscale yaxes' \
-pexec 's0.y=s0.y+-389/47' \
-pexec 's0 LEGEND "Resolution 0.1 yr (explicit)" ; legend box pattern 0 ; legend box fill pattern 0 ; s0 linewidth 2; s0 linestyle 1; s0 color 1' \
-block ./output/389ppm_Pulse100GtC_Res1yr_D1I_BernSCM_t_f_CS30.dat -bxy 1:8 \
-pexec 's1.y=s1.y*2.123/100 ; autoscale yaxes' \
-pexec 's1.y=s1.y+-389/47' \
-pexec 's1 LEGEND "Resolution 1 yr (implicit)" ; legend box pattern 0 ; legend box fill pattern 0 ; s1 linewidth 2; s1 linestyle 1; s1 color 2' \
-block ./output/389ppm_Pulse100GtC_Res10yr_D10QI_BernSCM_t_f_CS30.dat -bxy 1:8 \
-pexec 's2.y=s2.y*2.123/100 ; autoscale yaxes' \
-pexec 's2.y=s2.y+-389/47' \
-pexec 's2 LEGEND "Resolution 10 yr (implicit, linear)" ; legend box pattern 0 ; legend box fill pattern 0 ; s2 linewidth 2; s2 linestyle 1; s2 color 3' \
-pexec 'world 2000, 0, 2116, 1 ; autoscale yaxes; autoticks' \
-pexec 'legend loctype world; legend 2040, 0' \
-pexec 'with g0; yaxis label "AF"' \


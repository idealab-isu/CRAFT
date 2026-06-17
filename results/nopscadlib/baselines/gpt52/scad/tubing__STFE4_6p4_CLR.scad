$fn=96;

module ptfe_heatshrink_sleeve(len=60, id=4, wall=0.5, flare=0.6, flare_len=6) {
    od = id + 2*wall;
    od_flare = od + 2*flare;
    id_flare = id + 2*flare*0.6;

    difference() {
        union() {
            cylinder(h=len, d=od, center=true);
            translate([0,0, len/2 - flare_len/2])
                cylinder(h=flare_len, d1=od, d2=od_flare, center=true);
            translate([0,0,-len/2 + flare_len/2])
                cylinder(h=flare_len, d1=od_flare, d2=od, center=true);
        }
        union() {
            cylinder(h=len+0.2, d=id, center=true);
            translate([0,0, len/2 - flare_len/2])
                cylinder(h=flare_len+0.2, d1=id, d2=id_flare, center=true);
            translate([0,0,-len/2 + flare_len/2])
                cylinder(h=flare_len+0.2, d1=id_flare, d2=id, center=true);
        }
    }
}

ptfe_heatshrink_sleeve(len=80, id=6, wall=0.6, flare=0.8, flare_len=8);
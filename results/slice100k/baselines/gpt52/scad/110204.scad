$fn=128;

module spool_like_part(od=10, h=7, flange_t=1.5, waist_od=6, bore_d=3) {
    difference() {
        union() {
            cylinder(d=od, h=flange_t, center=false);
            translate([0,0,h-flange_t]) cylinder(d=od, h=flange_t, center=false);

            translate([0,0,flange_t])
                cylinder(h=(h-2*flange_t)/2, d1=od, d2=waist_od, center=false);

            translate([0,0,h/2])
                cylinder(h=(h-2*flange_t)/2, d1=waist_od, d2=od, center=false);
        }
        translate([0,0,-0.1]) cylinder(d=bore_d, h=h+0.2, center=false);
    }
}

translate([0,0,-7/2]) spool_like_part(od=10, h=7, flange_t=1.5, waist_od=6, bore_d=3);
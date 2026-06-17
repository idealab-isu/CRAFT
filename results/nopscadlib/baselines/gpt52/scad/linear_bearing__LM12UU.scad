$fn=128;

bore_d = 12.0;
od_d = 21.0;
len = 30.0;

seal_recess_depth = 1.0;
seal_recess_len = 2.0;
chamfer_len = 0.8;

module chamfered_ring(od, id, h, chamfer=0.8) {
    difference() {
        union() {
            cylinder(d=od, h=h, center=true);
            translate([0,0,h/2 - chamfer/2])
                cylinder(d1=od, d2=od-2*chamfer, h=chamfer, center=true);
            translate([0,0,-h/2 + chamfer/2])
                cylinder(d1=od-2*chamfer, d2=od, h=chamfer, center=true);
        }
        cylinder(d=id, h=h+2, center=true);
    }
}

module linear_bearing(bore, od, L) {
    difference() {
        chamfered_ring(od=od, id=bore, h=L, chamfer=chamfer_len);

        translate([0,0, L/2 - seal_recess_len/2])
            difference() {
                cylinder(d=od+2, h=seal_recess_len, center=true);
                cylinder(d=od-2*seal_recess_depth, h=seal_recess_len+2, center=true);
            }

        translate([0,0,-L/2 + seal_recess_len/2])
            difference() {
                cylinder(d=od+2, h=seal_recess_len, center=true);
                cylinder(d=od-2*seal_recess_depth, h=seal_recess_len+2, center=true);
            }
    }
}

linear_bearing(bore=bore_d, od=od_d, L=len);
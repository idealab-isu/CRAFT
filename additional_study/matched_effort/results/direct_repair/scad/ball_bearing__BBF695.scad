$fn = 180;

bore_d = 5.0;
od_d = 13.0;
width = 4.0;

flange_d = 15.0;
flange_th = 1.0;

module flanged_bearing(bore_d, od_d, width, flange_d, flange_th) {
    difference() {
        union() {
            cylinder(d=od_d, h=width);
            cylinder(d=flange_d, h=flange_th);
        }
        translate([0,0,-0.1])
            cylinder(d=bore_d, h=width + 0.2);
    }
}

flanged_bearing(bore_d, od_d, width, flange_d, flange_th);
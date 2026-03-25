$fn=96;

bore_d = 3.0;
od_d = 10.0;
width = 4.0;

flange_d = 11.5;
flange_th = 0.8;

race_wall = 1.0;
seal_recess = 0.25;

module ring(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module bearing_body() {
    union() {
        ring(od_d, bore_d, width);
        translate([0,0,(width/2 - flange_th/2)])
            ring(flange_d, od_d, flange_th);
    }
}

module bearing_detail_cuts() {
    union() {
        translate([0,0,(width/2 - seal_recess/2)])
            ring(od_d-0.6, bore_d+0.6, seal_recess);
        translate([0,0,(-width/2 + seal_recess/2)])
            ring(od_d-0.6, bore_d+0.6, seal_recess);

        ring(od_d - 2*race_wall, bore_d + 2*race_wall, width + 0.2);
    }
}

difference() {
    bearing_body();
    bearing_detail_cuts();
}
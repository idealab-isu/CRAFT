$fn=96;

od = 4.0;
len = 6.3;

bore_d = 3.3;          // approximate pilot/bore for M4 screw clearance in insert
lead_in = 0.6;         // chamfer length
chamfer = 0.35;        // radial chamfer amount

knurl_depth = 0.25;    // radial depth of knurl cuts
knurl_pitch = 0.9;     // spacing along Z
knurl_count = 18;      // number of knurl flutes around

module insert_body() {
    union() {
        cylinder(d=od, h=len - 2*lead_in, center=true);
        translate([0,0,(len - 2*lead_in)/2])
            cylinder(h=lead_in, d1=od, d2=od - 2*chamfer, center=false);
        translate([0,0,-(len - 2*lead_in)/2 - lead_in])
            cylinder(h=lead_in, d1=od - 2*chamfer, d2=od, center=false);
    }
}

module knurl_cuts() {
    for (i = [0:knurl_count-1]) {
        ang = 360/knurl_count * i;
        rotate([0,0,ang])
            translate([od/2 - knurl_depth/2, 0, 0])
                rotate([0,0,45])
                    cube([knurl_depth, knurl_depth, len*1.2], center=true);
    }
    for (z = [-len/2 : knurl_pitch : len/2]) {
        translate([0,0,z])
            rotate([0,0,15])
                cylinder(d=od + 0.6, h=0.25, center=true);
    }
}

module bore() {
    cylinder(d=bore_d, h=len + 2, center=true);
    translate([0,0,len/2 - lead_in/2])
        cylinder(h=lead_in+0.2, d1=bore_d+0.6, d2=bore_d, center=true);
    translate([0,0,-len/2 + lead_in/2])
        cylinder(h=lead_in+0.2, d1=bore_d, d2=bore_d+0.6, center=true);
}

difference() {
    insert_body();
    bore();
    knurl_cuts();
}
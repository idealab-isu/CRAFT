$fn=128;

module rigid_shaft_coupling(
    L=25.0,
    OD=12.5,
    bore1_d=5.0,
    bore2_d=8.0,
    split_at=12.5,
    chamfer=0.6
){
    difference() {
        // Body with slight end chamfers
        union() {
            cylinder(h=L, d=OD);
            // End chamfers (approximated as short tapers)
            if (chamfer > 0) {
                translate([0,0,0])
                    cylinder(h=chamfer, d1=OD-2*chamfer, d2=OD);
                translate([0,0,L-chamfer])
                    cylinder(h=chamfer, d1=OD, d2=OD-2*chamfer);
            }
        }

        // Through bores from each end meeting at split plane
        translate([0,0,-0.1])
            cylinder(h=split_at+0.2, d=bore1_d);

        translate([0,0,split_at-0.1])
            cylinder(h=(L-split_at)+0.2, d=bore2_d);

        // Small relief at the split plane to avoid overlap artifacts
        translate([0,0,split_at-0.05])
            cylinder(h=0.10, d=max(bore1_d,bore2_d)+0.2);
    }
}

rigid_shaft_coupling();
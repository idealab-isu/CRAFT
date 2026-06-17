// Linear bearing: 3.0mm bore, 7.0mm OD, 10.0mm length

bearing_length = 10.0;          //[5.0:20.0:0.1]
outer_diameter = 7.0;           //[3.5:14.0:0.1]
bore_diameter  = 3.0;           //[1.5:6.0:0.1]

chamfer_size = 0.3;             //[0.15:0.6:0.05]
groove_depth = 0.2;             //[0.1:0.5:0.05]
lube_groove_width = 0.6;        //[0.3:1.2:0.05]
lube_groove_offset = 2.5;       //[1.0:4.5:0.1]
retaining_groove_width = 0.5;   //[0.25:1.0:0.05]
retaining_groove_edge_margin = 1.0; //[0.5:2.0:0.1]

eps = 0.02;
$fn = 128;

module bearing() {
    r_out = outer_diameter/2;
    r_in  = bore_diameter/2;

    // Keep features physically valid
    cham = max(0, min(chamfer_size, r_out - r_in - 0.05, bearing_length/2 - 0.05));
    gdep = max(0, min(groove_depth, r_out - r_in - 0.05));
    lgw  = max(0, min(lube_groove_width, bearing_length - 0.2));
    lgo  = max(0, min(lube_groove_offset, bearing_length/2 - lgw/2 - 0.05));
    rgw  = max(0, min(retaining_groove_width, bearing_length - 0.2));
    rgz  = bearing_length/2 - retaining_groove_edge_margin;

    difference() {
        // Outer body (max OD = outer_diameter)
        union() {
            cylinder(h=bearing_length, r=r_out, center=true);

            // End chamfers (connected via slight overlap)
            if (cham > 0) {
                translate([0, 0,  bearing_length/2 - cham/2])
                    cylinder(h=cham + 2*eps, r1=r_out, r2=r_out - cham, center=true);
                translate([0, 0, -bearing_length/2 + cham/2])
                    cylinder(h=cham + 2*eps, r1=r_out - cham, r2=r_out, center=true);
            }
        }

        // Through-bore (must be visible from ALL side views)
        cylinder(h=bearing_length + 4*eps, r=r_in, center=true);

        // OD relief grooves (subtract only the annulus: r_out - gdep .. r_out)
        if (gdep > 0) {
            if (lgw > 0 && lgo > 0) {
                for (z = [lgo, -lgo]) {
                    translate([0, 0, z])
                        difference() {
                            cylinder(h=lgw + 4*eps, r=r_out + eps, center=true);
                            cylinder(h=lgw + 6*eps, r=r_out - gdep, center=true);
                        }
                }
            }

            if (rgw > 0 && rgz > 0) {
                for (z = [rgz, -rgz]) {
                    translate([0, 0, z])
                        difference() {
                            cylinder(h=rgw + 4*eps, r=r_out + eps, center=true);
                            cylinder(h=rgw + 6*eps, r=r_out - gdep, center=true);
                        }
                }
            }
        }
    }
}

color("Silver") bearing();
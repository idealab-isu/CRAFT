$fn=64;

rail_w = 9.0;
rail_h = 6.0;
rail_l = 100.0;

module countersunk_hole(thru_d=3.2, head_d=6.0, head_h=1.8, depth=rail_h+0.2) {
    union() {
        cylinder(h=depth, d=thru_d, center=false);
        translate([0,0,depth-head_h]) cylinder(h=head_h+0.01, d1=head_d, d2=thru_d, center=false);
    }
}

module rail_profile(w=rail_w, h=rail_h, l=rail_l) {
    difference() {
        translate([0,0,0]) cube([l,w,h], center=true);

        // Side reliefs to suggest guide geometry
        for (s = [-1, 1]) {
            translate([0, s*(w/2 - 1.2), 0.2])
                cube([l+0.2, 1.6, h-0.8], center=true);
        }

        // Top center groove
        translate([0,0,h/2 - 1.0])
            cube([l+0.2, 2.2, 2.0], center=true);

        // Mounting holes along length
        hole_count = 5;
        pitch = rail_l/(hole_count+1);
        for (i = [1:hole_count]) {
            x = -rail_l/2 + i*pitch;
            translate([x, 0, -rail_h/2 - 0.1])
                countersunk_hole(thru_d=3.2, head_d=6.0, head_h=1.8, depth=rail_h+0.2);
        }
    }
}

rail_profile();
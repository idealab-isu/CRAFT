$fn=128;

// Ring terminal parameters (mm)
ring_outer_d = 18;
ring_inner_d = 8;
ring_thickness = 2.2;

neck_length = 10;
neck_width  = 7;
neck_thickness = ring_thickness;

barrel_length = 18;
barrel_outer_d = 7.5;
barrel_inner_d = 4.2;

// Small flare at wire entry
flare_length = 3;
flare_outer_d = 8.5;
flare_inner_d = barrel_inner_d;

// Fillet-ish blend radius (approximated with hull)
blend_len = 2.5;

module ring_terminal() {
    union() {
        // Ring (washer)
        difference() {
            cylinder(h=ring_thickness, d=ring_outer_d);
            translate([0,0,-0.2]) cylinder(h=ring_thickness+0.4, d=ring_inner_d);
        }

        // Neck + blend to ring
        translate([ring_outer_d/2 - blend_len, -neck_width/2, 0])
        hull() {
            // near ring
            cube([blend_len, neck_width, neck_thickness], center=false);
            // start of neck
            translate([blend_len, 0, 0])
                cube([neck_length, neck_width, neck_thickness], center=false);
        }

        // Blend from neck to barrel (hull between rectangular and circular)
        translate([ring_outer_d/2 + neck_length - blend_len, 0, 0])
        hull() {
            // end of neck (rect)
            translate([0, -neck_width/2, 0])
                cube([blend_len, neck_width, neck_thickness], center=false);

            // start of barrel (circle)
            translate([blend_len, 0, 0])
                cylinder(h=neck_thickness, d=barrel_outer_d);
        }

        // Barrel (tube) aligned along +X
        translate([ring_outer_d/2 + neck_length, 0, ring_thickness/2])
        rotate([0,90,0])
        difference() {
            union() {
                cylinder(h=barrel_length, d=barrel_outer_d);
                // entry flare
                translate([barrel_length,0,0])
                    cylinder(h=flare_length, d1=barrel_outer_d, d2=flare_outer_d);
            }
            // bore
            translate([0,0,-0.2])
                cylinder(h=barrel_length+flare_length+0.4, d=barrel_inner_d);
            // flare bore (slight)
            translate([barrel_length,0,-0.2])
                cylinder(h=flare_length+0.4, d1=barrel_inner_d, d2=flare_inner_d);
        }
    }
}

ring_terminal();
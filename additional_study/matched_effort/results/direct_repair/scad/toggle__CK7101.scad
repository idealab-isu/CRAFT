$fn=96;

body_d = 6.86;
body_r = body_d/2;
body_h = 12.7;

cap_h = 0.8;
cap_overhang = 0.25;

module toggle_switch() {
    union() {
        // Main cylindrical body
        cylinder(h=body_h, r=body_r);

        // Slight top lip
        translate([0,0,body_h])
            cylinder(h=cap_h, r=body_r + cap_overhang);

        // Small bottom chamfer ring (visual detail)
        chamfer_h = 0.6;
        translate([0,0,0])
            cylinder(h=chamfer_h, r1=body_r + 0.15, r2=body_r);

        // Toggle lever (simple representation)
        lever_d = 2.2;
        lever_h = 10;
        lever_tilt = 18; // degrees
        translate([0,0,body_h + cap_h])
            rotate([lever_tilt,0,0])
                cylinder(h=lever_h, r=lever_d/2);

        // Lever tip
        translate([0,0,body_h + cap_h])
            rotate([lever_tilt,0,0])
                translate([0,0,lever_h])
                    sphere(r=lever_d/2);
    }
}

toggle_switch();
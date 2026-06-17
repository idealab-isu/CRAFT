$fn=96;

module led_3mm_through_hole(body_d=3.0, body_h=3.15, flange_d=3.4, flange_h=0.6,
                           lead_d=0.5, lead_pitch=2.54, lead_len=12.0,
                           lens_flat=0.35, cathode_flat_depth=0.25) {

    // Body (lens) with a small flat at the bottom edge and a cathode flat on the side
    color([0.85,0.1,0.1,0.85])
    difference() {
        union() {
            // Main cylindrical body
            translate([0,0,flange_h])
                cylinder(d=body_d, h=body_h-flange_h);

            // Flange at base
            cylinder(d=flange_d, h=flange_h);

            // Slightly domed top (spherical cap approximation)
            translate([0,0,body_h])
                intersection() {
                    sphere(d=body_d);
                    translate([0,0,-body_d/2])
                        cylinder(d=body_d, h=body_d/2);
                }
        }

        // Bottom lens flat (trim a bit off the bottom edge)
        translate([0,0,-1])
            cube([body_d*2, body_d*2, 1 + lens_flat], center=true);

        // Cathode flat on side (a shallow planar cut)
        translate([body_d/2 - cathode_flat_depth, 0, flange_h + (body_h-flange_h)/2])
            cube([cathode_flat_depth*2, body_d*1.2, (body_h-flange_h)*1.2], center=true);
    }

    // Leads
    color([0.75,0.75,0.78])
    for (sx = [-0.5, 0.5]) {
        translate([sx*lead_pitch, 0, -lead_len])
            cylinder(d=lead_d, h=lead_len + 0.2);
    }

    // Slight lead stubs into body
    color([0.75,0.75,0.78])
    for (sx = [-0.5, 0.5]) {
        translate([sx*lead_pitch, 0, 0])
            cylinder(d=lead_d, h=flange_h + 0.6);
    }
}

led_3mm_through_hole();
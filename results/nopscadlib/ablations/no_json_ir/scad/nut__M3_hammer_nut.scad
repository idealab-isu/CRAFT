$fn = 96;

module t_slot_nut(
    af = 6.0,          // across flats
    thick = 2.75,      // overall thickness
    screw_d = 3.0,     // M3 clearance
    neck_w = 4.0,      // narrow "neck" width for T-slot engagement
    neck_h = 1.10      // height of the neck (undercut step)
) {
    // Derived dimensions
    r_hex = af / sqrt(3);                 // circumradius for across-flats hex
    neck_h_clamped = min(neck_h, thick);  // safety
    base_h = thick - neck_h_clamped;

    difference() {
        union() {
            // Base: hex prism (across flats = af)
            translate([0, 0, base_h/2])
                cylinder(h = base_h, r = r_hex, $fn = 6, center = true);

            // Neck: narrower rectangular step on top to create T-profile/undercut
            // Overlap by a tiny amount to guarantee connectivity
            translate([0, 0, base_h + neck_h_clamped/2 - 0.01])
                cube([af, neck_w, neck_h_clamped], center = true);
        }

        // M3 clearance hole through entire part (with small extra for clean cut)
        translate([0, 0, thick/2])
            cylinder(d = screw_d, h = thick + 0.4, center = true);
    }
}

t_slot_nut();
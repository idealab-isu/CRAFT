$fn = 96;

// 5.0mm through-hole LED (T-1 3/4), 5.9mm body height
// One connected solid: flange + cylindrical body + domed lens + two leads.
// Coordinate system: flange bottom at z=0, body extends +Z, leads extend -Z.

module led_5mm_tht(
    body_d=5.0,
    body_h=5.9,          // total body height above flange (cyl + dome)
    flange_d=5.8,
    flange_h=1.0,
    dome_h=2.2,          // portion of body_h that is domed
    lead_d=0.5,
    lead_len=25,
    lead_pitch=2.54,
    cathode_flat_depth=0.35,
    overlap=0.10
){
    cyl_h = max(0.01, body_h - dome_h);

    // Spherical-cap dome that is guaranteed to meet the cylinder at its base:
    // Choose sphere radius so that cap height = dome_h with base radius = body_d/2.
    // R = (a^2 + h^2) / (2h), where a = body_d/2, h = dome_h
    a = body_d/2;
    R = (a*a + dome_h*dome_h) / (2*dome_h);

    union() {
        // Leads: start slightly inside flange for watertight union
        for (x = [-lead_pitch/2, lead_pitch/2]) {
            translate([x, 0, -lead_len])
                cylinder(d=lead_d, h=lead_len + flange_h + overlap);
        }

        // Flange (collar)
        cylinder(d=flange_d, h=flange_h);

        // Main cylindrical body with cathode flat
        translate([0, 0, flange_h - overlap])
        difference() {
            cylinder(d=body_d, h=cyl_h + overlap);

            // Flat cut: remove slab on +X side, depth measured from outer surface
            // Keep plane at x = a - cathode_flat_depth; remove everything beyond it.
            translate([a - cathode_flat_depth + (body_d/2), 0, (cyl_h + overlap)/2])
                cube([body_d, body_d*1.6, cyl_h + overlap + 0.2], center=true);
        }

        // Domed top: spherical cap of height dome_h, base exactly at top of cylinder
        // Place sphere center at z = (flange_h + cyl_h) + (dome_h - R)
        // Then keep only z >= flange_h + cyl_h - overlap to ensure overlap/connection.
        translate([0, 0, flange_h + cyl_h - overlap])
        intersection() {
            translate([0, 0, dome_h - R])
                sphere(r=R);

            // Keep cap region from base upward; include overlap to fuse with cylinder
            translate([0, 0, 0])
                cylinder(d=body_d*1.2, h=dome_h + 2*overlap);
        }
    }
}

led_5mm_tht();
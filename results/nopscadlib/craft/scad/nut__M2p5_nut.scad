// Hex nut for M2.5
thread_diameter = 2.5;      // mm (nominal)
across_flats    = 5.8;      // mm
thickness       = 2.2;      // mm
lead_in_chamfer = 0.2;      // mm
eps             = 0.02;     // mm (small to avoid artifacts)

$fn = 96;

// Single solid: hex body with circular bore + small lead-in chamfers
module hex_nut_M25() {
    difference() {
        // Hexagonal body (across flats = 2 * apothem)
        cylinder(
            h = thickness,
            r = across_flats / (2 * cos(30)),
            $fn = 6,
            center = true
        );

        // Circular bore (clearance for M2.5; adjust if you want tighter/looser)
        union() {
            cylinder(h = thickness + 2*eps, r = thread_diameter/2, center = true);

            // Top lead-in chamfer
            translate([0, 0, thickness/2 - (lead_in_chamfer/2)])
                cylinder(
                    h  = lead_in_chamfer + eps,
                    r1 = thread_diameter/2 + lead_in_chamfer,
                    r2 = thread_diameter/2,
                    center = true
                );

            // Bottom lead-in chamfer
            translate([0, 0, -thickness/2 + (lead_in_chamfer/2)])
                cylinder(
                    h  = lead_in_chamfer + eps,
                    r1 = thread_diameter/2,
                    r2 = thread_diameter/2 + lead_in_chamfer,
                    center = true
                );
        }
    }
}

hex_nut_M25();
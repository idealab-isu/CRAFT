// Thin hex nut for M5 screw
// Specs: 8.0mm across flats, 2.7mm thick, 5.0mm round through-hole

across_flats_mm = 8.0;
thickness_mm    = 2.7;
hole_diameter_mm = 5.0;

// Small edge break (kept subtle; set to 0 for perfectly sharp edges)
edge_chamfer_mm = 0.2;

// Numerical tolerance for clean booleans
eps_mm = 0.02;

// Convert across-flats to the cylinder radius used by $fn=6 (circumradius)
hex_outer_radius_mm = across_flats_mm / sqrt(3);

module thin_hex_nut() {
    difference() {
        // Main hex body
        cylinder(h=thickness_mm, r=hex_outer_radius_mm, $fn=6, center=true);

        // Round through-hole for screw clearance
        cylinder(h=thickness_mm + 2*eps_mm, r=hole_diameter_mm/2, $fn=64, center=true);

        // Optional small chamfers (implemented as conical cuts)
        if (edge_chamfer_mm > 0) {
            // Top chamfer cut
            translate([0, 0, thickness_mm/2 - edge_chamfer_mm/2])
                cylinder(h=edge_chamfer_mm + 2*eps_mm,
                         r1=hex_outer_radius_mm + eps_mm,
                         r2=hex_outer_radius_mm - edge_chamfer_mm,
                         $fn=6, center=true);

            // Bottom chamfer cut
            translate([0, 0, -thickness_mm/2 + edge_chamfer_mm/2])
                cylinder(h=edge_chamfer_mm + 2*eps_mm,
                         r1=hex_outer_radius_mm - edge_chamfer_mm,
                         r2=hex_outer_radius_mm + eps_mm,
                         $fn=6, center=true);
        }
    }
}

thin_hex_nut();
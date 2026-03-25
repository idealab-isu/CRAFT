// Thin hex nut for M6 screw: 10.0mm across flats, 3.2mm thick

thread_nominal_diameter_mm = 6.0;
across_flats_mm = 10.0;
thickness_mm = 3.2;

// Use a simple clearance hole for an M6 screw (no threads modeled)
hole_diameter_mm = 6.6;

eps_mm = 0.05;

// Derived: for a regular hex, across_flats = 2 * apothem
// OpenSCAD cylinder(r=..., $fn=6) uses circumradius (center to vertex)
hex_circumradius_mm = across_flats_mm / sqrt(3);

module thin_hex_nut() {
    difference() {
        // Hex body (flat-to-flat = across_flats_mm)
        cylinder(h=thickness_mm, r=hex_circumradius_mm, $fn=6, center=true);

        // Through hole
        cylinder(h=thickness_mm + 2*eps_mm, r=hole_diameter_mm/2, $fn=64, center=true);
    }
}

thin_hex_nut();
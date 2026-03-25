// Thin hex nut for M8: 13.0mm across flats, 4.0mm thick

$fn = 96;

// Target dimensions
thread_nominal_diameter_mm = 8.0;
across_flats_mm = 13.0;
thickness_mm = 4.0;

// Hole settings
tolerance_mm = 0.2;                 // added to clearance hole
hole_type_is_clearance = 1;         // 1=clearance, 0=undersized "threaded" pilot
threaded_hole_scale = 0.85;         // used when hole_type_is_clearance=0

// Robust boolean epsilon
eps_mm = 0.2;

// Derived
hole_diameter_mm = thread_nominal_diameter_mm;
hole_r =
    (hole_type_is_clearance == 1)
    ? (hole_diameter_mm + tolerance_mm) / 2
    : (thread_nominal_diameter_mm * threaded_hole_scale) / 2;

// Hex geometry: for a regular hex, across_flats = 2 * apothem
apothem = across_flats_mm / 2;
hex_R = apothem / cos(30);          // circumradius
hex_points = [ for (i = [0:5]) [ hex_R * cos(60*i), hex_R * sin(60*i) ] ];

module thin_hex_nut() {
    difference() {
        // Body
        linear_extrude(height = thickness_mm, center = true, convexity = 10)
            polygon(points = hex_points);

        // Through-hole (guaranteed to cut through)
        cylinder(r = hole_r, h = thickness_mm + 2*eps_mm, center = true);
    }
}

thin_hex_nut();
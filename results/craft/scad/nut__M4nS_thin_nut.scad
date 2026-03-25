// Thin hex nut for M4 screw
// Requirements: 7.0mm across flats, 2.2mm thick, circular M4 hole (tap/clearance selectable)
// Output: ONE connected solid (nut only; no washer/flange)

thread_nominal_diameter_mm = 4.0; //[2.0:8.0:0.1]
across_flats_mm = 7.0;            //[3.5:14.0:0.1]
thickness_mm = 2.2;               //[1.1:4.4:0.1]

// hole_type: 0 = tap hole, 1 = clearance hole
hole_type = 0;                    //[0:1:1]
tap_hole_diameter_mm = 3.3;       //[2.0:4.0:0.05]
clearance_hole_diameter_mm = 4.5; //[4.0:5.5:0.05]

$fn = 96;

eps = 0.02;

// Convert across-flats (AF) to circumradius (distance from center to vertex) for a hex:
// AF = 2 * apothem, apothem = R * cos(30) => R = AF / (2*cos(30))
hex_circumradius_mm = across_flats_mm / (2 * cos(30));

hole_diameter_mm = (hole_type == 0) ? tap_hole_diameter_mm : clearance_hole_diameter_mm;

module thin_hex_nut() {
    difference() {
        // Plain hex body (no flange/washer)
        cylinder(r = hex_circumradius_mm, h = thickness_mm, center = true, $fn = 6);

        // Circular through-hole
        cylinder(d = hole_diameter_mm, h = thickness_mm + 2*eps, center = true, $fn = 96);
    }
}

thin_hex_nut();
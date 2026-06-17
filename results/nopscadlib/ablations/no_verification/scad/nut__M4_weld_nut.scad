// Hex nut for 4.0mm screw
// Specs: 5.3mm across flats, 6.3mm thick
// Note: This is a plain clearance hole (no modeled threads).

thread_diameter_mm = 4.0;      // screw nominal diameter
across_flats_mm    = 5.3;      // hex across flats
thickness_mm       = 6.3;      // nut thickness
hole_clearance_mm  = 0.4;      // clearance for screw
eps_mm             = 0.2;      // boolean safety

module hex_nut() {
    hex_R = across_flats_mm / (2 * cos(30));                 // circumradius for $fn=6
    hole_r = (thread_diameter_mm + hole_clearance_mm) / 2;

    difference() {
        cylinder(r=hex_R, h=thickness_mm, center=true, $fn=6);
        cylinder(r=hole_r, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
}

hex_nut();
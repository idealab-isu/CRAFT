// Hex nut for 6.0mm screws
// 11.5mm across flats, 5.0mm thick

thread_nominal_diameter_mm = 6;          // M6 nominal
across_flats_mm = 11.5;                  // AF
thickness_mm = 5.0;                      // nut thickness
hole_type_is_threaded = 1;               // 1=threaded (modeled as simple hole), 0=clearance
thread_hole_diameter_mm = 6.0;           // simple representation of thread minor/nominal
clearance_hole_diameter_mm = 6.6;        // typical clearance
chamfer_mm = 0.5;                        // edge chamfer
eps_mm = 0.2;

$fn = 96;

// Derived
hex_circumradius_mm = across_flats_mm / (2 * cos(30)); // converts AF to circumscribed radius
hole_diameter_mm = hole_type_is_threaded ? thread_hole_diameter_mm : clearance_hole_diameter_mm;

module hex_nut(af=across_flats_mm, t=thickness_mm, d=hole_diameter_mm, cham=chamfer_mm) {
    R = af / (2 * cos(30));
    difference() {
        // Outer hex body (true hex across flats)
        cylinder(r=R, h=t, center=true, $fn=6);

        // Through hole
        cylinder(d=d, h=t + 2*eps_mm, center=true, $fn=96);

        // Top chamfer (remove material)
        if (cham > 0)
            translate([0, 0,  t/2 - cham/2])
                cylinder(r1=R, r2=R - cham, h=cham + eps_mm, center=true, $fn=6);

        // Bottom chamfer (remove material)
        if (cham > 0)
            translate([0, 0, -t/2 + cham/2])
                cylinder(r1=R - cham, r2=R, h=cham + eps_mm, center=true, $fn=6);
    }
}

hex_nut();
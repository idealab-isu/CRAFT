// Hex nut for 5.0mm screws: 9.2mm across flats, 4.0mm thick, 5.0mm through hole

across_flats   = 9.2;   // mm
thickness      = 4.0;   // mm
hole_diameter  = 5.0;   // mm
chamfer_size   = 0.4;   // mm (per face)
overlap        = 0.2;   // mm (boolean safety overlap)

// Derived
hex_R  = across_flats / sqrt(3);  // circumradius for a hex with given across-flats
hole_r = hole_diameter / 2;

module hex_nut() {
    difference() {
        // Outer hex prism (flats aligned to X/Y so top/bottom views are hex)
        cylinder(r=hex_R, h=thickness, center=true, $fn=6);

        // Through hole
        cylinder(r=hole_r, h=thickness + 2*overlap, center=true, $fn=96);

        // Top chamfer (remove material near outer edge)
        translate([0, 0, thickness/2 - chamfer_size/2])
            cylinder(
                r1 = hex_R + overlap,
                r2 = max(hole_r, hex_R - chamfer_size),
                h  = chamfer_size + overlap,
                center = true,
                $fn = 6
            );

        // Bottom chamfer
        translate([0, 0, -thickness/2 + chamfer_size/2])
            cylinder(
                r1 = max(hole_r, hex_R - chamfer_size),
                r2 = hex_R + overlap,
                h  = chamfer_size + overlap,
                center = true,
                $fn = 6
            );
    }
}

color("Silver") hex_nut();
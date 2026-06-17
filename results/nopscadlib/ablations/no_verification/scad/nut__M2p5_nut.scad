// Plain hex nut for M2.5
// Target: 5.8mm across flats, 2.2mm thick, circular bore (no flange/washer)

// Parameters
thread_diameter_mm = 2.5;          // nominal screw diameter
across_flats_mm    = 5.8;          // hex across flats
thickness_mm       = 2.2;          // nut thickness
tolerance_mm       = 0.15;         // clearance for printed hole
edge_chamfer_mm    = 0.2;          // small outer edge chamfer
overlap_mm         = 0.2;          // boolean overlap

$fn = 96;

// Helpers
function hex_circumradius_from_flats(af) = af / sqrt(3); // R such that across flats = sqrt(3)*R

module hex_nut_plain(af, h, hole_d, chamfer) {
    R = hex_circumradius_from_flats(af);

    difference() {
        // Outer hex with slight chamfer on both faces (still 6 flats)
        union() {
            // Middle straight section
            cylinder(r=R, h=max(h - 2*chamfer, 0.01), center=true, $fn=6);

            // Top chamfer
            translate([0, 0, (h/2) - (chamfer/2)])
                cylinder(r1=R, r2=max(R - chamfer, 0.01), h=chamfer + overlap_mm, center=true, $fn=6);

            // Bottom chamfer
            translate([0, 0, -(h/2) + (chamfer/2)])
                cylinder(r1=max(R - chamfer, 0.01), r2=R, h=chamfer + overlap_mm, center=true, $fn=6);
        }

        // Circular through-hole (clearance)
        cylinder(d=hole_d, h=h + 2*overlap_mm, center=true, $fn=96);
    }
}

module assembly() {
    // Plain nut only (no washer/flange/step)
    hex_nut_plain(
        af=across_flats_mm,
        h=thickness_mm,
        hole_d=thread_diameter_mm + tolerance_mm,
        chamfer=edge_chamfer_mm
    );
}

assembly();
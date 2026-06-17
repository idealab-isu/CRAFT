// Hex nut for 6.0mm screws, 11.5mm across flats, 3.0mm thick
thread_nominal_diameter_mm = 6.0;
across_flats_mm = 11.5;
thickness_mm = 3.0;

// 0 = clearance hole, 1 = simple thread-representation bore
hole_type = 0;
clearance_hole_diameter_mm = 6.4;
thread_pitch_mm = 1.0;

// Small edge break (not a full conical chamfer that destroys the hex)
chamfer_mm = 0.3;

// Robust boolean overlap
overlap_mm = 0.8;

function hex_circumradius_from_flats(af) = af / sqrt(3); // R = AF / (2*cos30) = AF/sqrt(3)

module hex_prism(af, h) {
    cylinder(h=h, r=hex_circumradius_from_flats(af), center=true, $fn=6);
}

module hex_nut_body(af, h, edge_break) {
    // Keep a true hex outer profile; add a small 45° edge break by subtracting
    // shallow frustums (still hex, not cones to a point).
    difference() {
        hex_prism(af, h);

        if (edge_break > 0) {
            // Top edge break
            translate([0, 0,  h/2 - edge_break/2])
                cylinder(
                    h=edge_break + overlap_mm,
                    r1=hex_circumradius_from_flats(af) + overlap_mm,
                    r2=hex_circumradius_from_flats(af) - edge_break,
                    center=true,
                    $fn=6
                );

            // Bottom edge break
            translate([0, 0, -h/2 + edge_break/2])
                cylinder(
                    h=edge_break + overlap_mm,
                    r1=hex_circumradius_from_flats(af) + overlap_mm,
                    r2=hex_circumradius_from_flats(af) - edge_break,
                    center=true,
                    $fn=6
                );
        }
    }
}

module bore(h) {
    // Clean circular bore (not polygonal)
    bore_d =
        (hole_type == 0)
        ? clearance_hole_diameter_mm
        : (thread_nominal_diameter_mm - 0.65 * thread_pitch_mm);

    cylinder(h=h, r=bore_d/2, center=true, $fn=96);
}

module hex_nut() {
    difference() {
        hex_nut_body(across_flats_mm, thickness_mm, chamfer_mm);
        bore(thickness_mm + 2*overlap_mm);
    }
}

hex_nut();
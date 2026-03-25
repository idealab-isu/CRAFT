// Dimension-calibrated (target: 0.03 x 0.01 x 0.03 mm)
scale([1.033375, 1.000168, 3.100521])
{
// Compact faceted cylindrical tool body with:
// - central hex through-bore (visible on both ends)
// - multiple smaller hexagonal through-holes arranged around it on ONE end face (-X end)
// - stepped collar near one end (-X)
// - domed/capped opposite end (+X)
// Units: meters

// ---------- Quality ----------
$fn = 64;
facet_count = 12;

// ---------- Parameters ----------
body_len      = 0.026;
body_flat_d   = 0.0092;

collar_len    = 0.0025;
collar_flat_d = 0.010;

dome_len      = 0.0015;   // axial length of cap segment
dome_r        = 0.005;    // sphere radius used to form cap

bore_hex_af   = 0.0036;

hole_count    = 6;
hole_hex_af   = 0.0016;
hole_ring_r   = 0.0032;

recess_depth  = 0.0006;
recess_af     = 0.0068;

// Robust overlap for unions/cuts (1–2mm)
overlap       = 0.0012;

// ---------- Derived extents (axis along X) ----------
x_body_min   = -body_len/2;
x_body_max   =  body_len/2;

x_collar_min = x_body_min - collar_len + overlap; // overlaps into body
x_collar_max = x_body_min + overlap;

x_neg_end    = x_collar_min; // outermost -X end face
x_pos_end    = x_body_max + dome_len; // outermost +X end (cap tip plane)

// ---------- Helpers ----------
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for hex with given across-flats

module hex_prism_x(af, len, center=true) {
    rotate([0,90,0])
        linear_extrude(height=len, center=center, convexity=10)
            circle(r=hex_R_from_AF(af), $fn=6);
}

// ---------- Main solids (axis along X) ----------
module main_faceted_body() {
    rotate([0,90,0])
        cylinder(r=body_flat_d/2, h=body_len, $fn=facet_count, center=true);
}

module stepped_collar() {
    // Collar spans x = [x_collar_min, x_collar_max]
    translate([(x_collar_min + x_collar_max)/2, 0, 0])
        rotate([0,90,0])
            cylinder(r=collar_flat_d/2, h=(x_collar_max - x_collar_min), $fn=facet_count, center=true);
}

module domed_or_capped_end() {
    // Domed cap on +X end, overlapping into main body by `overlap`
    x_base = x_body_max - overlap; // where sphere begins overlapping the body
    x_tip  = x_body_max + dome_len;

    intersection() {
        translate([x_base, 0, 0]) sphere(r=dome_r, $fn=96);
        translate([(x_base + x_tip)/2, 0, 0])
            cube([ (x_tip - x_base) + 2*overlap,
                   2*(dome_r + overlap),
                   2*(dome_r + overlap) ], center=true);
    }
}

// ---------- Cutters ----------
module central_hex_through_bore() {
    // Through the entire assembled length (+ extra) so openings are visible on both ends
    total_len = (x_pos_end - x_neg_end) + 6*overlap;
    hex_prism_x(bore_hex_af, total_len, center=true);
}

module peripheral_hex_holes_endface_only() {
    // Smaller hex through-holes that start at the -X end face and run inward only.
    // Ensure they CLEAR the collar and enter the main body.
    hole_depth = body_len * 0.55;

    // Start slightly outside the -X end face, extend inward
    x_start  = x_neg_end - overlap;
    x_end    = x_start + hole_depth + 2*overlap;
    x_center = (x_start + x_end)/2;

    for (i = [0:hole_count-1]) {
        ang = i * 360 / hole_count;
        translate([x_center, hole_ring_r*cos(ang), hole_ring_r*sin(ang)])
            hex_prism_x(hole_hex_af, (x_end - x_start), center=true);
    }
}

module end_face_recess() {
    // Shallow hex counterbore opening on the -X end face (around the central bore)
    x_start  = x_neg_end - overlap;
    x_end    = x_start + recess_depth + 2*overlap;
    x_center = (x_start + x_end)/2;

    translate([x_center, 0, 0])
        hex_prism_x(recess_af, (x_end - x_start), center=true);
}

// ---------- Assembly ----------
module tool_body() {
    difference() {
        union() {
            main_faceted_body();
            stepped_collar();
            domed_or_capped_end();
        }
        // Required features:
        central_hex_through_bore();
        peripheral_hex_holes_endface_only();
        end_face_recess();
    }
}

// Final output
tool_body();
}

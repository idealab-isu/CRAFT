// T-slot nut (single connected solid) for:
// - 3.0mm screw (clearance hole by default)
// - 6.0mm across flats (hex pocket on top face)
// - 3.0mm thick overall

// -------- Parameters --------
screw_d            = 3.0;   // screw nominal diameter
clearance_d        = 3.2;   // through-hole clearance for M3
across_flats       = 6.0;   // hex across flats
thickness          = 3.0;   // total nut thickness (overall)

body_length        = 10.0;  // along slot
neck_width         = 6.0;   // top/neck width (slot opening)
cavity_width       = 10.0;  // bottom/cavity width (slot undercut)

wing_height        = 1.0;   // height of the wider bottom "T" section
chamfer            = 0.4;   // end chamfer size

// Guaranteed overlap for connectivity (1-2mm as required)
overlap            = 1.2;

hex_pocket_depth   = 2.0;   // depth from top face down

$fn = 64;

// -------- Helpers --------
function hex_circumradius_from_af(af) = (af/2)/cos(30); // R such that across flats = af

module hex_prism(af, h, center=false) {
    cylinder(r=hex_circumradius_from_af(af), h=h, center=center, $fn=6);
}

// -------- Model --------
module tslot_nut() {
    wing_each_w = max(0, (cavity_width - neck_width)/2);

    top_h = max(0.01, thickness - wing_height);
    bot_h = min(wing_height, thickness);

    top_z =  thickness/2 - top_h/2;     // flush to top
    bot_z = -thickness/2 + bot_h/2;     // flush to bottom

    // --- Diagonal side rails (must be physically fused to body) ---
    // Make them intersect the body in Y by pushing their inner edge inside the body's max half-width.
    strip_len   = body_length * 0.95;
    strip_w     = 1.2;
    strip_h     = thickness;            // full thickness => guaranteed Z intersection
    strip_angle = 35;

    body_half_x = body_length/2;
    body_half_y = max(neck_width, cavity_width)/2;

    // Place rail centers so their INNER edge is inside the body by 'overlap'
    // inner_edge_y = strip_cy - strip_w/2  <= body_half_y - overlap
    strip_cy = body_half_y - overlap + strip_w/2;

    // Keep them near the ends in X but still intersecting the body volume
    strip_cx = body_half_x - overlap;

    difference() {
        union() {
            // Top/neck block
            translate([0, 0, top_z])
                cube([body_length, neck_width, top_h], center=true);

            // Bottom wings (wider)
            if (wing_each_w > 0) {
                // Overlap wings into neck by 'overlap' in Y to avoid any seam/gap
                translate([0, -(neck_width/2 + wing_each_w/2 - overlap), bot_z])
                    cube([body_length, wing_each_w, bot_h], center=true);

                translate([0,  (neck_width/2 + wing_each_w/2 - overlap), bot_z])
                    cube([body_length, wing_each_w, bot_h], center=true);
            } else {
                translate([0, 0, bot_z])
                    cube([body_length, neck_width, bot_h], center=true);
            }

            // Diagonal rail near +Y side (ATTACHED: overlaps body in Y by 'overlap')
            translate([ strip_cx,  strip_cy, 0])
                rotate([0, 0, -strip_angle])
                    cube([strip_len, strip_w, strip_h], center=true);

            // Diagonal rail near -Y side (ATTACHED: overlaps body in Y by 'overlap')
            translate([-strip_cx, -strip_cy, 0])
                rotate([0, 0, -strip_angle])
                    cube([strip_len, strip_w, strip_h], center=true);
        }

        // End chamfers
        chamfer_cut_w = cavity_width + 2;
        chamfer_cut_h = thickness + 2;

        translate([ body_length/2 - chamfer/2, 0, 0])
            rotate([0, 0, 45])
                cube([chamfer, chamfer_cut_w, chamfer_cut_h], center=true);

        translate([-body_length/2 + chamfer/2, 0, 0])
            rotate([0, 0, 45])
                cube([chamfer, chamfer_cut_w, chamfer_cut_h], center=true);

        // Through hole for M3 screw (clearance)
        cylinder(d=clearance_d, h=thickness + 2, center=true);

        // Hex pocket on top face (open to top only)
        translate([0, 0, thickness/2 - hex_pocket_depth/2 + overlap])
            rotate([0, 0, 30])
                hex_prism(across_flats, hex_pocket_depth + 2*overlap, center=true);
    }
}

tslot_nut();
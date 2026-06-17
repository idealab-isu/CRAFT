$fn = 64;

// Miniature linear guide rail (connected rail + carriage)
// Target overall rail size: 100(L) x 15(W) x 10(H) mm

// ---------------- Parameters ----------------
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 15.0;  //[7.5:30.0:0.5]
rail_H = 10.0;  //[5.0:20.0:0.5]

// Rail profile details (kept within rail_W/rail_H)
side_step_w = 2.0;   //[0.5:4.0:0.1]   // side relief width
side_step_h = 2.0;   //[0.5:4.0:0.1]   // side relief height from bottom
top_groove_w = 6.0;  //[2.0:10.0:0.5]  // top center groove width
top_groove_d = 1.2;  //[0.5:3.0:0.1]   // top center groove depth

// Mounting holes (through rail height)
hole_d = 3.0;        //[1.5:6.0:0.1]
hole_pitch = 25.0;   //[12.0:50.0:1]
hole_end_offset = 12.5; //[6.0:25.0:0.5]
hole_count = 4;      //[2:8:1]
hole_extra_depth = 2.0; //[0.5:5.0:0.5]

// Carriage block
carriage_L = 25.0;   //[12.0:60.0:1]
carriage_W = 22.0;   //[12.0:44.0:1]
carriage_H = 14.0;   //[7.0:28.0:1]

// Connection overlap to guarantee one connected solid
overlap = 0.6;       //[0.2:2.0:0.1]

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep details valid for any parameter edits
side_step_w2 = clamp(side_step_w, 0, rail_W/2 - 0.2);
side_step_h2 = clamp(side_step_h, 0, rail_H - 0.2);
top_groove_w2 = clamp(top_groove_w, 0.5, rail_W - 0.5);
top_groove_d2 = clamp(top_groove_d, 0, rail_H/2 - 0.2);

// ---------------- Geometry ----------------
module rail_profile_solid() {
    // Base rail block with simple profile reliefs and a top groove
    difference() {
        cube([rail_L, rail_W, rail_H], center=true);

        // Side reliefs (bottom corners) to suggest rail profile
        // Left relief
        translate([0,
                   -rail_W/2 + side_step_w2/2,
                   -rail_H/2 + side_step_h2/2])
            cube([rail_L + 2*overlap, side_step_w2, side_step_h2], center=true);

        // Right relief
        translate([0,
                   rail_W/2 - side_step_w2/2,
                   -rail_H/2 + side_step_h2/2])
            cube([rail_L + 2*overlap, side_step_w2, side_step_h2], center=true);

        // Top center groove
        translate([0, 0, rail_H/2 - top_groove_d2/2])
            cube([rail_L + 2*overlap, top_groove_w2, top_groove_d2], center=true);
    }
}

module mounting_holes() {
    // Holes go through Z (height), positioned along X
    for (i = [0:hole_count-1]) {
        x = -rail_L/2 + hole_end_offset + i*hole_pitch;
        // Keep holes within rail length
        if (x <= rail_L/2 - hole_end_offset + 1e-6)
            translate([x, 0, 0])
                cylinder(h=rail_H + hole_extra_depth, r=hole_d/2, center=true);
    }
}

module carriage_block() {
    // Carriage sits on top of rail and overlaps slightly into it for connectivity
    translate([0, 0, rail_H/2 + carriage_H/2 - overlap])
        cube([carriage_L, carriage_W, carriage_H], center=true);
}

module complete_model() {
    union() {
        // Rail with holes
        difference() {
            rail_profile_solid();
            mounting_holes();
        }

        // Carriage (connected)
        carriage_block();
    }
}

// ---------------- Output ----------------
complete_model();
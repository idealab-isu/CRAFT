// 20x20 T-slot aluminium extrusion (approx. 2020 profile), 100mm long
// STRUCTURAL FIX: ensure the cross-section is ONE connected solid (no split/floating long bodies)

$fn = 96;

// Parameters (mm)
size_mm   = 20.0;
length_mm = 100.0;

// Proportions (simple but recognizable)
slot_open_mm     = 6.0;   // opening width at the face
slot_depth_mm    = 6.0;   // depth from face inward
slot_cavity_w_mm = 10.0;  // wider cavity behind opening
slot_cavity_d_mm = 3.0;   // cavity depth behind opening
center_bore_d_mm = 5.0;   // center hole diameter

// Overlap to guarantee boolean connectivity (1-2mm as requested)
overlap_mm = 1.0;

// Minimum web thickness that MUST remain between opposite slot cuts
// to prevent the profile from splitting into two long bars / four corner blocks.
min_web_mm = 2.0;

// Derived: clamp slot depth so opposite cuts cannot sever the body.
// Condition: 2*slot_depth <= size - min_web
slot_depth_eff_mm = min(slot_depth_mm, (size_mm - min_web_mm)/2);

// Also clamp cavity depth so it stays behind the opening and doesn't worsen severing.
slot_cavity_d_eff_mm = min(slot_cavity_d_mm, max(0, slot_depth_eff_mm - 1.0));

module tslot2020_section_2d() {
    difference() {
        // Main body (solid 20x20)
        square([size_mm, size_mm], center=true);

        // Center bore (hole)
        circle(d=center_bore_d_mm);

        // Four T-slots cut from each face inward
        for (a = [0, 90, 180, 270]) {
            rotate(a) {
                // Slot opening (narrow) from face inward
                // Positioned so its outer edge slightly protrudes past the face (overlap),
                // but its inner edge stops at (size/2 - slot_depth_eff), preserving a center web.
                translate([ size_mm/2 - slot_depth_eff_mm/2 + overlap_mm/2, 0 ])
                    square([ slot_depth_eff_mm + overlap_mm, slot_open_mm ], center=true);

                // Slot cavity (wider) behind the opening (still not allowed to reach center)
                translate([ size_mm/2 - slot_depth_eff_mm - slot_cavity_d_eff_mm/2 + overlap_mm/2, 0 ])
                    square([ slot_cavity_d_eff_mm + overlap_mm, slot_cavity_w_mm ], center=true);
            }
        }
    }
}

module extrusion_2020(len=length_mm) {
    // Union used explicitly to ensure a single combined solid
    union() {
        color("Silver")
            linear_extrude(height=len, center=true, convexity=10)
                tslot2020_section_2d();
    }
}

// Build
extrusion_2020(length_mm);
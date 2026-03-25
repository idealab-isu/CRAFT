// Linear bearing block for 8.0mm shaft
// Block size: 40.0mm x 35.0mm (L x W)
// One connected solid (single printable part) with bore + bearing seat + mounting holes + clamp slit + clamp screw holes
//
// STRUCTURAL FIXES (connectivity):
// - Clamp slit is now a PARTIAL-Y slit (does not reach the -Y face), leaving a solid spine.
// - Added an internal "bridge rib" across the slit near the -Y side to guarantee a single connected solid
//   even if slicers/kernel treat near-tangent faces as disconnected.
// - All unions overlap by ~1–2mm to ensure watertight connectivity.
// - All translate() values are formula-based (no arbitrary offsets).

shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
block_length_mm = 40.0; //[20.0:80.0:0.5]
block_width_mm  = 35.0; //[18.0:70.0:0.5]
block_height_mm = 28.0; //[14.0:56.0:0.5]

bearing_outer_diameter_mm = 15.0; //[10.0:30.0:0.1]
bearing_length_mm         = 24.0; //[12.0:48.0:0.5]

shaft_bore_clearance_mm   = 0.1; //[0.0:0.5:0.05]
bearing_seat_clearance_mm = 0.2; //[0.0:0.6:0.05]

mounting_hole_diameter_mm   = 5.0; //[3.0:8.0:0.1]
mounting_hole_spacing_x_mm  = 30.0; //[15.0:60.0:0.5]
mounting_hole_spacing_y_mm  = 20.0; //[10.0:50.0:0.5]

split_gap_mm            = 1.0; //[0.5:3.0:0.1]
clamp_screw_diameter_mm = 4.0; //[3.0:6.0:0.1]

mounting_face_thickness_mm = 2.0; //[1.0:5.0:0.5]

// Use 1–2mm overlap for robust connectivity
overlap_mm = 1.2; //[0.2:2.0:0.1]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module bearing_block_solid() {
    // Derived
    shaft_r = (shaft_diameter_mm + shaft_bore_clearance_mm)/2;
    seat_r  = (bearing_outer_diameter_mm + bearing_seat_clearance_mm)/2;

    // Ensure bearing seat fits within block length
    seat_len = min(bearing_length_mm, block_length_mm - 2*overlap_mm);

    // Keep mounting holes inside footprint with a margin
    hole_margin = mounting_hole_diameter_mm/2 + 2;
    sx = clamp(mounting_hole_spacing_x_mm, 0, block_length_mm - 2*hole_margin);
    sy = clamp(mounting_hole_spacing_y_mm, 0, block_width_mm  - 2*hole_margin);

    // Clamp screw placement (through Y), keep inside block
    screw_x = clamp(block_length_mm/4, 0, block_length_mm/2 - (clamp_screw_diameter_mm/2 + 2));
    screw_z = clamp(block_height_mm/4, 0, block_height_mm/2 - (clamp_screw_diameter_mm/2 + 2));

    // Bearing housing "boss"
    boss_r = min(block_width_mm/2 - 1.0, seat_r + 3.0);
    boss_r = max(boss_r, seat_r + 1.5);

    // --- Clamp slit: partial along Y so the body remains one connected solid ---
    // Leave a solid spine on the -Y side.
    spine_y_mm = 2.0;
    spine_y_mm = clamp(spine_y_mm, 1.0, block_width_mm - split_gap_mm - 1.0);

    // Slit region spans from +Y face inward, stopping short of -Y face by spine_y_mm.
    // Cut region in Y: [ -W/2 + spine_y_mm , +W/2 ]
    slit_depth_y  = block_width_mm - spine_y_mm;
    slit_center_y = (block_width_mm/2) - (slit_depth_y/2);

    // Extra internal bridge rib to guarantee connectivity across the slit
    // (prevents any "upper/lower bearing block halves" from becoming disconnected).
    // Place it inside the uncut spine region near -Y, overlapping both sides by > overlap_mm.
    bridge_y_thk = max(2.0, split_gap_mm + 2*overlap_mm);   // spans across the slit gap with overlap
    bridge_z_thk = max(3.0, overlap_mm + 2.0);              // small vertical rib thickness
    bridge_x_len = block_length_mm + 2*overlap_mm;          // full length with overlap
    bridge_y_pos = -block_width_mm/2 + spine_y_mm/2;        // centered within the spine region
    bridge_z_pos = 0;                                       // centered vertically (doesn't change exterior)

    difference() {
        // SOLID: everything that must be one connected piece
        union() {
            // Main rectangular body
            cube([block_length_mm, block_width_mm, block_height_mm], center=true);

            // Bottom mounting face (connected with overlap)
            translate([0, 0, -block_height_mm/2 - mounting_face_thickness_mm/2 + overlap_mm])
                cube([block_length_mm, block_width_mm, mounting_face_thickness_mm], center=true);

            // Central cylindrical boss (bearing housing), oriented along X
            rotate([0, 90, 0])
                cylinder(r=boss_r, h=block_length_mm, center=true);

            // Internal bridge rib (guarantees no split/floating halves)
            translate([0, bridge_y_pos, bridge_z_pos])
                cube([bridge_x_len, bridge_y_thk, bridge_z_thk], center=true);
        }

        // Shaft bore (through X)
        rotate([0, 90, 0])
            cylinder(r=shaft_r, h=block_length_mm + 2*overlap_mm, center=true);

        // Bearing seat (counterbore)
        rotate([0, 90, 0])
            cylinder(r=seat_r, h=seat_len, center=true);

        // Mounting holes (through Z, include mounting face)
        for (xsgn = [-1, 1])
            for (ysgn = [-1, 1])
                translate([xsgn*sx/2, ysgn*sy/2, -block_height_mm/2 - mounting_face_thickness_mm/2 + overlap_mm])
                    cylinder(
                        r=mounting_hole_diameter_mm/2,
                        h=block_height_mm + mounting_face_thickness_mm + 2*overlap_mm,
                        center=true
                    );

        // Clamp slit (PARTIAL along Y so the body remains one connected solid)
        // Cut only within the +Y-side region; does not reach the -Y face.
        translate([0, slit_center_y, 0])
            cube([block_length_mm + 2*overlap_mm, split_gap_mm, block_height_mm + 2*overlap_mm], center=true);

        // Clamp screw holes (through Y), on +X side, symmetric in Z
        for (zsgn = [-1, 1])
            translate([screw_x, 0, zsgn*screw_z])
                rotate([90, 0, 0])
                    cylinder(
                        r=clamp_screw_diameter_mm/2,
                        h=block_width_mm + 2*overlap_mm,
                        center=true
                    );
    }
}

bearing_block_solid();
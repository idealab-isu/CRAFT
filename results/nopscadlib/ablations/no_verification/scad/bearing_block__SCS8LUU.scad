// Long linear bearing block for 6.0mm shaft
// Block size: 34.0mm (X) x 58.0mm (Y) x 20.0mm (Z)
// One connected solid (bearing/shaft are not separate parts; only cutouts)

$fn = 96;

// Parameters
shaft_diameter_mm = 6.0; //[3.0:12.0:0.1]
block_width_mm = 34.0;   //[17.0:68.0:0.5]   // X
block_length_mm = 58.0;  //[29.0:116.0:0.5]  // Y
block_height_mm = 20.0;  //[10.0:40.0:0.5]   // Z

shaft_bore_clearance_mm = 0.2; //[0.0:0.6:0.05]
bore_diameter_mm = shaft_diameter_mm + shaft_bore_clearance_mm; //[6.0:7.0:0.05]

mount_hole_diameter_mm = 4.2; //[3.0:6.0:0.1]
mount_hole_edge_margin_mm = 6.0; //[3.0:12.0:0.5]
counterbore_diameter_mm = 8.0; //[6.0:16.0:0.1]
counterbore_depth_mm = 3.0; //[1.0:8.0:0.1]

set_screw_thread = 3; //[2:6:1]
set_screw_clearance_mm = 0.4; //[0.2:0.8:0.05]
set_screw_hole_depth_mm = 10.0; //[5.0:18.0:0.5]
set_screw_offset_from_end_mm = 10.0; //[5.0:20.0:0.5]

overlap_mm = 1.0; //[0.5:2.0:0.1]

// Geometry tuning (typical long bearing block look)
top_flat_mm = 2.0;                 // material above bore
bottom_flat_mm = 2.0;              // material below bore
side_wall_min_mm = 4.0;            // minimum side wall thickness around bore
clamp_slot_width_mm = 2.0;         // slit width
clamp_slot_depth_mm = 0.65;        // fraction of height for slit depth
clamp_boss_d_mm = 8.0;             // boss diameter around clamp screw
fillet_r_mm = 2.0;                 // simple edge softening via minkowski (small)

function clamp_boss_r() = clamp_boss_d_mm/2;
function clamp_screw_d() = set_screw_thread + set_screw_clearance_mm;

module rounded_block(size=[10,10,10], r=1) {
    // Rounded edges using minkowski; keep r small for performance
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module bearing_block() {
    // Ensure bore fits with walls
    bore_r = bore_diameter_mm/2;
    min_x = 2*(bore_r + side_wall_min_mm);
    bw = max(block_width_mm, min_x);

    // Bore center height (Z) from bottom: keep top/bottom flats
    bore_center_z = -block_height_mm/2 + bottom_flat_mm + bore_r;
    // Clamp slit starts at top and goes down near bore center
    slit_z_center = block_height_mm/2 - (block_height_mm*clamp_slot_depth_mm)/2;
    slit_h = block_height_mm*clamp_slot_depth_mm + overlap_mm;

    // Mount hole pattern (4 holes)
    hx = bw/2 - mount_hole_edge_margin_mm;
    hy = block_length_mm/2 - mount_hole_edge_margin_mm;

    // Clamp screw location (across X), near one end in Y
    clamp_y = block_length_mm/2 - set_screw_offset_from_end_mm;
    clamp_z = block_height_mm/2 - (top_flat_mm + clamp_boss_r()); // near top

    difference() {
        // Main body (rounded)
        rounded_block([bw, block_length_mm, block_height_mm], r=min(fillet_r_mm, 0.49*min(bw,block_length_mm,block_height_mm)));

        // Shaft bore along Y
        translate([0, 0, bore_center_z])
            rotate([90, 0, 0])
                cylinder(r=bore_r, h=block_length_mm + 2*overlap_mm, center=true);

        // Clamp slit from top down (along Y, thin in X)
        translate([0, 0, slit_z_center])
            cube([clamp_slot_width_mm, block_length_mm + 2*overlap_mm, slit_h], center=true);

        // Clamp screw through X (cross-bolt) + bosses clearance
        // Through-hole
        translate([0, clamp_y, clamp_z])
            rotate([0, 90, 0])
                cylinder(r=clamp_screw_d()/2, h=bw + 2*overlap_mm, center=true);

        // Counterbore pockets on both sides for clamp screw head/nut (simple)
        translate([ bw/2 - clamp_boss_r(), clamp_y, clamp_z])
            rotate([0, 90, 0])
                cylinder(r=clamp_boss_r(), h=2*clamp_boss_r() + overlap_mm, center=true);
        translate([-bw/2 + clamp_boss_r(), clamp_y, clamp_z])
            rotate([0, 90, 0])
                cylinder(r=clamp_boss_r(), h=2*clamp_boss_r() + overlap_mm, center=true);

        // Mounting holes (through Z) with counterbores on top face
        for (sx = [-1, 1], sy = [-1, 1]) {
            // Through hole
            translate([sx*hx, sy*hy, 0])
                cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true);

            // Counterbore from top
            translate([sx*hx, sy*hy, block_height_mm/2 - counterbore_depth_mm/2 + overlap_mm/2])
                cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
        }

        // Optional: small relief pockets on sides to resemble bearing block profile
        relief_r = min(6, bw/2 - 1);
        relief_h = block_height_mm*0.55;
        for (sy = [-1, 1]) {
            translate([0, sy*(block_length_mm/2 - 0.22*block_length_mm), -block_height_mm/2 + relief_h/2])
                rotate([0, 90, 0])
                    cylinder(r=relief_r, h=bw + 2*overlap_mm, center=true);
        }
    }
}

bearing_block();
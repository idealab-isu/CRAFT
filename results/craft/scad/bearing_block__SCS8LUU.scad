// Long linear bearing block (SCS6LUU-style) for 6.0mm shaft
// Single connected solid, block size 34mm x 58mm (W x L)

$fn = 96;

// Parameters
shaft_diameter_mm = 6.0; //[3.0:12.0:0.1]
block_width_mm    = 34.0; //[17.0:68.0:0.5]   // X
block_length_mm   = 58.0; //[29.0:116.0:0.5]  // Y
block_height_mm   = 24.0; //[12.0:48.0:0.5]   // Z

mounting_hole_diameter_mm   = 5.0; //[3.0:8.0:0.1]
mounting_hole_spacing_x_mm  = 24.0; //[16.0:30.0:0.5]
mounting_hole_spacing_y_mm  = 44.0; //[30.0:54.0:0.5]
counterbore_diameter_mm     = 9.0; //[6.0:16.0:0.1]
counterbore_depth_mm        = 4.0; //[2.0:10.0:0.1]

clamp_slit_width_mm = 1.5; //[0.8:3.0:0.1]
tolerance_mm        = 0.2; //[0.0:0.5:0.05]
edge_radius_mm      = 1.0; //[0.0:3.0:0.1]
overlap_mm          = 1.0; //[0.5:2.0:0.1]
bore_extra_length_mm = 2.0; //[0.5:6.0:0.5]

// Derived (simple SCS6LUU-like proportions)
bore_r = (shaft_diameter_mm + tolerance_mm)/2;

// Outer "bearing seat" cavity (visual/functional clearance pocket around bore)
seat_diameter_mm = max(shaft_diameter_mm + 8.0, 14.0); // typical for SCS6LUU-ish look
seat_r = (seat_diameter_mm + tolerance_mm)/2;
seat_length_mm = block_length_mm * 0.62;               // long pocket but not full length

// Top opening to bore (clamp gap)
top_opening_w_mm = min(block_width_mm * 0.55, seat_diameter_mm + 6.0);
top_opening_l_mm = block_length_mm + 2*overlap_mm;

// Small relief around bore at top (gives "U" look)
u_relief_r = seat_r + 1.5;

// Rounded block helper (rounded vertical edges)
module rounded_block(size=[10,10,10], r=1.0) {
    r2 = min(r, min(size[0], size[1]) / 2);
    linear_extrude(height=size[2], center=true)
        offset(r=r2)
            square([size[0]-2*r2, size[1]-2*r2], center=true);
}

module scs6luu_block() {
    difference() {
        // Main body (one solid)
        rounded_block([block_width_mm, block_length_mm, block_height_mm], r=edge_radius_mm);

        // Shaft bore (along Y)
        rotate([90,0,0])
            cylinder(r=bore_r, h=block_length_mm + bore_extra_length_mm, center=true);

        // Bearing seat pocket (along Y) - larger diameter, shorter length
        rotate([90,0,0])
            cylinder(r=seat_r, h=seat_length_mm + overlap_mm, center=true);

        // Top opening slot down to bore/seat (clamp gap)
        // Place so it opens from top surface down past bore center
        slot_h = block_height_mm/2 + seat_r + overlap_mm;
        translate([0, 0, block_height_mm/2 - slot_h/2 + overlap_mm])
            cube([clamp_slit_width_mm, top_opening_l_mm, slot_h], center=true);

        // Wider top "U" opening (gives typical SCS look)
        u_h = block_height_mm/2 + u_relief_r;
        translate([0, 0, block_height_mm/2 - u_h/2 + overlap_mm])
            cube([top_opening_w_mm, top_opening_l_mm, u_h], center=true);

        // Mounting through-holes (4)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mounting_hole_spacing_x_mm/2,
                       sy*mounting_hole_spacing_y_mm/2,
                       0])
                cylinder(r=mounting_hole_diameter_mm/2,
                         h=block_height_mm + 2*overlap_mm,
                         center=true);
        }

        // Counterbores on top face
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mounting_hole_spacing_x_mm/2,
                       sy*mounting_hole_spacing_y_mm/2,
                       block_height_mm/2 - counterbore_depth_mm/2 + overlap_mm*0.25])
                cylinder(r=counterbore_diameter_mm/2,
                         h=counterbore_depth_mm + overlap_mm,
                         center=true);
        }
    }
}

scs6luu_block();
$fn = 96;

// Leadscrew nut housing overall size (X=length, Y=width, Z=height)
block_width  = 16.0;   // Y
block_height = 28.0;   // Z
block_length = 42.5;   // X

// Internal features
nut_bore_diameter       = 10.0;  // through bore (along Y, per views)
mounting_hole_diameter  = 3.0;   // through holes (along Y, per views)
mounting_hole_offset_x  = 4.0;   // from X edges
mounting_hole_offset_z  = 4.0;   // from Z edges

eps = 0.05;

// Main block body
module main_block_body() {
    cube([block_length, block_width, block_height], center=true);
}

// Through leadscrew/nut bore (along Y)
module leadscrew_nut_bore() {
    rotate([90, 0, 0])
        cylinder(h=block_width + 2*eps, d=nut_bore_diameter, center=true);
}

// Mounting holes (through Y), positioned from X/Z edges using formulas
module mounting_holes() {
    x_pos = block_length/2 - mounting_hole_offset_x;
    z_pos = block_height/2 - mounting_hole_offset_z;

    for (x = [-x_pos, x_pos])
        for (z = [-z_pos, z_pos])
            translate([x, 0, z])
                rotate([90, 0, 0])
                    cylinder(h=block_width + 2*eps, d=mounting_hole_diameter, center=true);
}

// Assemble: one connected solid (block with subtracted holes)
difference() {
    main_block_body();
    leadscrew_nut_bore();
    mounting_holes();
}
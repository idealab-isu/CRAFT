// Linear bearing block for 9.0mm shaft
// Block size: 50.0mm x 44.0mm x 30.0mm
// One connected solid (single printable part): bearing-style housing with through shaft bore + 4 mounting holes + top counterbores

// Parameters
shaft_diameter_mm = 9.0; //[4.5:18.0:0.1]
block_length_mm   = 50.0; //[25.0:100.0:0.5]   // X
block_width_mm    = 44.0; //[22.0:88.0:0.5]    // Y
block_height_mm   = 30.0; //[15.0:60.0:0.5]    // Z

// Bore (shaft channel)
shaft_fit_clearance_mm = 0.2; //[0.0:0.5:0.01]

// Bearing housing geometry (adds "typical" rounded housing around the bore)
housing_outer_d_mm = 26.0; //[16.0:40.0:0.5]   // outer diameter of the cylindrical housing
housing_len_mm     = 34.0; //[20.0:50.0:0.5]   // length along X of the housing
housing_flat_z_mm  = 2.0;  //[0.0:6.0:0.5]     // how much to flatten top/bottom of housing to blend into block

// Mounting holes
mount_hole_diameter_mm   = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_x_mm  = 38.0; //[20.0:80.0:0.5]
mount_hole_spacing_y_mm  = 32.0; //[16.0:70.0:0.5]
counterbore_diameter_mm  = 9.0; //[6.0:14.0:0.1]
counterbore_depth_mm     = 4.0; //[1.0:10.0:0.5]

// Edge rounding (visual/typical block look)
corner_radius_mm = 3.0; //[0.0:8.0:0.5]

// Small overlap for robust booleans
overlap_mm = 0.8; //[0.2:2.0:0.1]

$fn = 96;

// Helpers
module rounded_block(size_xyz, r) {
    lx = size_xyz[0];
    ly = size_xyz[1];
    lz = size_xyz[2];

    if (r <= 0) {
        cube([lx, ly, lz], center=true);
    } else {
        minkowski() {
            cube([lx - 2*r, ly - 2*r, lz - 2*r], center=true);
            sphere(r=r);
        }
    }
}

module mount_holes_through() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2, 0])
            cylinder(d=mount_hole_diameter_mm, h=block_height_mm + 2*overlap_mm, center=true);
    }
}

module mount_counterbores_top() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_spacing_x_mm/2,
                   sy*mount_hole_spacing_y_mm/2,
                   block_height_mm/2 - counterbore_depth_mm/2 + overlap_mm/2])
            cylinder(d=counterbore_diameter_mm, h=counterbore_depth_mm + overlap_mm, center=true);
    }
}

module shaft_bore_x() {
    rotate([0, 90, 0])
        cylinder(d=shaft_diameter_mm + shaft_fit_clearance_mm,
                 h=block_length_mm + 2*overlap_mm, center=true);
}

module bearing_housing_solid() {
    // Cylindrical housing centered on the shaft axis (X axis), blended into the block
    // Flattened slightly on top/bottom so it doesn't protrude beyond block height.
    // Ensure it stays within the 30mm height by limiting effective radius.
    eff_r = min(housing_outer_d_mm/2, block_height_mm/2 - 0.2);
    eff_d = 2*eff_r;

    intersection() {
        // Main cylinder along X
        rotate([0, 90, 0])
            cylinder(d=eff_d, h=housing_len_mm, center=true);

        // Flatten top/bottom to blend into block (still connected)
        // Keep within block height with a small margin.
        cube([housing_len_mm + 2*overlap_mm,
              block_width_mm + 2*overlap_mm,
              block_height_mm - 2*housing_flat_z_mm], center=true);
    }
}

module linear_bearing_block() {
    difference() {
        union() {
            // Base block (50 x 44 x 30)
            rounded_block([block_length_mm, block_width_mm, block_height_mm], corner_radius_mm);

            // Add bearing-style cylindrical housing around the bore (connected, centered)
            bearing_housing_solid();
        }

        // Shaft channel (through along X)
        shaft_bore_x();

        // Mounting holes + counterbores
        mount_holes_through();
        mount_counterbores_top();
    }
}

linear_bearing_block();
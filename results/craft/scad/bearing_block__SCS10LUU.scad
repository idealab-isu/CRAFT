$fn = 96;

// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
block_width_mm = 40; //[20:80:0.5]     // X
block_length_mm = 68; //[34:136:0.5]   // Y
block_height_mm = 30; //[15:60:0.5]    // Z

bearing_outer_diameter_mm = 15; //[10:30:0.1]
bearing_length_mm = 24; //[12:48:0.5]
bore_clearance_mm = 0.2; //[0:0.6:0.05]
bearing_bore_depth_mm = 26; //[18:40:0.5]
retention_shoulder_mm = 1.5; //[0.5:4:0.1]
retention_lip_depth_mm = 2; //[1:6:0.5]

mount_hole_diameter_mm = 5; //[3:8:0.1]
mount_hole_spacing_x_mm = 28; //[14:56:0.5]
mount_hole_spacing_y_mm = 50; //[25:100:0.5]

set_screw_count = 2; //[0:4:1]
set_screw_diameter_mm = 3; //[2:6:0.1]
set_screw_length_mm = 10; //[6:20:0.5]
set_screw_offset_from_top_mm = 8; //[4:16:0.5]

overlap_mm = 1; //[0.5:2:0.1]

// Added: recognizable long bearing block features (SCS/SBR style)
base_thickness_mm = 12; //[8:18:0.5]          // mounting base thickness
housing_height_mm = 18; //[12:26:0.5]         // raised bearing housing height above base
housing_width_mm = 28; //[18:36:0.5]          // raised housing width (X)
housing_length_mm = 46; //[30:60:0.5]         // raised housing length (Y)
housing_corner_r_mm = 3; //[0:6:0.5]          // housing corner radius
base_corner_r_mm = 2; //[0:6:0.5]             // base corner radius

clamp_slot_width_mm = 2.2; //[1:5:0.1]        // split clamp slot width
clamp_slot_depth_mm = 10; //[4:20:0.5]        // how far down from top the slot cuts
clamp_bolt_count = 2; //[0:4:1]
clamp_bolt_diameter_mm = 4; //[2:8:0.1]
clamp_bolt_head_diameter_mm = 7.5; //[5:12:0.1]
clamp_bolt_head_depth_mm = 3; //[1:6:0.1]
clamp_bolt_spacing_y_mm = 26; //[10:50:0.5]
clamp_bolt_offset_x_mm = 0; //[0:10:0.5]      // 0 = centered on housing

// Derived / sanity clamps
bearing_bore_depth_eff = min(bearing_bore_depth_mm, block_height_mm - 0.5);
retention_lip_depth_eff = min(retention_lip_depth_mm, bearing_bore_depth_eff - 0.5);
bearing_r = (bearing_outer_diameter_mm + bore_clearance_mm) / 2;
lip_r = bearing_r + retention_shoulder_mm;

base_thickness_eff = min(base_thickness_mm, block_height_mm - 2);
housing_height_eff = min(housing_height_mm, block_height_mm - base_thickness_eff);
housing_w_eff = min(housing_width_mm, block_width_mm - 2);
housing_l_eff = min(housing_length_mm, block_length_mm - 2);

clamp_slot_depth_eff = min(clamp_slot_depth_mm, housing_height_eff - 1);

// Helpers
module rounded_rect_prism(size=[40,68,12], r=2) {
    // size = [x,y,z], r = corner radius in XY
    r_eff = min(r, min(size[0], size[1]) / 2 - 0.01);
    linear_extrude(height=size[2], center=true)
        offset(r=r_eff)
            square([size[0] - 2*r_eff, size[1] - 2*r_eff], center=true);
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2, 0])
            cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true);
    }
}

module set_screw_holes() {
    // Two set screws from the long sides (±Y) into the bearing pocket
    if (set_screw_count > 0) {
        zc = block_height_mm/2 - set_screw_offset_from_top_mm;
        for (sy = [-1, 1]) {
            translate([0, sy*(block_length_mm/2 - set_screw_length_mm/2 + 0.01), zc])
                rotate([90, 0, 0])
                    cylinder(r=set_screw_diameter_mm/2, h=set_screw_length_mm + 2*overlap_mm, center=true);
        }
    }
}

module bearing_pocket_voids() {
    // Main bearing pocket from top face downward
    z_main = block_height_mm/2 - bearing_bore_depth_eff/2;
    translate([0, 0, z_main])
        cylinder(r=bearing_r, h=bearing_bore_depth_eff + 2*overlap_mm, center=true);

    // Retention counterbore/lip near the top face
    z_lip = block_height_mm/2 - retention_lip_depth_eff/2;
    translate([0, 0, z_lip])
        cylinder(r=lip_r, h=retention_lip_depth_eff + 2*overlap_mm, center=true);

    // Through shaft bore (8mm)
    translate([0, 0, 0])
        cylinder(r=shaft_diameter_mm/2 + bore_clearance_mm/2, h=block_height_mm + 2*overlap_mm, center=true);
}

module clamp_slot_void() {
    // Slot centered on X=0, runs along Y through housing, cuts down from top
    z_top = block_height_mm/2;
    z_slot_center = z_top - clamp_slot_depth_eff/2;
    translate([0, 0, z_slot_center])
        cube([housing_w_eff + 2*overlap_mm, housing_l_eff + 2*overlap_mm, clamp_slot_depth_eff + 2*overlap_mm], center=true);
}

module clamp_bolt_voids() {
    if (clamp_bolt_count > 0) {
        // Bolts go through X direction across the split clamp (left-to-right)
        // Place them on the raised housing, symmetric along Y.
        z_top = block_height_mm/2;
        z_bolt = z_top - clamp_slot_depth_eff/2; // centered in the clamp region
        y_positions =
            (clamp_bolt_count == 1) ? [0] :
            (clamp_bolt_count == 2) ? [-clamp_bolt_spacing_y_mm/2, clamp_bolt_spacing_y_mm/2] :
            (clamp_bolt_count == 3) ? [-clamp_bolt_spacing_y_mm, 0, clamp_bolt_spacing_y_mm] :
                                      [-1.5*clamp_bolt_spacing_y_mm, -0.5*clamp_bolt_spacing_y_mm, 0.5*clamp_bolt_spacing_y_mm, 1.5*clamp_bolt_spacing_y_mm];

        for (yy = y_positions) {
            // Through hole
            translate([0, yy, z_bolt])
                rotate([0, 90, 0])
                    cylinder(r=clamp_bolt_diameter_mm/2, h=block_width_mm + 2*overlap_mm, center=true);

            // Counterbore for head on +X side (typical clamp screw head)
            head_h = min(clamp_bolt_head_depth_mm, housing_w_eff/2);
            x_head_center = (housing_w_eff/2 - head_h/2) - 0.2; // keep inside housing
            translate([x_head_center + clamp_bolt_offset_x_mm, yy, z_bolt])
                rotate([0, 90, 0])
                    cylinder(r=clamp_bolt_head_diameter_mm/2, h=head_h + 2*overlap_mm, center=true);
        }
    }
}

module scs_long_bearing_block() {
    // ONE connected solid: base + raised housing, with subtracted features
    color([0.78, 0.78, 0.80])
    difference() {
        union() {
            // Base (40 x 68 footprint)
            translate([0, 0, -block_height_mm/2 + base_thickness_eff/2])
                rounded_rect_prism([block_width_mm, block_length_mm, base_thickness_eff], base_corner_r_mm);

            // Raised housing (centered), connected to base with slight overlap
            translate([0, 0, -block_height_mm/2 + base_thickness_eff + housing_height_eff/2 - 0.2])
                rounded_rect_prism([housing_w_eff, housing_l_eff, housing_height_eff], housing_corner_r_mm);
        }

        // Voids
        bearing_pocket_voids();
        mounting_holes();
        set_screw_holes();

        // Clamp split + clamp bolts (recognizable bearing block feature)
        clamp_slot_void();
        clamp_bolt_voids();
    }
}

scs_long_bearing_block();
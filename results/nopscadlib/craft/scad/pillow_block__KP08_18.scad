$fn = 96;

// Parameters
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
base_length_mm = 55.0; //[27.5:110.0:0.5]
base_width_mm = 42.0; //[21.0:84.0:0.5]
base_thickness_mm = 8.0; //[4.0:16.0:0.5]
overall_height_mm = 28.0; //[14.0:56.0:0.5]
housing_outer_diameter_mm = 28.0; //[14.0:56.0:0.5]
boss_outer_diameter_mm = 34.0; //[17.0:68.0:0.5]
mount_hole_spacing_mm = 40.0; //[20.0:80.0:0.5]
mount_hole_diameter_mm = 6.5; //[3.0:13.0:0.1]
mount_hole_edge_margin_mm = 7.5; //[4.0:15.0:0.5]
housing_length_mm = 42.0; //[21.0:84.0:0.5]
housing_width_mm = 26.0; //[13.0:52.0:0.5]
housing_base_overlap_mm = 1.0; //[0.5:2.0:0.1]
bore_clearance_mm = 0.2; //[0.0:0.6:0.05]
trapezoid_height_mm = 10.0; //[5.0:20.0:0.5]
trapezoid_base_mm = 16.0; //[8.0:32.0:0.5]
trapezoid_top_mm = 8.0; //[4.0:16.0:0.5]
trapezoid_thickness_mm = 10.0; //[5.0:20.0:0.5]

// Bearing insert visual detail (still one connected solid after subtraction)
insert_outer_d_mm = 16.0;   // typical for 8mm insert OD-ish (visual)
insert_length_mm  = 18.0;   // length along X (visual)
insert_lip_d_mm   = 18.5;   // small lip (visual)
insert_lip_len_mm = 2.0;    // lip length each side (visual)

// Small overlap to guarantee watertight unions
eps = 0.2;

// Right Trapezoid (extrudes along +Z when center=false)
module right_trapezoid() {
    linear_extrude(height=trapezoid_thickness_mm, center=true)
        polygon(points=[
            [0, 0],
            [trapezoid_base_mm, 0],
            [trapezoid_top_mm, trapezoid_height_mm],
            [0, trapezoid_height_mm]
        ]);
}

// Mount hole positions (through base thickness)
module kp_pillow_block_hole_positions() {
    // Keep holes inside base with margin and requested spacing
    hole_x = min(mount_hole_spacing_mm/2, base_length_mm/2 - mount_hole_edge_margin_mm);

    for (sx = [-1, 1])
        translate([sx*hole_x, 0, base_thickness_mm/2])
            cylinder(d=mount_hole_diameter_mm, h=base_thickness_mm + 2, center=true);
}

// Main solid (no holes/bore)
module kp_pillow_block_solid() {
    // Derived heights
    housing_block_h = max(0.1, overall_height_mm - base_thickness_mm + housing_base_overlap_mm);

    // Place housing center so it overlaps into base by housing_base_overlap_mm
    housing_center_z = base_thickness_mm + housing_block_h/2 - housing_base_overlap_mm;

    // Shaft axis height (center of housing cylinder) - keep within overall height
    shaft_axis_z = base_thickness_mm + (overall_height_mm - base_thickness_mm) * 0.55;

    // Gussets: connect housing to base on both sides (Y+ and Y-)
    gusset_z = base_thickness_mm + trapezoid_height_mm/2 - 1; // overlap into base
    gusset_y = housing_width_mm/2 + trapezoid_thickness_mm/2 - 1; // overlap into housing

    union() {
        // Base (exact 55 x 42 footprint)
        translate([0, 0, base_thickness_mm/2])
            cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);

        // Housing block (sits on base with overlap)
        translate([0, 0, housing_center_z])
            cube([housing_length_mm, housing_width_mm, housing_block_h], center=true);

        // Main housing cylinder (along X) - ensures recognizable pillow block profile
        translate([0, 0, shaft_axis_z])
            rotate([0, 90, 0])
                cylinder(d=housing_outer_diameter_mm, h=housing_length_mm + eps, center=true);

        // Raised boss cylinder (along X)
        translate([0, 0, shaft_axis_z])
            rotate([0, 90, 0])
                cylinder(d=boss_outer_diameter_mm, h=housing_length_mm * 0.55 + eps, center=true);

        // Gussets (4) near ends to resemble typical housing supports
        translate([ housing_length_mm/2 - trapezoid_base_mm/2 + 1,  gusset_y, gusset_z])
            right_trapezoid();
        translate([ housing_length_mm/2 - trapezoid_base_mm/2 + 1, -gusset_y, gusset_z])
            mirror([0,1,0]) right_trapezoid();

        translate([-housing_length_mm/2 + trapezoid_base_mm/2 - 1,  gusset_y, gusset_z])
            mirror([1,0,0]) right_trapezoid();
        translate([-housing_length_mm/2 + trapezoid_base_mm/2 - 1, -gusset_y, gusset_z])
            mirror([1,0,0]) mirror([0,1,0]) right_trapezoid();
    }
}

// Final assembly with mounting holes + 8.0mm shaft bore (+ clearance) + insert pocket detail
module kp_pillow_block_assembly() {
    shaft_axis_z = base_thickness_mm + (overall_height_mm - base_thickness_mm) * 0.55;

    // Ensure insert pocket stays within housing length
    insert_len = min(insert_length_mm, housing_length_mm - 2);
    lip_len = min(insert_lip_len_mm, max(0.5, (housing_length_mm - insert_len)/2 - 0.5));

    difference() {
        kp_pillow_block_solid();

        // Two mounting holes through base
        kp_pillow_block_hole_positions();

        // Shaft bore (along X)
        translate([0, 0, shaft_axis_z])
            rotate([0, 90, 0])
                cylinder(d=shaft_diameter_mm + bore_clearance_mm,
                         h=base_length_mm + 2, center=true);

        // Bearing insert pocket (visual detail): larger bore section centered in boss
        translate([0, 0, shaft_axis_z])
            rotate([0, 90, 0])
                cylinder(d=insert_outer_d_mm, h=insert_len + eps, center=true);

        // Small lips on both sides of insert pocket (visual)
        for (sx = [-1, 1]) {
            translate([sx*(insert_len/2 + lip_len/2 - 0.2), 0, shaft_axis_z])
                rotate([0, 90, 0])
                    cylinder(d=insert_lip_d_mm, h=lip_len + eps, center=true);
        }
    }
}

kp_pillow_block_assembly();
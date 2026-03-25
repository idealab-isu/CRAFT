$fn = 32;

// Parameters (KP08-style pillow block, simplified but dimensionally verifiable)
shaft_diameter_mm = 8.0;                 // bore
base_length_mm = 55.0;                   // X
base_width_mm  = 42.0;                   // Y
base_thickness_mm = 8.0;                 // Z

shaft_centerline_height_mm = 18.0;       // from base bottom to shaft axis

housing_outer_diameter_mm = 28.0;        // main round housing OD
housing_length_mm = 24.0;                // along Y (bearing width)

mounting_hole_diameter_mm = 6.0;         // through holes
mounting_hole_center_distance_mm = 42.0; // along X

// Typical KP08-ish details (simplified)
mount_pad_diameter_mm = 12.0;            // pad around mounting holes (visual)
mount_pad_height_mm = 2.0;               // raised pad height

cap_height_mm = 22.0;                    // height of housing "cap" above base top
cap_width_extra_mm = 10.0;               // extra width beyond round housing (gives KP look)
cap_length_extra_mm = 10.0;              // extra length beyond housing length

web_top_width_x_mm = 18.0;               // width near housing
connection_overlap_mm = 0.2;             // small overlap for watertight unions (keep tiny)

// Helpers
base_top_z() = base_thickness_mm/2;
shaft_axis_z() = -base_thickness_mm/2 + shaft_centerline_height_mm;

module kp08_pillow_block() {

    // Precompute a few dims to avoid accidental negative heights
    cap_h = cap_height_mm;
    cap_y = housing_length_mm + cap_length_extra_mm;
    cap_x = housing_outer_diameter_mm + cap_width_extra_mm;

    // Web: from base top up toward housing (keep conservative and always positive)
    web_h = max(1.0, shaft_axis_z() - base_top_z() - housing_outer_diameter_mm*0.20);
    web_z = base_top_z() + web_h/2 - connection_overlap_mm;

    // Side feet (simplified: blocks)
    foot_h = base_thickness_mm*0.65;
    foot_y = base_width_mm*0.92;
    foot_x = max(2.0, (base_length_mm - mounting_hole_center_distance_mm)/2);

    difference() {
        union() {
            // Base
            cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);

            // Raised mounting pads
            for (sx = [-1, 1]) {
                translate([sx*mounting_hole_center_distance_mm/2, 0,
                           base_thickness_mm/2 + mount_pad_height_mm/2 - connection_overlap_mm])
                    cylinder(d=mount_pad_diameter_mm, h=mount_pad_height_mm, center=true);
            }

            // Main round housing (axis along Y)
            translate([0, 0, shaft_axis_z()])
                rotate([90, 0, 0])
                    cylinder(d=housing_outer_diameter_mm, h=housing_length_mm, center=true);

            // Housing cap block (simplified)
            translate([0, 0, base_top_z() + cap_h/2 - connection_overlap_mm])
                cube([cap_x, cap_y, cap_h], center=true);

            // Central support web (single block)
            translate([0, 0, web_z])
                cube([web_top_width_x_mm, housing_length_mm*0.95, web_h], center=true);

            // Side feet
            for (sx = [-1, 1]) {
                translate([sx*(mounting_hole_center_distance_mm/2), 0, -base_thickness_mm/2 + foot_h/2])
                    cube([foot_x, foot_y, foot_h], center=true);
            }
        }

        // Shaft bore (through the housing along Y)
        translate([0, 0, shaft_axis_z()])
            rotate([90, 0, 0])
                cylinder(d=shaft_diameter_mm, h=base_width_mm + 2*(housing_length_mm + 10), center=true);

        // Mounting holes (through base)
        for (sx = [-1, 1]) {
            translate([sx*mounting_hole_center_distance_mm/2, 0, 0])
                cylinder(d=mounting_hole_diameter_mm,
                         h=base_thickness_mm + 2*(mount_pad_height_mm + 2),
                         center=true);
        }

        // Shallow relief pocket on top of base under the housing
        pocket_h = 1.2;
        translate([0, 0, base_thickness_mm/2 - pocket_h/2 + connection_overlap_mm])
            cube([housing_outer_diameter_mm*0.95, housing_length_mm*1.05, pocket_h], center=true);
    }
}

kp08_pillow_block();
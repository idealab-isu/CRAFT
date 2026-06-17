// Shaft support bracket for 12.0mm rod, 23.0mm tall
// One connected solid (bracket only)

// Parameters
rod_diameter_mm = 12.0; //[6.0:24.0:0.1]
overall_height_mm = 23.0; //[12.0:46.0:0.1]
rod_fit_clearance_mm = 0.2; //[0.0:0.6:0.05]
bracket_wall_thickness_mm = 4.0; //[2.0:8.0:0.1]
base_thickness_mm = 6.0; //[3.0:12.0:0.1]
base_length_mm = 40.0; //[20.0:80.0:0.1]
base_width_mm = 20.0; //[10.0:40.0:0.1]
mount_hole_diameter_mm = 5.0; //[3.0:8.0:0.1]
mount_hole_edge_margin_mm = 6.0; //[3.0:12.0:0.1]
rod_center_height_from_base_mm = 17.0; //[10.0:30.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 64;

module bracket() {
    // Derived
    rod_r = (rod_diameter_mm + rod_fit_clearance_mm)/2;
    outer_r = rod_r + bracket_wall_thickness_mm;

    // Clamp rod center so the outer cylinder stays within overall height
    rod_center_z = min(
        max(rod_center_height_from_base_mm, outer_r),
        overall_height_mm - outer_r
    );

    // Base spans full height (as in reference views: a vertical plate with two holes)
    base_center_z = overall_height_mm/2;

    // Rod sleeve centered on rod axis, spans the plate thickness (Y)
    sleeve_h = base_width_mm;

    difference() {
        union() {
            // Vertical plate (mounting bracket)
            translate([0, 0, base_center_z])
                cube([base_length_mm, base_width_mm, overall_height_mm], center=true);

            // Rod sleeve (adds material around the rod bore), connected by overlap
            translate([0, 0, rod_center_z])
                rotate([90, 0, 0])
                    cylinder(r=outer_r, h=sleeve_h + 2*overlap_mm, center=true);
        }

        // Mount holes through plate thickness (Y direction)
        for (xpos = [-base_length_mm/2 + mount_hole_edge_margin_mm,
                      base_length_mm/2 - mount_hole_edge_margin_mm]) {
            translate([xpos, 0, base_center_z])
                rotate([90, 0, 0])
                    cylinder(r=mount_hole_diameter_mm/2,
                             h=base_width_mm + 2*overlap_mm,
                             center=true);
        }

        // Rod bore through sleeve (Y direction)
        translate([0, 0, rod_center_z])
            rotate([90, 0, 0])
                cylinder(r=rod_r, h=sleeve_h + 4*overlap_mm, center=true);
    }
}

bracket();
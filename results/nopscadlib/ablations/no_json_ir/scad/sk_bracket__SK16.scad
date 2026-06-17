// Parameters
rod_diameter = 16.0;
bracket_height = 27.0;
base_thickness = 5.0;
base_length = 40.0;
base_width = 20.0;
mounting_hole_diameter = 4.0;
mounting_hole_offset = 10.0;
clamp_thickness = 5.0;
clamp_height = bracket_height - base_thickness;
clamp_width = rod_diameter + 2 * clamp_thickness;
set_screw_diameter = 3.0;
set_screw_offset = 5.0;

// Base mount block
module base_mount_block() {
    difference() {
        cube([base_length, base_width, base_thickness]);
        translate([mounting_hole_offset, base_width / 2, 0])
            cylinder(h = base_thickness + 1, d = mounting_hole_diameter, center = true);
        translate([base_length - mounting_hole_offset, base_width / 2, 0])
            cylinder(h = base_thickness + 1, d = mounting_hole_diameter, center = true);
    }
}

// Rod cradle or clamp
module rod_cradle_or_clamp() {
    translate([base_length / 2, base_width / 2, base_thickness])
        difference() {
            union() {
                translate([-clamp_width / 2, -clamp_thickness / 2, 0])
                    cube([clamp_width, clamp_thickness, clamp_height]);
                translate([-clamp_thickness / 2, -clamp_width / 2, 0])
                    cube([clamp_thickness, clamp_width, clamp_height]);
            }
            translate([0, 0, 0])
                cylinder(h = clamp_height, d = rod_diameter, center = true);
        }
}

// Rod retention feature (set screw boss)
module rod_retention_feature() {
    translate([base_length / 2, base_width / 2, base_thickness + clamp_height / 2])
        rotate([90, 0, 0])
            cylinder(h = clamp_thickness, d = set_screw_diameter, center = true);
}

// Fillets or chamfers
module fillets_or_chamfers() {
    // Example chamfer on the base edges
    translate([0, 0, 0])
        hull() {
            translate([0, 0, base_thickness])
                sphere(r = 2);
            translate([base_length, 0, base_thickness])
                sphere(r = 2);
            translate([0, base_width, base_thickness])
                sphere(r = 2);
            translate([base_length, base_width, base_thickness])
                sphere(r = 2);
        }
}

// Rod (for visualization)
module rod() {
    translate([base_length / 2, base_width / 2, base_thickness + clamp_height / 2])
        cylinder(h = 100, d = rod_diameter, center = true);
}

// Assemble the bracket
module shaft_support_bracket() {
    base_mount_block();
    rod_cradle_or_clamp();
    rod_retention_feature();
    fillets_or_chamfers();
}

// Render the model
shaft_support_bracket();
// Uncomment the following line to visualize the rod
// rod();
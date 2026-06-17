$fn = 96;

// Parameters
rod_diameter = 12.0;
bracket_height = 23.0;

base_thickness = 5.0;
base_length = 40.0;
base_width  = 20.0;

mounting_hole_diameter = 4.0;
mounting_hole_offset_x = 10.0;   // from center along length
mounting_hole_offset_y = 6.0;    // from center along width

clamp_thickness = 3.0;           // top cap thickness
wall = 4.0;                      // material around rod
overlap = 0.2;                   // small overlap for robust unions/differences

// Derived
rod_r   = rod_diameter/2;
outer_r = rod_r + wall;

// Ensure total height matches bracket_height exactly
cradle_h = bracket_height - base_thickness - clamp_thickness;

// Rod axis along Y, placed near one end in X, centered in Z within cradle
rod_center_x = -(base_length/2 - outer_r);
rod_center_z = base_thickness + cradle_h/2;

// Base block with mounting holes
module base_block() {
    difference() {
        translate([0, 0, base_thickness/2])
            cube([base_length, base_width, base_thickness], center=true);

        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*mounting_hole_offset_x, sy*mounting_hole_offset_y, base_thickness/2])
                cylinder(h=base_thickness + 2*overlap, d=mounting_hole_diameter, center=true);
    }
}

// Cradle body with rod cutout
module rod_support_cradle() {
    difference() {
        // Cradle sits directly on top of base and ends just below the cap
        translate([0, 0, base_thickness + cradle_h/2 - overlap])
            cube([base_length, base_width, cradle_h + 2*overlap], center=true);

        // Rod cutout (axis along Y)
        translate([rod_center_x, 0, rod_center_z])
            rotate([90, 0, 0])
                cylinder(h=base_width + 2*overlap, r=rod_r, center=true);
    }
}

// Top retention cap (connected to cradle with slight overlap)
module rod_retention_feature() {
    translate([0, 0, base_thickness + cradle_h + clamp_thickness/2 - overlap])
        cube([base_length, base_width, clamp_thickness + 2*overlap], center=true);
}

// Assemble the bracket as ONE connected solid
module shaft_support_bracket() {
    union() {
        base_block();
        rod_support_cradle();
        rod_retention_feature();
    }
}

shaft_support_bracket();
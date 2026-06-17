module rectangular_tube() {
    outer_length = 0.8;
    outer_width = 0.3;
    outer_height = 0.3;
    wall_thickness = 0.05;
    
    inner_length = outer_length - 2 * wall_thickness;
    inner_width = outer_width - 2 * wall_thickness;
    inner_height = outer_height - 2 * wall_thickness;
    
    difference() {
        cube([outer_length, outer_width, outer_height], center = true);
        translate([0, 0, 0])
            cube([inner_length, inner_width, inner_height], center = true);
    }
}

rectangular_tube();
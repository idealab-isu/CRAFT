module ht_pipe_segment(length = 2000, outer_diameter = 125, wall_thickness = 3.2) {
    difference() {
        cylinder(h = length, d = outer_diameter, $fn = 100);
        translate([0, 0, -1])
            cylinder(h = length + 2, d = outer_diameter - 2 * wall_thickness, $fn = 100);
    }
}

module integrated_end_fitting(outer_diameter = 125, wall_thickness = 3.2, fitting_length = 50) {
    difference() {
        cylinder(h = fitting_length, d = outer_diameter + 10, $fn = 100);
        translate([0, 0, -1])
            cylinder(h = fitting_length + 2, d = outer_diameter - 2 * wall_thickness, $fn = 100);
    }
}

module ht_pipe() {
    ht_pipe_segment();
    translate([0, 0, 2000])
        integrated_end_fitting();
}

ht_pipe();
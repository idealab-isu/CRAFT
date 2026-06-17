module ht_pipe_segment(length, diameter, wall_thickness) {
    difference() {
        cylinder(h=length, d=diameter, $fn=100);
        translate([0, 0, -1])
            cylinder(h=length + 2, d=diameter - 2 * wall_thickness, $fn=100);
    }
}

module integrated_end_fitting(diameter, wall_thickness, fitting_length) {
    union() {
        cylinder(h=fitting_length, d=diameter, $fn=100);
        translate([0, 0, -1])
            cylinder(h=fitting_length + 2, d=diameter - 2 * wall_thickness, $fn=100);
    }
}

module ht_pipe(length, diameter, wall_thickness, fitting_length) {
    union() {
        ht_pipe_segment(length - 2 * fitting_length, diameter, wall_thickness);
        translate([0, 0, length - fitting_length])
            integrated_end_fitting(diameter, wall_thickness, fitting_length);
        rotate([0, 180, 0])
            integrated_end_fitting(diameter, wall_thickness, fitting_length);
    }
}

ht_pipe(length=1500, diameter=32, wall_thickness=2, fitting_length=20);
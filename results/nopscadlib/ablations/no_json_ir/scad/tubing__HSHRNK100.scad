// Parameters for the heatshrink tubing
module heatshrink_tubing_body(outer_diameter, inner_diameter, length) {
    difference() {
        cylinder(h = length, d = outer_diameter, $fn = 100);
        translate([0, 0, -1])
            cylinder(h = length + 2, d = inner_diameter, $fn = 100);
    }
}

// Optional path sweep
module optional_path_sweep(path_points, outer_diameter, inner_diameter) {
    sweep() {
        path(path_points);
        profile() {
            difference() {
                circle(d = outer_diameter, $fn = 100);
                circle(d = inner_diameter, $fn = 100);
            }
        }
    }
}

// Main tubing module
module tubing(outer_diameter, inner_diameter, length, path_points = []) {
    if (len(path_points) > 0) {
        optional_path_sweep(path_points, outer_diameter, inner_diameter);
    } else {
        heatshrink_tubing_body(outer_diameter, inner_diameter, length);
    }
}

// Example sleeved resistor
module sleeved_resistor(resistor_length, resistor_diameter, tubing_outer_diameter, tubing_inner_diameter, tubing_length, path_points = []) {
    translate([0, 0, -resistor_length / 2])
        cylinder(h = resistor_length, d = resistor_diameter, $fn = 100);
    translate([0, 0, -tubing_length / 2])
        tubing(tubing_outer_diameter, tubing_inner_diameter, tubing_length, path_points);
}

// Example usage
sleeved_resistor(10, 2, 5, 3, 15, [[0, 0, 0], [0, 0, 15]]);
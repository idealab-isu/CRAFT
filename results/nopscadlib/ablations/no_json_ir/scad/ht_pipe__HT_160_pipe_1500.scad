// Define the HT pipe vitamin component
module ht_pipe_body(diameter, length) {
    cylinder(h=length, d=diameter, $fn=100);
}

module pipe_end_fitting_geometry(diameter, thickness) {
    difference() {
        cylinder(h=thickness, d=diameter, $fn=100);
        translate([0, 0, -1])
            cylinder(h=thickness + 2, d=diameter - 10, $fn=100);
    }
}

module ht_pipe(diameter, length, end_thickness) {
    union() {
        ht_pipe_body(diameter, length);
        translate([0, 0, length])
            pipe_end_fitting_geometry(diameter, end_thickness);
        pipe_end_fitting_geometry(diameter, end_thickness);
    }
}

// Parameters for HT 160 pipe
ht_pipe_diameter = 160;
ht_pipe_length = 1500;
end_fitting_thickness = 20;

// Create the HT pipe model
ht_pipe(ht_pipe_diameter, ht_pipe_length, end_fitting_thickness);
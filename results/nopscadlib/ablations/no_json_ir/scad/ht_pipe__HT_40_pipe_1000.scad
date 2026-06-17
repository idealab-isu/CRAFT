// Define the HT pipe parameters
module ht_pipe_segment(length) {
    ht_pipe(length);
    integrated_end_fitting();
}

// Define the HT pipe geometry
module ht_pipe(length) {
    // HT 40 pipe dimensions
    outer_diameter = 40; // Outer diameter in mm
    wall_thickness = 1.8; // Wall thickness in mm
    inner_diameter = outer_diameter - 2 * wall_thickness;
    
    // Create the pipe
    difference() {
        cylinder(h = length, d = outer_diameter, $fn = 100);
        translate([0, 0, -1])
            cylinder(h = length + 2, d = inner_diameter, $fn = 100);
    }
}

// Define the integrated end fitting
module integrated_end_fitting() {
    // End fitting dimensions
    fitting_length = 20; // Length of the fitting in mm
    fitting_diameter = 42; // Diameter of the fitting in mm
    
    // Create the end fitting
    translate([0, 0, -fitting_length])
        cylinder(h = fitting_length, d = fitting_diameter, $fn = 100);
}

// Create the HT pipe segment with a length of 1000 mm
ht_pipe_segment(1000);
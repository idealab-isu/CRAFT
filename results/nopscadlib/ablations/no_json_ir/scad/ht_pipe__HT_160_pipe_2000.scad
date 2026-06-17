// HT 160 PVC Pipe Segment with a length of 2000 mm

// Parameters
pipe_diameter = 160; // Outer diameter in mm
pipe_thickness = 3.2; // Wall thickness in mm
pipe_length = 2000; // Length of the pipe in mm
fitting_length = 50; // Length of the integrated end fitting in mm

// Function to create the main pipe body
module ht_pipe_body() {
    difference() {
        cylinder(h = pipe_length, d = pipe_diameter, $fn=100);
        translate([0, 0, -1])
            cylinder(h = pipe_length + 2, d = pipe_diameter - 2 * pipe_thickness, $fn=100);
    }
}

// Function to create the integrated end fitting
module integrated_end_fitting() {
    translate([0, 0, pipe_length - fitting_length])
        difference() {
            cylinder(h = fitting_length, d = pipe_diameter, $fn=100);
            translate([0, 0, -1])
                cylinder(h = fitting_length + 2, d = pipe_diameter - 2 * pipe_thickness, $fn=100);
        }
}

// Main module to create the HT pipe
module ht_pipe() {
    ht_pipe_body();
    integrated_end_fitting();
}

// Render the HT pipe
ht_pipe();
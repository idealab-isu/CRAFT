// Parameters for HT 50 pipe
pipe_diameter = 50; // Outer diameter in mm
pipe_thickness = 2; // Wall thickness in mm
pipe_length = 2000; // Length in mm

// Function to create the main body of the HT pipe
module ht_pipe_body() {
    difference() {
        cylinder(h = pipe_length, d = pipe_diameter, $fn=100);
        translate([0, 0, -1])
            cylinder(h = pipe_length + 2, d = pipe_diameter - 2 * pipe_thickness, $fn=100);
    }
}

// Function to create the end fitting geometry
module end_fitting_geometry() {
    translate([0, 0, pipe_length])
        cylinder(h = 10, d = pipe_diameter + 10, $fn=100);
}

// Main module to assemble the HT pipe
module ht_pipe() {
    ht_pipe_body();
    end_fitting_geometry();
}

// Render the HT pipe
ht_pipe();
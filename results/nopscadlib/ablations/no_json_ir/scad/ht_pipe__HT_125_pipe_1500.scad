// Define HT 125 pipe dimensions
outer_diameter = 125; // Outer diameter in mm
wall_thickness = 3.2; // Wall thickness in mm for HT 125
length = 1500; // Length of the pipe in mm

// Function to create a hollow cylinder (pipe)
module ht_pipe_segment(outer_diameter, wall_thickness, length) {
    difference() {
        cylinder(d=outer_diameter, h=length, center=false);
        cylinder(d=outer_diameter - 2 * wall_thickness, h=length + 1, center=false);
    }
}

// Optional end fitting geometry
module end_fitting_geometry(outer_diameter, wall_thickness) {
    // Example end fitting: simple flange
    flange_thickness = 10; // Thickness of the flange
    flange_diameter = outer_diameter + 20; // Diameter of the flange

    translate([0, 0, -flange_thickness])
    cylinder(d=flange_diameter, h=flange_thickness, center=false);
}

// Main module to create the HT pipe with optional end fitting
module ht_pipe() {
    ht_pipe_segment(outer_diameter, wall_thickness, length);
    end_fitting_geometry(outer_diameter, wall_thickness);
}

// Render the HT pipe
ht_pipe();
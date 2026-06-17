// HT 110 pipe specifications
module ht_pipe_segment(length = 2000) {
    ht_pipe(length);
    integrated_end_fitting();
}

// HT 110 pipe module
module ht_pipe(length) {
    outer_diameter = 110; // Outer diameter for HT 110
    wall_thickness = 3.2; // Typical wall thickness for HT 110
    inner_diameter = outer_diameter - 2 * wall_thickness;
    
    difference() {
        cylinder(h = length, d = outer_diameter, $fn = 100);
        translate([0, 0, -1]) // Slightly extend inner cylinder for clean subtraction
            cylinder(h = length + 2, d = inner_diameter, $fn = 100);
    }
}

// Integrated end fitting module
module integrated_end_fitting() {
    outer_diameter = 110; // Outer diameter for HT 110
    fitting_length = 50; // Typical length for end fitting
    fitting_thickness = 4; // Typical thickness for end fitting
    
    translate([0, 0, -fitting_length])
        difference() {
            cylinder(h = fitting_length, d = outer_diameter + 2 * fitting_thickness, $fn = 100);
            translate([0, 0, -1]) // Slightly extend inner cylinder for clean subtraction
                cylinder(h = fitting_length + 2, d = outer_diameter, $fn = 100);
        }
}

// Render the HT 110 pipe segment
ht_pipe_segment();
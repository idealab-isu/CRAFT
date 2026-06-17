module ht_pipe_segment() {
    hollow_bore(250);
    end_fitting();
}

module hollow_bore(length) {
    outer_diameter = 125; // Outer diameter for HT 125
    wall_thickness = 3.2; // Typical wall thickness for HT 125
    inner_diameter = outer_diameter - 2 * wall_thickness;
    
    difference() {
        cylinder(h = length, d = outer_diameter, $fn=100);
        translate([0, 0, -1]) // Slightly extend inner cylinder for clean subtraction
            cylinder(h = length + 2, d = inner_diameter, $fn=100);
    }
}

module end_fitting() {
    fitting_length = 20; // Typical length for end fitting
    fitting_diameter = 130; // Slightly larger than outer diameter for fitting
    
    translate([0, 0, 250 - fitting_length]) // Position at the end of the pipe
        cylinder(h = fitting_length, d1 = fitting_diameter, d2 = outer_diameter, $fn=100);
}

ht_pipe_segment();
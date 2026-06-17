// Parameters
ring_outer_diameter = 20;
ring_thickness = 2;
mounting_hole_diameter = 8;
tongue_length = 30;
tongue_width = 10;
tongue_thickness = 2;
wire_entry_diameter = 5;

// Ring body
module ring_body() {
    difference() {
        cylinder(d=ring_outer_diameter, h=ring_thickness, center=true);
        cylinder(d=mounting_hole_diameter, h=ring_thickness + 1, center=true);
    }
}

// Wire termination section (tongue)
module wire_termination_section() {
    translate([0, tongue_length/2, 0])
    cube([tongue_width, tongue_length, tongue_thickness], center=true);
}

// Transition fillet or hull between ring and tongue
module transition_fillet() {
    hull() {
        translate([0, ring_outer_diameter/2, 0])
        cylinder(d=ring_outer_diameter, h=ring_thickness, center=true);
        translate([0, tongue_length/2, 0])
        cube([tongue_width, tongue_length, tongue_thickness], center=true);
    }
}

// Optional wire entry hole or slot in tongue
module wire_entry_hole() {
    translate([0, tongue_length/2, 0])
    cylinder(d=wire_entry_diameter, h=tongue_thickness + 1, center=true);
}

// Complete ring terminal assembly
module ring_terminal_assembly() {
    union() {
        ring_body();
        wire_termination_section();
        transition_fillet();
        wire_entry_hole();
    }
}

// Render the ring terminal
ring_terminal_assembly();
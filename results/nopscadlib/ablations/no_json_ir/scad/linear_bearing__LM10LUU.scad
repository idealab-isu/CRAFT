$fn = 128;

// Target dimensions (mm)
outer_diameter = 19.0;   // OD
inner_diameter = 10.0;   // bore (through)
length         = 55.0;   // overall length

// Simple external features to resemble a long linear bearing
groove_depth   = 0.6;    // radial depth of outer grooves
groove_width   = 1.2;    // axial width of each groove
groove_offset  = 3.0;    // distance from each end to groove center
chamfer_len    = 0.8;    // end chamfer length (axial)

// Small epsilon for robust booleans
eps = 0.02;

module bearing_body() {
    // Outer cylinder with end chamfers and two shallow outer grooves
    difference() {
        // Base OD cylinder
        cylinder(d=outer_diameter, h=length, center=true);

        // End chamfers (remove small cones at both ends)
        for (s = [-1, 1]) {
            translate([0, 0, s*(length/2 - chamfer_len/2)])
                cylinder(h=chamfer_len + eps, center=true,
                         d1=outer_diameter + 2*chamfer_len, d2=outer_diameter);
        }

        // Outer grooves near ends (shallow ring cuts)
        for (s = [-1, 1]) {
            translate([0, 0, s*(length/2 - groove_offset)])
                cylinder(d=outer_diameter + eps, h=groove_width, center=true);

            translate([0, 0, s*(length/2 - groove_offset)])
                cylinder(d=outer_diameter - 2*groove_depth, h=groove_width + eps, center=true);
        }
    }
}

module through_bore() {
    // Through-hole for 10mm shaft
    cylinder(d=inner_diameter, h=length + 2*eps, center=true);
}

module linear_bearing() {
    // ONE connected solid: outer body minus through bore
    difference() {
        bearing_body();
        through_bore();
    }
}

linear_bearing();
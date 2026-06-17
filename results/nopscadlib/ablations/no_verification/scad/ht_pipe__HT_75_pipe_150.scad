// HT 75 pipe, length 150 mm (single connected solid)

// Parameters
nominal_size = 75; //[40:160:1]
length_mm = 150; //[75:300:1]
ht75_outer_diameter = 75; //[60:90:0.5]
ht75_wall_thickness = 2.7; //[1.5:5.5:0.1]
interface_ring_length = 18; //[8:40:1]
interface_ring_radial_thickness = 2.0; //[0.8:6.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

$fn = 128;

module ht_pipe() {
    outer_r = ht75_outer_diameter/2;
    inner_r = outer_r - ht75_wall_thickness;
    inner_r_safe = max(0.01, inner_r);

    // Place ring at one end, overlapping into the main pipe so it's connected
    ring_center_z = (length_mm/2) - (interface_ring_length/2) + overlap;

    color([0.85, 0.85, 0.8])
    difference() {
        // Outer solid: main pipe + outer ring (connected via overlap)
        union() {
            cylinder(h=length_mm, r=outer_r, center=true);

            translate([0, 0, ring_center_z])
                cylinder(h=interface_ring_length, r=outer_r + interface_ring_radial_thickness, center=true);
        }

        // Inner bore: remove through entire length including ring
        cylinder(h=length_mm + interface_ring_length + 6*overlap, r=inner_r_safe, center=true);
    }
}

ht_pipe();
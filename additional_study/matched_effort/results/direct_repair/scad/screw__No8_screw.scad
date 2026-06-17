$fn = 128;

// Pan head screw (simplified, no threads)
// Dimensions from description:
d_shank = 4.2;      // mm
L = 10;             // mm (overall length)
d_head = 8.2;       // mm
h_head = 3.05;      // mm

// Simple pan head profile parameters (approximation)
h_cyl = h_head * 0.55;          // cylindrical portion of head
h_dome = h_head - h_cyl;        // domed portion
d_top = d_head * 0.92;          // slightly smaller top diameter for dome

module pan_head_screw() {
    union() {
        // Shank
        cylinder(d = d_shank, h = L - h_head);

        // Head (placed on top of shank)
        translate([0,0,L - h_head]) {
            union() {
                // Cylindrical base of head
                cylinder(d = d_head, h = h_cyl);

                // Domed top (frustum to a smaller top diameter)
                translate([0,0,h_cyl])
                    cylinder(d1 = d_head, d2 = d_top, h = h_dome);
            }
        }
    }
}

pan_head_screw();
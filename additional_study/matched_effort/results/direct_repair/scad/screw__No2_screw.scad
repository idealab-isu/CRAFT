$fn = 96;

shaft_d = 2.2;
length = 10;

head_d = 4.2;
head_h = 1.7;

// Simple pan head approximation: cylindrical skirt + spherical cap
cap_r = head_d * 0.55;                 // cap sphere radius (tuned for pan-head look)
cap_center_z = head_h - cap_r;         // place sphere so top is rounded

module pan_head_screw() {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Head (pan)
        translate([0,0,length]) {
            intersection() {
                union() {
                    // cylindrical portion
                    cylinder(d = head_d, h = head_h);

                    // rounded top
                    translate([0,0,cap_center_z])
                        sphere(r = cap_r);
                }
                // limit to head height
                cylinder(d = head_d, h = head_h);
            }
        }
    }
}

pan_head_screw();
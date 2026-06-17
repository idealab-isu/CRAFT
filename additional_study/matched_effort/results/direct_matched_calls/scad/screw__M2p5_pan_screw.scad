$fn = 96;

// Dimensions (mm)
shaft_d = 2.5;
shaft_r = shaft_d/2;

length = 10;          // total length under head
head_d = 4.7;
head_r = head_d/2;
head_h = 1.7;

// Simple pan head profile (approximation)
module pan_head_screw() {
    union() {
        // Shaft (unthreaded approximation)
        cylinder(h = length, r = shaft_r);

        // Head: cylindrical skirt + domed top (spherical cap approximation)
        translate([0,0,length]) {
            union() {
                // Lower cylindrical portion of head
                skirt_h = head_h * 0.55;
                cylinder(h = skirt_h, r = head_r);

                // Domed top portion
                dome_h = head_h - skirt_h;
                // Use a sphere intersected with a cylinder to form a dome
                translate([0,0,skirt_h]) {
                    intersection() {
                        // Sphere sized to create a gentle dome
                        // Radius chosen so cap height ~= dome_h
                        sphere_r = (head_r*head_r + dome_h*dome_h) / (2*dome_h);
                        translate([0,0,sphere_r - dome_h]) sphere(r = sphere_r);
                        cylinder(h = dome_h, r = head_r);
                    }
                }
            }
        }
    }
}

pan_head_screw();
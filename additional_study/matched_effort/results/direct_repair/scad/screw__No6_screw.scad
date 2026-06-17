$fn = 96;

shaft_d = 3.5;
length = 10;

head_d = 6.7;
head_h = 2.2;

// Simple pan head approximation: cylindrical head with a rounded top
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Head (cyl + dome)
        translate([0,0,length]) {
            union() {
                // Straight side portion
                cylinder(d = head_d, h = head_h*0.55);

                // Rounded top (spherical cap via intersection)
                translate([0,0,head_h*0.55])
                intersection() {
                    // Bounding cylinder for cap height
                    cylinder(d = head_d, h = head_h*0.45);
                    // Sphere to create dome
                    translate([0,0,head_d*0.35])
                        sphere(d = head_d);
                }
            }
        }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);
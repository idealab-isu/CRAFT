$fn = 96;

shaft_d = 2.5;
length = 10;

head_d = 4.7;
head_h = 1.7;

// Simple pan head approximation: cylindrical head with a rounded top
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Head (cylinder + spherical cap)
        translate([0,0,length]) {
            union() {
                cylinder(d = head_d, h = head_h*0.55);

                // Rounded top via intersection of sphere and a limiting cylinder
                translate([0,0,head_h*0.55])
                intersection() {
                    // Sphere sized to give a gentle dome
                    sphere(d = head_d);
                    // Limit to upper portion to form a cap
                    translate([0,0,-head_d/2])
                        cylinder(d = head_d, h = head_h*0.45 + head_d/2);
                }
            }
        }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);
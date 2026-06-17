$fn = 96;

shaft_d = 3.0;
length = 10.0;

head_d = 5.5;
head_h = 2.0;

// Simple pan head approximation: cylindrical head with a rounded top
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Head: cylinder + spherical cap (intersection) for rounded top
        translate([0,0,length])
        union() {
            cylinder(d = head_d, h = head_h * 0.65);

            // Rounded top cap
            translate([0,0,head_h * 0.65])
            intersection() {
                // Sphere sized to create a gentle dome
                sphere(d = head_d);
                // Keep only the upper portion as a cap
                translate([-head_d, -head_d, 0])
                    cube([2*head_d, 2*head_d, head_h]);
            }
        }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);
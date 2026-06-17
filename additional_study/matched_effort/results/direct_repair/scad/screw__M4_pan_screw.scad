$fn = 96;

// Parameters (mm)
shaft_d = 4.0;
length = 10.0;

head_d = 7.8;
head_h = 3.3;

// Simple pan head approximation: cylindrical head with a rounded top
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(h = length, d = shaft_d);

        // Head base cylinder
        translate([0,0,length])
            cylinder(h = head_h*0.65, d = head_d);

        // Rounded dome top (intersection of sphere and cylinder)
        translate([0,0,length + head_h*0.65])
            intersection() {
                // Sphere sized to create a gentle dome
                sphere(d = head_d);
                // Limit to upper portion to form dome height
                translate([0,0,-head_d/2])
                    cylinder(h = head_h*0.35 + head_d/2, d = head_d);
            }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);
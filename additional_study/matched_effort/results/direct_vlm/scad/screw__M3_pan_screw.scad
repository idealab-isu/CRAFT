$fn = 96;

shaft_d = 3.0;
length = 10.0;

head_d = 5.4;
head_h = 2.0;

// Simple pan head approximation: cylindrical head with a rounded top
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Head base cylinder
        translate([0,0,length])
            cylinder(d = head_d, h = head_h*0.55);

        // Rounded dome top (spherical cap approximation)
        translate([0,0,length + head_h*0.55])
            intersection() {
                sphere(d = head_d);
                translate([0,0,0])
                    cylinder(d = head_d, h = head_h*0.45);
            }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);
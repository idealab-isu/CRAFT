$fn = 96;

// Dimensions (mm)
shaft_d = 3.5;
length = 10;

head_d = 6.9;
head_h = 2.5;

// Simple pan head approximation: cylindrical head with a rounded top
module pan_head_screw(shaft_d, length, head_d, head_h) {
    union() {
        // Shaft
        cylinder(d = shaft_d, h = length);

        // Head base cylinder
        translate([0,0,length])
            cylinder(d = head_d, h = head_h * 0.65);

        // Rounded dome top (spherical cap approximation)
        translate([0,0,length + head_h * 0.65])
            intersection() {
                sphere(d = head_d);
                translate([0,0,0])
                    cylinder(d = head_d, h = head_h * 0.35);
            }
    }
}

pan_head_screw(shaft_d, length, head_d, head_h);
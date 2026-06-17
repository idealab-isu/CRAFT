$fn = 96;

shaft_d = 3.5;
length = 10;

head_d = 6.7;
head_h = 2.2;

// Simple pan head screw (no threads, no drive recess)
union() {
    // Shaft
    cylinder(h = length, d = shaft_d);

    // Pan head: cylindrical base + rounded dome
    translate([0,0,length]) {
        union() {
            // Cylindrical portion
            cylinder(h = head_h*0.55, d = head_d);

            // Rounded top (spherical cap approximation)
            translate([0,0,head_h*0.55])
                intersection() {
                    sphere(d = head_d);
                    cylinder(h = head_h*0.45, d = head_d);
                }
        }
    }
}
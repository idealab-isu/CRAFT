$fn = 96;

shaft_d = 3.5;
length = 10;

head_d = 6.7;
head_h = 2.2;

// Simple pan head screw (no threads, no drive recess)
union() {
    // Shaft
    cylinder(d = shaft_d, h = length);

    // Pan head: cylindrical base + rounded dome
    translate([0,0,length])
    union() {
        // Base cylinder
        cylinder(d = head_d, h = head_h * 0.55);

        // Rounded top (spherical cap approximation)
        translate([0,0,head_h * 0.55])
        intersection() {
            sphere(d = head_d);
            cylinder(d = head_d, h = head_h * 0.45);
        }
    }
}
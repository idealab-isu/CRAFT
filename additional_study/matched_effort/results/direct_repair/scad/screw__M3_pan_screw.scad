$fn = 96;

shaft_d = 3.0;
length = 10.0;

head_d = 5.4;
head_h = 2.0;

// Simple pan head screw (no threads, no drive recess)
union() {
    // Shaft
    cylinder(h = length, d = shaft_d);

    // Pan head: cylindrical base + rounded dome
    translate([0,0,length])
    union() {
        // Base cylinder
        cylinder(h = head_h*0.55, d = head_d);

        // Rounded top (spherical cap approximation)
        translate([0,0,head_h*0.55])
        intersection() {
            // Sphere sized to give a gentle dome
            sphere(d = head_d);
            // Keep only the upper portion to form the cap
            translate([-head_d, -head_d, 0])
                cube([2*head_d, 2*head_d, head_h*0.45], center = false);
        }
    }
}
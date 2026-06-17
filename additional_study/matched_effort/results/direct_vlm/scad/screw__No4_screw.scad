$fn = 96;

shaft_d = 3.0;
length = 10.0;

head_d = 5.5;
head_h = 2.0;

// Simple pan head screw (unthreaded shaft)
union() {
    // Shaft
    cylinder(d = shaft_d, h = length);

    // Pan head (approximated as a short cylinder with a rounded top)
    translate([0, 0, length])
    intersection() {
        // Base cylinder for head height
        cylinder(d = head_d, h = head_h);

        // Rounded top via sphere intersection
        translate([0, 0, head_h * 0.55])
            sphere(d = head_d);
    }
}
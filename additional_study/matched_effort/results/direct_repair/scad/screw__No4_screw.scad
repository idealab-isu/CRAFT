$fn = 96;

d_shaft = 3.0;
l_shaft = 10.0;

d_head = 5.5;
h_head = 2.0;

// Simple pan head screw (no threads, no drive recess)
union() {
    // Shaft
    cylinder(d = d_shaft, h = l_shaft);

    // Pan head: cylindrical base + domed top
    translate([0, 0, l_shaft])
    union() {
        // Base cylinder (about half the head height)
        cylinder(d = d_head, h = h_head * 0.55);

        // Dome (spherical cap) to reach total head height
        translate([0, 0, h_head * 0.55])
        intersection() {
            sphere(d = d_head);
            cylinder(d = d_head, h = h_head * 0.45);
        }
    }
}
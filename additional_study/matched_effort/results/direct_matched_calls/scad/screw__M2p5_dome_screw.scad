$fn = 96;

// Dimensions (mm)
shaft_d = 2.5;
shaft_r = shaft_d/2;
length  = 10;

head_d = 5.35;
head_r = head_d/2;
head_h = 1.6;

// Simple dome-head screw (no threads, no drive recess)
union() {
    // Shaft
    cylinder(h = length, r = shaft_r);

    // Dome head: spherical cap sitting on top of shaft
    // Sphere radius chosen so that cap height = head_h and base radius = head_r
    // R = (a^2 + h^2) / (2h)
    a = head_r;
    h = head_h;
    R = (a*a + h*h) / (2*h);
    zc = length + h - R; // sphere center z

    intersection() {
        translate([0,0,zc]) sphere(r = R);
        translate([-head_r, -head_r, length])
            cube([2*head_r, 2*head_r, head_h], center = false);
    }
}
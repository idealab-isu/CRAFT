$fn = 96;

thread_d = 3.0;      // nominal thread diameter (mm)
length = 20.0;       // overall length (mm)
outer_d = 8.0;       // standoff outer diameter (mm)

difference() {
    cylinder(d = outer_d, h = length);
    translate([0, 0, -0.2])
        cylinder(d = thread_d, h = length + 0.4);
}
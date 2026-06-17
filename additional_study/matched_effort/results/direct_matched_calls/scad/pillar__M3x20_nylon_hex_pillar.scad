$fn = 96;

thread_d = 3.0;      // mm (nominal)
length = 20.0;       // mm
outer_d = 6.0;       // mm (fallback since diameter was "None")
hole_clearance = 0.2; // mm added to thread diameter for a simple clearance hole

difference() {
    cylinder(h = length, d = outer_d);
    translate([0, 0, -0.1])
        cylinder(h = length + 0.2, d = thread_d + hole_clearance);
}
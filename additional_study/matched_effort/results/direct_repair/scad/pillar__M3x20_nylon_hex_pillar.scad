$fn = 96;

thread_d = 3.0;      // mm (nominal)
length = 20.0;       // mm
outer_d = 6.0;       // mm (fallback since diameter was "None")

difference() {
  cylinder(d = outer_d, h = length);
  translate([0, 0, -0.2])
    cylinder(d = thread_d, h = length + 0.4);
}
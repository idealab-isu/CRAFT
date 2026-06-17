$fn = 96;

thread_d = 2.0;      // mm (nominal)
length   = 16.0;     // mm
outer_d  = 3.17;     // mm

difference() {
  cylinder(h = length, d = outer_d);
  cylinder(h = length + 0.2, d = thread_d);
}
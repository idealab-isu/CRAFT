$fn = 96;

thread_d = 3.0;      // mm (nominal)
length = 10.0;       // mm
outer_d = thread_d;  // "None mm diameter" -> default to thread diameter

difference() {
  cylinder(h = length, d = outer_d);
  cylinder(h = length + 0.2, d = thread_d, center = false);
}
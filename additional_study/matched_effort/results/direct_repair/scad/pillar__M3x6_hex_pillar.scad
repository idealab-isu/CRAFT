$fn = 96;

thread_d = 3.0;      // mm (nominal)
length   = 6.0;      // mm
outer_d  = 6.0;      // mm (assumed since "Nonemm diameter" likely means 6mm)

difference() {
  cylinder(d = outer_d, h = length);
  translate([0,0,-0.2])
    cylinder(d = thread_d, h = length + 0.4);
}
$fn = 96;

thread_d = 3.0;      // mm (nominal)
length = 6.0;        // mm
outer_d = 6.0;       // mm (assumed since "Nonemm diameter" unclear)

difference() {
    cylinder(d = outer_d, h = length);
    cylinder(d = thread_d, h = length + 0.2);
}
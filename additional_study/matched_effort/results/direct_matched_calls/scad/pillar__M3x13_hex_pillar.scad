$fn=96;

thread_d = 3.0;      // mm (nominal)
length   = 13.0;     // mm
outer_d  = 6.0;      // mm (assumed since diameter was "None")
hole_d   = 3.0;      // mm (clearance for M3-ish)

difference() {
  cylinder(h=length, d=outer_d);
  translate([0,0,-0.2]) cylinder(h=length+0.4, d=hole_d);
}
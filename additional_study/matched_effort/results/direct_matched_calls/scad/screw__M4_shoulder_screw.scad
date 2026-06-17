$fn = 96;

shaft_d = 5.0;
head_d  = 9.0;
head_h  = 2.4;
len     = 10.0;

union() {
  // Shaft
  cylinder(h = len, d = shaft_d);

  // Head on top
  translate([0,0,len])
    cylinder(h = head_h, d = head_d);
}
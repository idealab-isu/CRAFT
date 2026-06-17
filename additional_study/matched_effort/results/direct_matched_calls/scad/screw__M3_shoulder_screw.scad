$fn=96;

shaft_d = 4.0;
head_d  = 7.0;
head_h  = 2.4;
len     = 10.0;

union() {
  // Shaft
  cylinder(d=shaft_d, h=len);

  // Head
  translate([0,0,len])
    cylinder(d=head_d, h=head_h);
}
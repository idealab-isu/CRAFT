$fn=120;

shaft_d = 5.0;
head_d  = 9.0;
head_h  = 2.4;
len     = 10.0;

union() {
  cylinder(d=shaft_d, h=len, center=false);
  translate([0,0,len])
    cylinder(d=head_d, h=head_h, center=false);
}
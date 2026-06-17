$fn = 128;

// HT 90 pipe 250 mm (approximation)
// Assumptions (common HT DN90): OD=90mm, wall=2.7mm, length=250mm
// Adjust parameters as needed.

od = 90;
wall = 2.7;
len = 250;

id = od - 2*wall;

difference() {
  cylinder(h=len, d=od, center=false);
  translate([0,0,-0.1])
    cylinder(h=len+0.2, d=id, center=false);
}
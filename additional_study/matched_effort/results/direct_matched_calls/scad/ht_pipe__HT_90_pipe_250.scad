$fn = 128;

// HT 90 pipe 250 mm (approximation)
// Assumptions (common HT DN90): OD=90mm, wall=3.2mm, length=250mm
// Adjust parameters as needed.

od = 90;
wall = 3.2;
len = 250;

id = od - 2*wall;

difference() {
  cylinder(h=len, d=od, center=false);
  translate([0,0,-0.5])
    cylinder(h=len+1, d=id, center=false);
}
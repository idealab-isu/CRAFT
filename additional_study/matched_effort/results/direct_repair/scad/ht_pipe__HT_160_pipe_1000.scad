$fn=128;

// HT pipe parameters (mm)
outer_d = 160;
length  = 1000;

// Typical HT (indoor sewer) wall thickness approximation for DN160
wall = 4.7;

inner_d = outer_d - 2*wall;

difference() {
  cylinder(h=length, d=outer_d, center=false);
  translate([0,0,-0.5])
    cylinder(h=length+1, d=inner_d, center=false);
}
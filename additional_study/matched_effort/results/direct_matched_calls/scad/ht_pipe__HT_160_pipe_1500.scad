$fn=128;

// HT pipe parameters (approximation)
outer_d = 160;      // mm (nominal outer diameter)
length  = 1500;     // mm
wall    = 4.9;      // mm (typical for HT DN160; adjust if needed)

inner_d = outer_d - 2*wall;

difference() {
  cylinder(h=length, d=outer_d, center=false);
  translate([0,0,-0.1])
    cylinder(h=length+0.2, d=inner_d, center=false);
}
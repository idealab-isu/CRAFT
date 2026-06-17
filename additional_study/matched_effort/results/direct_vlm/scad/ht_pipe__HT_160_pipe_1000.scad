$fn=128;

// HT pipe parameters (approximation)
outer_d = 160;      // mm
length  = 1000;     // mm
wall    = 4.7;      // mm (typical for DN160 HT pipe; adjust if needed)

inner_d = outer_d - 2*wall;

difference() {
    cylinder(h=length, d=outer_d, center=false);
    translate([0,0,-0.1])
        cylinder(h=length+0.2, d=inner_d, center=false);
}
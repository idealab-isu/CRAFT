$fn = 180;

// HT pipe parameters (approximation)
outer_d = 160;      // mm (nominal HT 160 outer diameter)
length  = 150;      // mm
wall    = 4.7;      // mm (typical-ish for HT 160; adjust if needed)

inner_d = outer_d - 2*wall;

difference() {
    cylinder(h = length, d = outer_d, center = false);
    translate([0,0,-0.1])
        cylinder(h = length + 0.2, d = inner_d, center = false);
}
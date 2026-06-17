$fn = 128;

// Heatshrink sleeving (tubing) parameters
inner_d = 6;          // inner diameter (mm)
wall = 0.6;           // wall thickness (mm)
length = 50;          // length (mm)

// Optional subtle end chamfer (set to 0 for square ends)
chamfer = 0.4;        // mm

outer_d = inner_d + 2*wall;

module heatshrink_sleeve(id=inner_d, od=outer_d, L=length, c=chamfer) {
    difference() {
        // Outer body with optional chamfer
        if (c > 0) {
            hull() {
                translate([0,0,0]) cylinder(d=od - 2*c, h=0.01);
                translate([0,0,c]) cylinder(d=od, h=L - 2*c);
                translate([0,0,L - c]) cylinder(d=od - 2*c, h=0.01);
            }
        } else {
            cylinder(d=od, h=L);
        }

        // Inner bore (slightly extended to ensure clean subtraction)
        translate([0,0,-0.5]) cylinder(d=id, h=L + 1);
    }
}

heatshrink_sleeve();
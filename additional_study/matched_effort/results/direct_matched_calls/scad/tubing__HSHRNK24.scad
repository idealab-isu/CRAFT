$fn=128;

// Heatshrink sleeving (tubing) parameters
inner_d = 6;          // inner diameter (mm)
wall = 0.6;           // wall thickness (mm)
length = 40;          // length (mm)
chamfer = 0.8;        // end chamfer length (mm)

outer_d = inner_d + 2*wall;

module heatshrink_sleeve(id=inner_d, od=outer_d, h=length, c=chamfer) {
    difference() {
        // Outer body with slight end chamfers
        union() {
            // Main cylinder
            translate([0,0,c])
                cylinder(d=od, h=max(0.01, h-2*c));

            // Bottom chamfer
            if (c > 0)
                cylinder(d1=od-2*c, d2=od, h=c);

            // Top chamfer
            if (c > 0)
                translate([0,0,h-c])
                    cylinder(d1=od, d2=od-2*c, h=c);
        }

        // Inner bore (slightly extended to ensure clean subtraction)
        translate([0,0,-0.5])
            cylinder(d=id, h=h+1);
    }
}

heatshrink_sleeve();
$fn = 128;

// HT 40 cap (approximate dimensions)
// Adjust these if you have a specific manufacturer drawing.
id = 40.0;          // nominal inner diameter of pipe (mm)
wall = 2.2;         // cap wall thickness (mm)
depth = 35.0;       // insertion depth (mm)
top_th = 3.0;       // closed top thickness (mm)
lip = 2.0;          // outer lip radial extra (mm)
lip_h = 4.0;        // outer lip height (mm)
chamfer = 1.0;      // small chamfer size (mm)

od = id + 2*wall;
od_lip = od + 2*lip;

module chamfered_cylinder(h, r, c=1.0) {
    // Simple chamfer by subtracting cones at ends
    difference() {
        cylinder(h=h, r=r);
        // bottom chamfer
        translate([0,0,-0.01])
            cylinder(h=c+0.02, r1=r+0.01, r2=max(r-c, 0.01));
        // top chamfer
        translate([0,0,h-c-0.01])
            cylinder(h=c+0.02, r1=max(r-c, 0.01), r2=r+0.01);
    }
}

module ht40_cap() {
    difference() {
        union() {
            // Main outer body
            chamfered_cylinder(h=depth + top_th, r=od/2, c=chamfer);

            // Outer lip near opening
            translate([0,0,0])
                chamfered_cylinder(h=lip_h, r=od_lip/2, c=chamfer);
        }

        // Inner cavity (open at bottom, closed at top)
        translate([0,0,0])
            cylinder(h=depth, r=id/2);

        // Slight lead-in chamfer inside at opening
        translate([0,0,0])
            cylinder(h=chamfer+0.2, r1=(id/2)+chamfer, r2=id/2);
    }
}

ht40_cap();
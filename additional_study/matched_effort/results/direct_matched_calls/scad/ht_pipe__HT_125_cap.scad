$fn = 180;

// HT 125 cap (approximation)
// Dimensions in mm
id = 125;            // nominal inner diameter
wall = 3.2;          // cap wall thickness
od = id + 2*wall;    // outer diameter
depth = 55;          // insertion depth
top_th = 6;          // closed top thickness
lip_h = 10;          // outer lip height
lip_extra = 4;       // extra radius for lip
chamfer = 1.2;       // edge chamfer

module chamfered_cylinder(h, r, c=1) {
    // simple chamfer by minkowski with a cone-like frustum approximation
    // (kept renderable and robust)
    minkowski() {
        cylinder(h=max(0.01, h-2*c), r=r-c);
        cylinder(h=c, r1=c, r2=0);
    }
}

module ht125_cap() {
    difference() {
        union() {
            // main outer body
            chamfered_cylinder(h=depth + top_th, r=od/2, c=chamfer);

            // outer lip / collar near opening
            translate([0,0,0])
                chamfered_cylinder(h=lip_h, r=od/2 + lip_extra, c=chamfer);
        }

        // inner cavity (open at bottom)
        translate([0,0,0])
            cylinder(h=depth, r=id/2);

        // relieve inner edge slightly (lead-in)
        translate([0,0,0])
            cylinder(h=2.5, r1=id/2 + 1.2, r2=id/2);

        // small outer bottom chamfer cut (to sharpen lip edge)
        translate([0,0,-0.01])
            cylinder(h=chamfer+0.02, r1=od/2 + lip_extra + 0.8, r2=od/2 + lip_extra - 0.2);
    }
}

ht125_cap();
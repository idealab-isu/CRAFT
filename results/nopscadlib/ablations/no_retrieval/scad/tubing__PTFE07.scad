// PTFE sleeving (tubing) — single connected solid with through-bore and end chamfers

$fn = 128;

// Parameters
sleeve_length   = 100; //[50:200:1]
inner_diameter  = 4;   //[2:8:0.1]
outer_diameter  = 6;   //[3:12:0.1]
wall_thickness  = 1;   //[0.5:3:0.1] // Informational
chamfer_length  = 1.5; //[0.5:5:0.1]
chamfer_radial  = 0.75;//[0.25:3:0.05]
bore_clearance  = 0.2; //[0:1:0.05]
op_overlap      = 1;   //[0.5:2:0.1]

// Derived / safety clamps (avoid blank renders from invalid geometry)
od = max(outer_diameter, 0.01);
id = min(max(inner_diameter + 2*bore_clearance, 0.01), od - 0.02); // ensure wall remains
L  = max(sleeve_length, 0.01);

chL = min(max(chamfer_length, 0), L/2);
chR = min(max(chamfer_radial, 0), od/2 - 0.01);

// Base shapes
module sleeve_outer() {
    cylinder(h=L, r=od/2, center=true);
}

module sleeve_bore() {
    cylinder(h=L + 2*op_overlap, r=id/2, center=true);
}

// Chamfer cutters (remove material at ends)
module chamfer_cutter_top() {
    // Place so it intersects the top end with a small overlap
    translate([0, 0, L/2 - chL/2 + op_overlap/2])
        cylinder(h=chL + op_overlap, r1=od/2, r2=od/2 - chR, center=true);
}

module chamfer_cutter_bottom() {
    translate([0, 0, -L/2 + chL/2 - op_overlap/2])
        cylinder(h=chL + op_overlap, r1=od/2 - chR, r2=od/2, center=true);
}

// Final model
module ptfe_sleeve() {
    difference() {
        sleeve_outer();
        sleeve_bore();
        chamfer_cutter_top();
        chamfer_cutter_bottom();
    }
}

// Output (off-white PTFE)
color([0.95, 0.95, 0.92])
ptfe_sleeve();
$fn = 128;

// HT 75 cap (approximation)
// Dimensions in mm
d_nom = 75;                 // nominal pipe size
d_outer = 75;               // outer diameter of pipe/cap body
wall = 2.2;                 // wall thickness
d_inner = d_outer - 2*wall; // inner diameter
cap_depth = 45;             // overall cap height
closed_end_thk = 3.0;       // thickness of the closed end
lip_height = 8;             // small outer lip height
lip_overhang = 2.0;         // lip radial overhang

// Small chamfers/fillets approximated with cones
outer_chamfer_h = 1.2;
outer_chamfer_r = 0.8;
inner_lead_h = 2.0;
inner_lead_r = 1.0;

module ht75_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(h = cap_depth, d = d_outer);

            // Outer lip near opening
            translate([0,0,cap_depth - lip_height])
                cylinder(h = lip_height, d = d_outer + 2*lip_overhang);

            // Outer chamfer at opening edge (approx)
            translate([0,0,cap_depth - outer_chamfer_h])
                cylinder(h = outer_chamfer_h, d1 = (d_outer + 2*lip_overhang), d2 = (d_outer + 2*lip_overhang) - 2*outer_chamfer_r);
        }

        // Hollow interior (leave closed end thickness)
        translate([0,0,closed_end_thk])
            cylinder(h = cap_depth - closed_end_thk + 0.01, d = d_inner);

        // Inner lead-in chamfer at opening (approx)
        translate([0,0,cap_depth - inner_lead_h])
            cylinder(h = inner_lead_h + 0.02, d1 = d_inner + 2*inner_lead_r, d2 = d_inner);

        // Slight relief under lip (optional)
        translate([0,0,cap_depth - lip_height])
            cylinder(h = lip_height + 0.02, d = d_outer + 2*lip_overhang - 2.0);
    }
}

ht75_cap();
$fn=128;

// HT 90 cap (end cap) - parametric approximation
// Units: mm

// -------- Parameters --------
pipe_od      = 90;      // nominal outer diameter of pipe
wall         = 3.2;     // cap wall thickness
cap_depth    = 55;      // overall depth of cap (axial length)
closed_end   = 6;       // thickness of the closed end
socket_depth = 40;      // insertion depth (internal cavity length from open end)
clearance    = 0.6;     // internal clearance over pipe OD

// External reinforcement ring near open end
ring_height  = 12;
ring_thick   = 3.0;

// Small outer chamfer at open end
outer_chamfer = 1.2;
inner_chamfer = 1.0;

// -------- Derived --------
outer_r = pipe_od/2 + wall;
inner_r = pipe_od/2 + clearance;
cap_len = cap_depth;

// Ensure cavity doesn't break through closed end
cavity_len = min(socket_depth, cap_len - closed_end - 0.5);

// -------- Helpers --------
module chamfered_cylinder(h, r, chamfer=1.0, top=false, bottom=false) {
    // Simple chamfer by subtracting cones at ends
    difference() {
        cylinder(h=h, r=r);
        if (bottom && chamfer > 0)
            translate([0,0,-0.01])
                cylinder(h=chamfer+0.02, r1=r+0.01, r2=max(r-chamfer, 0.01));
        if (top && chamfer > 0)
            translate([0,0,h-chamfer-0.01])
                cylinder(h=chamfer+0.02, r1=max(r-chamfer, 0.01), r2=r+0.01);
    }
}

// -------- Model --------
module ht90_cap() {
    difference() {
        union() {
            // Main body
            chamfered_cylinder(cap_len, outer_r, chamfer=outer_chamfer, bottom=true, top=false);

            // Reinforcement ring near open end
            translate([0,0,0])
                cylinder(h=ring_height, r=outer_r + ring_thick);
        }

        // Internal cavity (socket)
        translate([0,0,0])
            chamfered_cylinder(cavity_len, inner_r, chamfer=inner_chamfer, bottom=true, top=false);

        // Slight internal relief near closed end (to avoid sharp corner)
        translate([0,0,cavity_len-0.01])
            cylinder(h=2.0, r=inner_r-0.8);
    }
}

ht90_cap();
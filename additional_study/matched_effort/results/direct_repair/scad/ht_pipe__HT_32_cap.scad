$fn = 128;

// HT 32 cap (approximation)
// Typical HT pipe OD ~ 32 mm. Cap is a closed-end socket with a small outer lip.
pipe_od = 32.0;
wall = 2.2;

socket_depth = 28.0;      // insertion depth
end_thickness = 3.0;      // closed end thickness beyond socket
outer_lip = 2.0;          // extra radius at the open end
lip_height = 3.0;         // height of the outer lip

clearance = 0.4;          // radial clearance for fit

outer_d = pipe_od + 2*wall;
inner_d = pipe_od + 2*clearance;

cap_outer_d = outer_d + 2*outer_lip;

total_h = socket_depth + end_thickness;

module ht32_cap() {
    difference() {
        union() {
            // Main outer body (closed end)
            cylinder(d=outer_d, h=total_h);

            // Outer lip at open end
            translate([0,0,0])
                cylinder(d=cap_outer_d, h=lip_height);
        }

        // Inner cavity (open end), leaving closed end thickness
        translate([0,0,0])
            cylinder(d=inner_d, h=socket_depth);

        // Small inner lead-in chamfer (approximated by a short cone)
        chamfer_h = 2.0;
        translate([0,0,0])
            cylinder(d1=inner_d + 2.0, d2=inner_d, h=chamfer_h);
    }
}

ht32_cap();
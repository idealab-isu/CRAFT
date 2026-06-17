$fn=128;

// HT 50 cap (approximation)
// Typical HT50 OD ~ 50 mm. Cap has a socket to slip over pipe OD.
// Dimensions are parametric for easy adjustment.

pipe_od = 50.0;          // outer diameter of HT50 pipe
clearance = 0.6;         // radial clearance for slip fit (diameter clearance ~1.2mm)
wall = 3.0;              // cap wall thickness
socket_depth = 35.0;     // depth of socket that covers the pipe
top_thickness = 4.0;     // thickness of closed end
outer_rim_extra = 2.0;   // extra thickness at rim for stiffness
chamfer = 1.2;           // small lead-in chamfer

inner_d = pipe_od + 2*clearance;
outer_d = inner_d + 2*wall;
outer_d_rim = outer_d + 2*outer_rim_extra;

total_h = socket_depth + top_thickness;

module cap_body() {
    union() {
        // Main outer shell
        cylinder(d=outer_d, h=total_h);

        // Slightly thicker rim at open end
        cylinder(d=outer_d_rim, h=6);

        // Small outer rounding at top edge (simple fillet approximation)
        translate([0,0,total_h-1.2])
            cylinder(d1=outer_d, d2=outer_d-2.0, h=1.2);
    }
}

module cap_void() {
    union() {
        // Main socket void (stops before top thickness)
        translate([0,0,top_thickness])
            cylinder(d=inner_d, h=socket_depth + 0.2);

        // Lead-in chamfer at opening
        cylinder(d1=inner_d + 2*chamfer, d2=inner_d, h=chamfer);

        // Slight relief just inside rim
        translate([0,0,0.5])
            cylinder(d=inner_d+0.6, h=2.0);
    }
}

difference() {
    cap_body();
    cap_void();
}
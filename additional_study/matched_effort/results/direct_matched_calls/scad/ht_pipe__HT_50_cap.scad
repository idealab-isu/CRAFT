$fn=128;

// HT 50 cap (approximate, renderable)
// Typical HT50 OD ~ 50 mm. Cap is a closed-end socket with a stop.
// Dimensions are parametric for easy tweaking.

module ht50_cap(
    pipe_od=50.0,          // outer diameter of pipe that fits inside
    clearance=0.6,          // radial clearance for fit
    wall=3.0,               // cap wall thickness
    socket_depth=35.0,      // insertion depth
    end_thickness=4.0,      // thickness of closed end
    stop_thickness=2.0,     // internal stop ring thickness (axial)
    stop_offset=28.0,       // distance from open end to stop ring start
    outer_rib_count=6,      // external grip ribs
    outer_rib_height=1.2,   // rib radial height
    outer_rib_width=6.0     // rib axial width
){
    inner_d = pipe_od + 2*clearance;
    outer_d = inner_d + 2*wall;

    total_h = socket_depth + end_thickness;

    difference() {
        union() {
            // Main outer body
            cylinder(d=outer_d, h=total_h);

            // External grip ribs near open end
            for (i = [0:outer_rib_count-1]) {
                z0 = 3 + i*(outer_rib_width + 2);
                if (z0 + outer_rib_width <= socket_depth - 2)
                    translate([0,0,z0])
                        cylinder(d=outer_d + 2*outer_rib_height, h=outer_rib_width);
            }

            // Slight outer chamfer at open end
            translate([0,0,0])
                cylinder(d1=outer_d + 1.0, d2=outer_d, h=1.2);
        }

        // Hollow socket cavity (open end)
        translate([0,0,0])
            cylinder(d=inner_d, h=socket_depth);

        // Internal stop: leave a ring by cutting deeper cavity beyond stop
        // Create a smaller cavity from stop_offset+stop_thickness to end
        // so that a ring remains at inner_d for stop_thickness.
        translate([0,0,stop_offset + stop_thickness])
            cylinder(d=inner_d + 2.0, h=total_h - (stop_offset + stop_thickness));

        // Inner corner relief at bottom (small fillet-like chamfer)
        translate([0,0,socket_depth-1.0])
            cylinder(d1=inner_d, d2=inner_d+2.0, h=1.0);

        // Outer bottom rounding (subtractive) to soften edge
        translate([0,0,total_h-1.2])
            cylinder(d1=outer_d, d2=outer_d-1.0, h=1.2);
    }
}

ht50_cap();
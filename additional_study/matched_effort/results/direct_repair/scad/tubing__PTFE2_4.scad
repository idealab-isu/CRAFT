$fn = 128;

// PTFE tubing (generic)
outer_d = 4.0;     // mm
inner_d = 2.0;     // mm
length  = 200.0;   // mm

module ptfe_tube(od, id, len) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = len + 0.2, d = id, center = false);
    }
}

ptfe_tube(outer_d, inner_d, length);
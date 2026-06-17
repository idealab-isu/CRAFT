$fn = 128;

// PTFE sleeving (tubing) parameters (mm)
inner_d = 4.0;     // inner diameter
outer_d = 6.0;     // outer diameter
length  = 100.0;   // tube length

module ptfe_sleeving(id, od, h) {
    difference() {
        cylinder(h = h, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = h + 1.0, d = id, center = false);
    }
}

ptfe_sleeving(inner_d, outer_d, length);
$fn = 128;

// PTFE sleeving (simple hollow tube)
inner_d = 4;      // mm
outer_d = 6;      // mm
length  = 60;     // mm

module ptfe_sleeving(id, od, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2, center=false);
    }
}

ptfe_sleeving(inner_d, outer_d, length);
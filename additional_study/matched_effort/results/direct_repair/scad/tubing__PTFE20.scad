$fn = 128;

// PTFE sleeving (simple hollow tube)
inner_d = 4;      // mm
outer_d = 6;      // mm
length  = 100;    // mm

module ptfe_sleeving(id=inner_d, od=outer_d, h=length) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5])
            cylinder(d=id, h=h+1, center=false);
    }
}

ptfe_sleeving();
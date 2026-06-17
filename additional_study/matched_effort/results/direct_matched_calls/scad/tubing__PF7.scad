$fn = 128;

// PTFE tubing (simple hollow cylinder)
// Units: mm
outer_d = 4.0;     // typical PTFE tube OD
inner_d = 2.0;     // typical PTFE tube ID
length  = 100.0;   // tube length

module ptfe_tube(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2, center=false);
    }
}

ptfe_tube(outer_d, inner_d, length);
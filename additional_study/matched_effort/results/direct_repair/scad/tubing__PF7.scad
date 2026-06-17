$fn = 128;

// PTFE tubing (simple hollow cylinder)
// Units: mm
outer_d = 4.0;     // typical PTFE tube OD
inner_d = 2.0;     // typical PTFE tube ID
length  = 200.0;   // tube length

module ptfe_tube(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2, center=false);
    }
}

color([0.95, 0.95, 0.95, 1.0])
ptfe_tube(outer_d, inner_d, length);
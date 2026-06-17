$fn = 128;

// PTFE tubing parameters (mm)
tube_length = 200;
outer_diameter = 4;
inner_diameter = 2;

// Safety checks
inner_diameter = min(inner_diameter, outer_diameter - 0.2);

module ptfe_tube(L=tube_length, OD=outer_diameter, ID=inner_diameter) {
    difference() {
        cylinder(h=L, d=OD, center=false);
        translate([0,0,-0.1])
            cylinder(h=L+0.2, d=ID, center=false);
    }
}

ptfe_tube();
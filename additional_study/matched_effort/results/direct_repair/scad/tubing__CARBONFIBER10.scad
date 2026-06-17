$fn = 128;

// Carbon fiber tubing parameters (mm)
outer_d = 25;
wall    = 2.0;
length  = 120;

inner_d = max(0.01, outer_d - 2*wall);

module carbon_fiber_tube(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5]) cylinder(d=id, h=h+1, center=false);
    }
}

module carbon_fiber_look(od, h) {
    // Subtle dark sheen bands to suggest carbon fiber weave
    for (i = [0:1:11]) {
        z0 = i * h/12;
        band_h = h/24;
        color([0.08 + 0.02*(i%2), 0.08 + 0.02*(i%2), 0.09 + 0.02*(i%2), 0.35])
            translate([0,0,z0])
                cylinder(d=od*1.001, h=band_h, center=false);
    }
}

union() {
    color([0.06, 0.06, 0.07]) carbon_fiber_tube(outer_d, inner_d, length);
    carbon_fiber_look(outer_d, length);
}
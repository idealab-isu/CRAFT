$fn = 180;

// Carbon fiber tubing parameters
outer_d = 30;      // mm
wall_th = 2.0;     // mm
length = 120;      // mm

inner_d = outer_d - 2*wall_th;

// Visual "carbon fiber" weave parameters (purely aesthetic)
weave_depth = 0.25;     // mm (radial depth of grooves)
weave_pitch = 8;        // mm per twist cycle
weave_strands = 24;     // number of helical grooves per direction

module tube_basic(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5]) cylinder(d=id, h=h+1, center=false);
    }
}

// Create a helical groove by twisting a thin rectangular cutter around the tube
module helical_groove(od, h, depth, pitch, zphase=0, dir=1) {
    // Place cutter slightly outside and cut inward
    cutter_w = 1.2;                 // tangential width
    cutter_t = depth * 2.2;         // radial thickness of cutter
    r = od/2 - depth*0.2;           // position so it bites into surface

    translate([0,0,zphase])
    linear_extrude(height=h, twist=dir * 360 * (h/pitch), slices=max(60, ceil(h*6)))
        translate([r,0,0])
            square([cutter_t, cutter_w], center=true);
}

module carbon_fiber_tube(od, id, h) {
    // Base tube
    base = tube_basic(od, id, h);

    // Weave grooves (two opposing helices)
    difference() {
        base;

        // Right-hand helices
        for (i = [0:weave_strands-1]) {
            rotate([0,0, i*(360/weave_strands)])
                helical_groove(od, h, weave_depth, weave_pitch, 0, 1);
        }

        // Left-hand helices, phase-shifted for a weave look
        for (i = [0:weave_strands-1]) {
            rotate([0,0, i*(360/weave_strands) + (180/weave_strands)])
                helical_groove(od, h, weave_depth, weave_pitch, weave_pitch/4, -1);
        }
    }
}

// Render
color([0.08,0.08,0.09])
carbon_fiber_tube(outer_d, inner_d, length);
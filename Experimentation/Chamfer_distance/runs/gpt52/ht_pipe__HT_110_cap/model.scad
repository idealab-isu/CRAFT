$fn = 96;

module ht_end_cap(nom_d=110) {
    // Approximate HT pipe end cap for nominal 110 mm
    // Typical OD ~110 mm; make an internal socket with a modest wall and a closed end.
    od = nom_d;           // outer diameter
    wall = 3.2;           // cap wall thickness
    socket_depth = 55;    // insertion depth
    end_thickness = 5;    // closed-end thickness
    lip_height = 12;      // outer lip height
    lip_thickness = 2.8;  // extra radial thickness at lip

    outer_h = socket_depth + end_thickness;

    difference() {
        union() {
            // Main outer body
            cylinder(h=outer_h, d=od);

            // Slight outer lip near the opening
            translate([0,0,outer_h - lip_height])
                cylinder(h=lip_height, d=od + 2*lip_thickness);

            // Small external chamfer-like taper at opening
            translate([0,0,outer_h - 3])
                cylinder(h=3, d1=od + 2*lip_thickness, d2=od + 2*lip_thickness - 2);
        }

        // Internal cavity (socket), leaving closed end thickness
        translate([0,0,end_thickness])
            cylinder(h=socket_depth + 0.2, d=od - 2*wall);

        // Inner lead-in chamfer at opening
        translate([0,0,outer_h - 8])
            cylinder(h=8.2, d1=(od - 2*wall) - 4, d2=(od - 2*wall));

        // Optional small internal stop ridge removal (creates slight step)
        translate([0,0,end_thickness + 18])
            cylinder(h=2.2, d=(od - 2*wall) + 1.2);
    }
}

translate([0,0,-30])
    ht_end_cap(110);
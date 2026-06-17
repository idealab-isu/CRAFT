$fn = 128;

// PTFE sleeving (tubing) parameters (mm)
inner_d = 4.0;     // inner diameter
outer_d = 6.0;     // outer diameter
length  = 60.0;    // tube length

// Optional: slight end chamfer for nicer render
chamfer = 0.4;     // set to 0 for square ends

module ptfe_sleeving(id, od, L, c=0) {
    assert(od > id, "outer_d must be greater than inner_d");
    assert(L > 0, "length must be > 0");
    r_in = id/2;
    r_out = od/2;

    difference() {
        // Outer body with optional chamfer
        if (c > 0) {
            hull() {
                translate([0,0,0]) cylinder(h=c, r=r_out - c);
                translate([0,0,c]) cylinder(h=L-2*c, r=r_out);
                translate([0,0,L-c]) cylinder(h=c, r=r_out - c);
            }
        } else {
            cylinder(h=L, r=r_out);
        }

        // Inner bore (extend slightly to avoid coplanar artifacts)
        translate([0,0,-0.2]) cylinder(h=L+0.4, r=r_in);
    }
}

// PTFE-like appearance (optional)
color([0.95, 0.95, 0.95, 0.95])
ptfe_sleeving(inner_d, outer_d, length, chamfer);
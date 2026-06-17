$fn = 128;

// PTFE tubing parameters (mm)
outer_d = 4.0;
inner_d = 2.0;
length  = 200.0;

// Small chamfer on ends (set to 0 for square ends)
chamfer = 0.4;

module tube(od, id, h, ch=0) {
    assert(od > id, "Outer diameter must be larger than inner diameter.");
    assert(id > 0, "Inner diameter must be > 0.");
    assert(h > 0, "Length must be > 0.");
    assert(ch >= 0, "Chamfer must be >= 0.");

    difference() {
        // Outer body with optional chamfered ends
        if (ch > 0) {
            minkowski() {
                cylinder(d=od - 2*ch, h=h - 2*ch, center=false);
                sphere(r=ch);
            }
        } else {
            cylinder(d=od, h=h, center=false);
        }

        // Inner bore (slightly extended to ensure clean subtraction)
        translate([0,0,-1])
            cylinder(d=id, h=h+2, center=false);
    }
}

tube(outer_d, inner_d, length, chamfer);
$fn = 128;

// Neoprene tubing (generic): hollow cylinder
// Units: mm

outer_diameter = 12;   // OD
inner_diameter = 8;    // ID
length = 120;          // tube length

// Optional: slight end chamfer for a more realistic cut
chamfer = 0.6;         // set to 0 for sharp ends

module neoprene_tube(od, id, L, ch=0) {
    assert(od > id, "Outer diameter must be greater than inner diameter.");
    assert(L > 0, "Length must be positive.");
    assert(ch >= 0, "Chamfer must be non-negative.");
    ch_eff = min(ch, (od-id)/4, L/4);

    difference() {
        // Outer body with optional chamfer
        if (ch_eff > 0) {
            hull() {
                translate([0,0,ch_eff]) cylinder(h=L-2*ch_eff, d=od);
                cylinder(h=0.01, d=od-2*ch_eff);
                translate([0,0,L-0.01]) cylinder(h=0.01, d=od-2*ch_eff);
            }
        } else {
            cylinder(h=L, d=od);
        }

        // Inner bore (slightly extended to ensure clean subtraction)
        translate([0,0,-0.5]) cylinder(h=L+1, d=id);
    }
}

neoprene_tube(outer_diameter, inner_diameter, length, chamfer);
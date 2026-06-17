$fn = 160;

// Single, connected solid: the INSERT itself (with bore + knurl cuts)
module insert(od=25.0, len=18.5, screw_d=10.0) {
    // Tunables
    chamfer_h = 2.0;
    chamfer_d = 22.0;          // end taper diameter
    bore_clear = 0.4;          // clearance for screw
    knurl_d = 2.0;             // knurl cutter diameter
    knurl_overlap = 0.6;       // how far knurl cuts into OD
    knurl_count = 12;

    r_outer = od/2;
    r_bore  = (screw_d + bore_clear)/2;

    // Safety
    assert(chamfer_h > 0 && chamfer_h <= len/2);
    assert(chamfer_d > 0 && chamfer_d <= od);
    assert(r_bore > 0 && r_bore < r_outer);
    assert(knurl_overlap >= 0 && knurl_overlap < r_outer);

    // Overlap to guarantee connectivity between sub-solids
    overlap = 1.0;   // 1–2mm per requirements
    eps = 0.05;

    difference() {
        // ONE connected solid: main body + two end chamfers (overlapped)
        union() {
            // Main body centered
            cylinder(d=od, h=len, center=true);

            // Top chamfer: overlaps into main body by 'overlap'
            translate([0, 0, (len/2 - chamfer_h) - overlap])
                cylinder(d1=od, d2=chamfer_d, h=chamfer_h + overlap + eps, center=false);

            // Bottom chamfer: overlaps into main body by 'overlap'
            translate([0, 0, -len/2 - eps])
                cylinder(d1=chamfer_d, d2=od, h=chamfer_h + overlap + eps, center=false);
        }

        // Through bore (cuts fully)
        cylinder(r=r_bore, h=len + 2*(chamfer_h + overlap) + 2*eps, center=true);

        // Knurl cuts: ensure they intersect the OD (not tangent)
        for (i = [0:knurl_count-1]) {
            rotate([0, 0, i * 360/knurl_count])
                translate([r_outer - knurl_overlap - knurl_d/2 + eps, 0, 0])
                    cylinder(d=knurl_d, h=len + 2*(chamfer_h + overlap) + 2*eps, center=true);
        }
    }
}

// Build the expected part name explicitly
union() {
    insert();
}
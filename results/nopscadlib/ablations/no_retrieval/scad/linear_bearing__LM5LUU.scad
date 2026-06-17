// Long linear bearing: 5.0mm bore, 10.0mm OD, 28.0mm length

$fn = 128;                 // ensure circular bore/OD (no polygonal look)
eps = 0.02;                // small overlap to guarantee clean boolean cuts

bearing_L  = 28.0;
bearing_OD = 10.0;
bearing_ID = 5.0;

// Optional cosmetic features (kept small and safe)
chamfer_len = 1.0;
chamfer_rad_reduction = 0.5;

outer_groove_count  = 6;
outer_groove_width  = 0.8;
outer_groove_depth  = 0.3;
outer_groove_margin = 2.5;

ring_groove_width  = 1.2;
ring_groove_depth  = 0.6;
ring_groove_offset = 3.0;

module bearing_complete() {
    difference() {
        // Main body
        cylinder(h=bearing_L, r=bearing_OD/2, center=true);

        // Through bore (make longer than body to guarantee a true through-hole)
        cylinder(h=bearing_L + 2*eps, r=bearing_ID/2, center=true);

        // End chamfers (cut as frustums that remove material at both ends)
        translate([0,0,  bearing_L/2 - chamfer_len/2])
            cylinder(h=chamfer_len + 2*eps,
                     r1=bearing_OD/2 + eps,
                     r2=bearing_OD/2 - chamfer_rad_reduction,
                     center=true);

        translate([0,0, -bearing_L/2 + chamfer_len/2])
            cylinder(h=chamfer_len + 2*eps,
                     r1=bearing_OD/2 - chamfer_rad_reduction,
                     r2=bearing_OD/2 + eps,
                     center=true);

        // Outer surface grooves (shallow OD reductions)
        for (i = [1:outer_groove_count]) {
            zpos = -(bearing_L/2 - outer_groove_margin)
                   + i * ((bearing_L - 2*outer_groove_margin) / (outer_groove_count + 1));
            translate([0,0,zpos])
                cylinder(h=outer_groove_width + 2*eps,
                         r=bearing_OD/2 - outer_groove_depth,
                         center=true);
        }

        // Retaining ring grooves near ends
        translate([0,0,  bearing_L/2 - ring_groove_offset])
            cylinder(h=ring_groove_width + 2*eps,
                     r=bearing_OD/2 - ring_groove_depth,
                     center=true);

        translate([0,0, -bearing_L/2 + ring_groove_offset])
            cylinder(h=ring_groove_width + 2*eps,
                     r=bearing_OD/2 - ring_groove_depth,
                     center=true);
    }
}

bearing_complete();
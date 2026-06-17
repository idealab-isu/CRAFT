$fn = 160;

// Parameters (mm)
outer_diameter = 30.0;           // OD across knurl peaks
overall_length = 22.0;           // total length
screw_diameter = 12.0;           // clearance bore
knurl_depth = 1.0;               // radial height of knurl peaks
knurl_count = 24;                // number of knurl ribs
lead_in_chamfer_length = 2.0;    // top chamfer length
installation_taper_length = 2.0; // bottom chamfer length

// Derived
outer_r = outer_diameter/2;
core_r  = outer_r - knurl_depth; // base cylinder radius under knurl
bore_d  = screw_diameter;
eps = 0.05;

module external_knurl_ribs(h) {
    rib_radial = knurl_depth; // protrusion outward from core
    rib_tangential = (2*PI*outer_r)/knurl_count * 0.55;
    overlap = knurl_depth * 0.8; // ensure ribs intersect core

    for (i = [0:knurl_count-1]) {
        rotate([0, 0, i * 360/knurl_count])
            translate([core_r + rib_radial/2 - overlap, 0, 0])
                cube([rib_radial + overlap, rib_tangential, h], center=true);
    }
}

module threaded_insert() {
    difference() {
        union() {
            // Main body (centered)
            cylinder(r=core_r, h=overall_length, center=true);

            // Knurl ribs (connected via overlap into core)
            external_knurl_ribs(overall_length);

            // Top chamfer: placed so it overlaps the main body by eps
            translate([0, 0, overall_length/2 - lead_in_chamfer_length + eps])
                cylinder(h=lead_in_chamfer_length + eps,
                         r1=core_r, r2=outer_r, center=false);

            // Bottom chamfer: placed so it overlaps the main body by eps
            translate([0, 0, -overall_length/2 - installation_taper_length])
                cylinder(h=installation_taper_length + eps,
                         r1=outer_r, r2=core_r, center=false);
        }

        // Through bore (slightly longer than part to guarantee clean cut)
        cylinder(d=bore_d, h=overall_length + 2*(lead_in_chamfer_length + installation_taper_length) + 2, center=true);
    }
}

threaded_insert();
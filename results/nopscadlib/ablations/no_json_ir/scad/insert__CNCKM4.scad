// Threaded heat-set insert (M4) - 4.0mm OD, 6.3mm long
// One connected solid with internal bore + external straight knurls

outer_diameter   = 4.0;   // mm
overall_length   = 6.3;   // mm
bore_diameter    = 3.3;   // mm (approx. internal thread minor/clearance)
knurl_depth      = 0.3;   // mm (radial protrusion beyond OD)
entry_chamfer    = 0.5;   // mm
lead_in_chamfer  = 0.5;   // mm

knurl_count      = 12;
$fn = 120;

module knurls(od, len, z0, count, depth) {
    // Ensure ribs are connected to the body by overlapping inward
    overlap = 0.15; // mm (into body)
    rib_radial = depth + overlap;

    // Tangential width (visual match to typical inserts)
    rib_tan = od * 0.22;

    // Place ribs so their inner face penetrates the cylinder by 'overlap'
    // Cube is centered, so its center radius is:
    // (od/2 - overlap) + rib_radial/2
    r_center = (od/2 - overlap) + rib_radial/2;

    for (i = [0 : count-1]) {
        rotate([0, 0, i * 360 / count])
            translate([r_center, 0, z0 + len/2])
                cube([rib_radial, rib_tan, len], center=true);
    }
}

module threaded_insert() {
    eps = 0.02;

    // Straight knurled section between chamfers
    knurl_h = max(0.01, overall_length - entry_chamfer - lead_in_chamfer);
    knurl_z0 = entry_chamfer;

    difference() {
        union() {
            // Main body
            cylinder(h=overall_length, d=outer_diameter);

            // External knurls (connected via overlap)
            knurls(outer_diameter, knurl_h, knurl_z0, knurl_count, knurl_depth);
        }

        // Through bore
        translate([0, 0, -eps])
            cylinder(h=overall_length + 2*eps, d=bore_diameter);

        // Bottom entry chamfer (outer -> bore)
        translate([0, 0, -eps])
            cylinder(h=entry_chamfer + eps, d1=outer_diameter, d2=bore_diameter);

        // Top lead-in chamfer (bore -> outer)
        translate([0, 0, overall_length - lead_in_chamfer])
            cylinder(h=lead_in_chamfer + eps, d1=bore_diameter, d2=outer_diameter);
    }
}

threaded_insert();
$fn = 120;

// Threaded heat-set insert (mm)
outer_diameter = 10.0;
length         = 8.0;

// For 4.0mm screws (user requested)
inner_diameter = 4.0;

// Knurl / ribs
knurl_depth   = 0.5;   // radial protrusion beyond OD
knurl_count   = 18;    // number of ribs around circumference
knurl_width   = 0.8;   // tangential width of each rib
knurl_overlap = 0.20;  // how much each rib sinks into the body for guaranteed connectivity

// End chamfers
lead_in_chamfer          = 1.0;  // bottom
installation_end_chamfer = 1.0;  // top

eps = 0.02;

module threaded_insert() {
    difference() {
        heat_set_insert_body();
        internal_bore();
    }
}

module heat_set_insert_body() {
    union() {
        // Main body
        cylinder(d=outer_diameter, h=length, center=false);

        // Bottom chamfer (lead-in) - attached to z=0 face
        translate([0, 0, -lead_in_chamfer])
            cylinder(
                d1=max(outer_diameter - 2*lead_in_chamfer, 0.01),
                d2=outer_diameter,
                h=lead_in_chamfer,
                center=false
            );

        // Top chamfer (installation end) - attached to z=length face
        translate([0, 0, length])
            cylinder(
                d1=outer_diameter,
                d2=max(outer_diameter - 2*installation_end_chamfer, 0.01),
                h=installation_end_chamfer,
                center=false
            );

        // External ribs (knurl)
        outer_ribs();
    }
}

module internal_bore() {
    // Through-hole across full insert including chamfers
    translate([0, 0, -lead_in_chamfer - eps])
        cylinder(
            d=inner_diameter,
            h=length + lead_in_chamfer + installation_end_chamfer + 2*eps,
            center=false
        );
}

module outer_ribs() {
    rib_h = length;

    // Place ribs so their inner face overlaps into the main cylinder by knurl_overlap
    // Rib radial thickness = knurl_depth + knurl_overlap
    rib_radial_thickness = knurl_depth + knurl_overlap;

    // Center radius so inner face is at (outer_diameter/2 - knurl_overlap)
    rib_r_center = outer_diameter/2 + rib_radial_thickness/2 - knurl_overlap;

    for (i = [0 : knurl_count-1]) {
        rotate([0, 0, i * 360/knurl_count])
            translate([rib_r_center, 0, rib_h/2])
                cube([rib_radial_thickness, knurl_width, rib_h], center=true);
    }
}

threaded_insert();
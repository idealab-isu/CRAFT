$fn = 96;

module led(type="5mm", body_color="green", lead_length=25, bend=true) {

    // --- Dimensions ---
    body_d = (type=="5mm") ? 5 : 3;
    body_h = (type=="5mm") ? 5 : 3;

    rim_h  = 0.6;
    rim_d1 = body_d;
    rim_d2 = body_d + 0.8;

    lead_d = 0.6;
    lead_spacing = (type=="5mm") ? 1.2 : 0.9;

    // Overlap to guarantee ONE connected solid
    overlap = 0.25;

    // Z references (body centered at z=0)
    body_zmin = -body_h/2;
    body_zmax =  body_h/2;

    // Leads start slightly inside body to ensure connection
    lead_z_top = body_zmin + overlap;

    // Bend parameters (right-angle bend at the bottom of the leads)
    bend_len = 5;

    union() {
        // LED body
        color(body_color)
            cylinder(h=body_h, d=body_d, center=true);

        // Rim at top, connected to body (slight overlap into body)
        translate([0, 0, body_zmax - overlap])
            cylinder(h=rim_h + overlap, d1=rim_d1, d2=rim_d2, center=false);

        // Leads (two pins), connected into body
        for (x = [-lead_spacing/2, lead_spacing/2]) {

            // Vertical lead: top at lead_z_top, extends downward
            translate([x, 0, lead_z_top - (lead_length + overlap)])
                cylinder(h=lead_length + overlap, d=lead_d, center=false);

            // Optional right-angle bend at the bottom, connected to lead end
            if (bend) {
                // Bottom of vertical lead is at z = lead_z_top - (lead_length + overlap)
                // Place horizontal cylinder so its start overlaps the vertical lead end.
                translate([x, 0, lead_z_top - (lead_length + overlap)])
                    rotate([90, 0, 0])
                        cylinder(h=bend_len + overlap, d=lead_d, center=false);
            }
        }
    }
}

led(type="5mm", body_color="green", lead_length=25, bend=true);
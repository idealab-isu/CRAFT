$fn = 96;

axial = [3.4, 1.75, 0.3]; // [length, diameter, lead_diameter]

module axial_part(a = axial) {
    L = a[0];
    D = a[1];
    d = a[2];

    bodyL = L * 0.55;
    leadL = (L - bodyL) / 2;

    union() {
        // Leads
        translate([-(bodyL/2 + leadL), 0, 0])
            cylinder(h = leadL, d = d, center = false);

        translate([bodyL/2, 0, 0])
            cylinder(h = leadL, d = d, center = false);

        // Body
        translate([-bodyL/2, 0, 0])
            cylinder(h = bodyL, d = D, center = false);
    }
}

// Orient along X axis
rotate([0, 90, 0]) axial_part();
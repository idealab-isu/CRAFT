$fn = 96;

overall_len = 66;
mount_inset = 6.8;

insulator_d = 16;
insulator_r = insulator_d/2;
insulator_len = 46;

groove_width = 12;     // axial length of groove
groove_depth = 5.6;    // radial reduction amount
groove_r = max(0.5, insulator_r - groove_depth);

module hotend_assembly() {
    union() {
        // Main insulator body
        difference() {
            translate([0,0,-overall_len/2])
                cylinder(h=insulator_len, r=insulator_r);

            // Mounting groove (ring cut)
            translate([0,0,-overall_len/2 + mount_inset])
                cylinder(h=groove_width, r=insulator_r + 0.2);
            translate([0,0,-overall_len/2 + mount_inset])
                cylinder(h=groove_width, r=groove_r);
        }

        // Upper neck (to reach overall length)
        neck_len = overall_len - insulator_len;
        if (neck_len > 0) {
            translate([0,0,-overall_len/2 + insulator_len])
                cylinder(h=neck_len, r=6);
        }
    }
}

hotend_assembly();
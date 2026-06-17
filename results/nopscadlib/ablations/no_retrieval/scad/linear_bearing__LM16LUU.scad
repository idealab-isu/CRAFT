$fn = 128;

// Critical dimensions (requested)
bearing_length = 70.0;     // mm
outer_diameter = 28.0;     // mm
bore_diameter  = 16.0;     // mm

// Detailing (kept subtle so OD stays uniform)
chamfer_length = 1.5;      // mm (axial)
chamfer_radial = 1.0;      // mm (radial)
groove_width   = 1.2;      // mm (axial)
groove_depth   = 0.5;      // mm (radial)
groove_offset_from_end = 6.0; // mm from each end to groove center
groove_count = 2;          // 0..2 supported here (top/bottom)
eps = 0.02;                // small boolean tolerance

ODr = outer_diameter/2;
IDr = bore_diameter/2;

module sleeve_base() {
    difference() {
        cylinder(h=bearing_length, r=ODr, center=true);
        cylinder(h=bearing_length + 2*eps, r=IDr, center=true);
    }
}

// Subtractive chamfer ring at an end (keeps OD at 28 except for chamfer)
module end_chamfer(zsign=1) {
    // Place chamfer so its outer face is flush with the end
    translate([0,0, zsign*(bearing_length/2 - chamfer_length/2)])
        difference() {
            // Outer envelope of the chamfer region
            cylinder(h=chamfer_length + 2*eps, r=ODr + eps, center=true);
            // Inner cone removes material to create chamfer
            cylinder(h=chamfer_length + 4*eps,
                     r1=ODr - chamfer_radial, r2=ODr,
                     center=true);
        }
}

// Subtractive shallow groove on OD (does not change overall OD elsewhere)
module marking_groove(zpos) {
    translate([0,0,zpos])
        difference() {
            cylinder(h=groove_width + 2*eps, r=ODr + eps, center=true);
            cylinder(h=groove_width + 4*eps, r=ODr - groove_depth, center=true);
        }
}

module linear_bearing() {
    difference() {
        sleeve_base();

        // End chamfers (subtractive)
        end_chamfer( 1);
        end_chamfer(-1);

        // Optional OD marking grooves (subtractive)
        if (groove_count >= 1)
            marking_groove( bearing_length/2 - groove_offset_from_end);
        if (groove_count >= 2)
            marking_groove(-bearing_length/2 + groove_offset_from_end);
    }
}

color([0.85, 0.85, 0.8]) linear_bearing();
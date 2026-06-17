$fn = 128;

// Brushless DC motor (stator) target dimensions
stator_d = 23.0;   // mm (requested)
motor_h  = 12.0;   // mm (requested)

// Key radii
R = stator_d/2;

// Visual/feature parameters (kept within overall 23x12 envelope)
lip_h      = 0.8;   // endcap lip height
lip_over   = 0.6;   // endcap lip radial overhang
seam_h     = 0.6;   // mid seam band height
seam_inset = 0.5;   // seam band inset from OD

// Front mounting face (typical outrunner faceplate)
face_h     = 1.2;
face_inset = 1.0;   // faceplate slightly smaller than OD

// Shaft
shaft_d        = 3.0;
shaft_len_out  = 7.0;
shaft_overlap  = 1.0;

// Mounting boss on bottom (small hub)
mount_boss_d       = 10.0;
mount_boss_h       = 1.2;
mount_boss_overlap = 0.6;

// Wire bundle exit (3 leads as a single connected bundle)
wire_bundle_d       = 3.2;
wire_len            = 7.0;
wire_overlap        = 1.0;
wire_z_from_bottom  = 3.0; // position along height (formula used below)

// Front ventilation slots (cut into front faceplate)
slot_count = 8;
slot_w     = 1.2;
slot_len   = 4.2;
slot_h     = face_h + 0.4; // ensure through-cut
slot_r     = (R - face_inset) * 0.55;

// Front bolt circle dimples (shallow cuts)
bolt_count = 4;
bolt_r     = (R - face_inset) * 0.62;
bolt_d     = 2.2;
bolt_depth = 0.5;

// Helper: radial array
module radial_array(n) {
    for (i = [0:n-1]) rotate([0,0,i*360/n]) children();
}

// Main can with end lips + mid seam band (all within 23mm OD)
module can_body() {
    union() {
        // Main cylinder (exact stator diameter and height)
        cylinder(d=stator_d, h=motor_h, center=true);

        // End lips (slight overhang)
        translate([0,0, motor_h/2 - lip_h/2])
            cylinder(d=stator_d + 2*lip_over, h=lip_h, center=true);

        translate([0,0,-motor_h/2 + lip_h/2])
            cylinder(d=stator_d + 2*lip_over, h=lip_h, center=true);

        // Mid seam band (slightly inset)
        cylinder(d=stator_d - 2*seam_inset, h=seam_h, center=true);
    }
}

// Front faceplate with vents + bolt dimples (subtractive details)
module front_faceplate() {
    // Place at top end, overlapping into can to ensure connectivity
    face_z = motor_h/2 - face_h/2; // sits flush with top
    difference() {
        translate([0,0, face_z])
            cylinder(d=stator_d - 2*face_inset, h=face_h, center=true);

        // Vent slots
        translate([0,0, face_z])
            radial_array(slot_count)
                translate([slot_r, 0, 0])
                    cube([slot_len, slot_w, slot_h], center=true);

        // Bolt dimples (shallow)
        translate([0,0, face_z + face_h/2 - bolt_depth/2])
            radial_array(bolt_count)
                translate([bolt_r, 0, 0])
                    cylinder(d=bolt_d, h=bolt_depth, center=true);
    }
}

// Shaft connected to front face (top)
module shaft() {
    translate([0,0, motor_h/2 + shaft_len_out/2 - shaft_overlap])
        cylinder(d=shaft_d, h=shaft_len_out, center=true);
}

// Bottom mounting boss connected to can
module mounting_boss() {
    translate([0,0, -motor_h/2 - mount_boss_h/2 + mount_boss_overlap])
        cylinder(d=mount_boss_d, h=mount_boss_h, center=true);
}

// Wire bundle exit connected to side of can
module wire_exit() {
    // Z position measured from bottom face, expressed as formula from motor_h
    // bottom face z = -motor_h/2, so z = -motor_h/2 + wire_z_from_bottom
    wire_z = -motor_h/2 + wire_z_from_bottom;

    translate([R + wire_len/2 - wire_overlap, 0, wire_z])
        rotate([0,90,0])
            cylinder(d=wire_bundle_d, h=wire_len, center=true);
}

// Small rear bearing bulge (subtle, still within OD) to suggest rotor/bell structure
module rear_bulge() {
    bulge_h = 1.0;
    bulge_d = stator_d - 1.6; // inset so it doesn't exceed OD
    // Place near bottom end, overlapping into can
    translate([0,0, -motor_h/2 + bulge_h/2 + lip_h])
        cylinder(d=bulge_d, h=bulge_h, center=true);
}

module bldc_motor_23x12() {
    union() {
        // Base can
        can_body();

        // BLDC-like details
        front_faceplate();
        rear_bulge();

        // Functional features
        shaft();
        mounting_boss();
        wire_exit();
    }
}

bldc_motor_23x12();
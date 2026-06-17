// Dimension-calibrated (target: 0.01 x 0.01 x 0.00 mm)
scale([0.001500, 0.001222, 0.000333])
{
// Short thick sleeve/cap-like solid with chamfered ends, a distinct circumferential step/groove,
// and an asymmetric side lug/flat with a clearly visible notch cutout.
// One connected solid; all placements derived from dimensions.

$fn = 128;

// ---- Parameters (mm) ----
outer_d        = 9.0;
body_h         = 3.0;

edge_chamfer_h = 0.35;   // small end chamfer height

// Circumferential groove/step near one end (implemented as a reduced-OD band)
step_d         = 8.0;    // reduced OD at the band (more distinct)
step_h         = 0.85;   // band height (more distinct)
step_from_end  = 0.20;   // distance from bottom end to start of band

// Lug / flat feature (asymmetric)
lug_len_radial = 2.0;    // how far it sticks out radially (+X)
lug_w_tan      = 3.0;    // tangential width (Y)
lug_h_z        = 2.2;    // height in Z

// Notch cutout in lug (visible from outside)
notch_len      = 1.35;   // along radial (X)
notch_w        = 1.35;   // along Y
notch_h        = 1.8;    // along Z
notch_inset    = 0.10;   // inset from lug outer face
notch_y_offset = 0.75;   // shift notch off-center to make it asymmetric

// Overlap to ensure watertight unions/differences
eps = 0.02;
overlap = 1.0;           // requested 1–2mm overlap for solid connections

// ---- Helpers ----
module chamfered_cylinder(d, h, ch) {
    ch2 = min(ch, h/2 - eps);
    r1 = d/2;
    r2 = max(r1 - ch2, eps);

    union() {
        translate([0,0,ch2])
            cylinder(h=h-2*ch2, r=r1);

        cylinder(h=ch2, r1=r2, r2=r1);

        translate([0,0,h-ch2])
            cylinder(h=ch2, r1=r1, r2=r2);
    }
}

module body_with_step() {
    difference() {
        chamfered_cylinder(outer_d, body_h, edge_chamfer_h);

        // Remove the annulus between step_d and outer_d to create a shallow groove/step band
        translate([0,0,step_from_end])
            difference() {
                cylinder(h=step_h, r=outer_d/2 + eps);
                cylinder(h=step_h + eps, r=step_d/2);
            }
    }
}

module lug_solid() {
    // Lug attached to +X side; overlap into cylinder by 'overlap' to guarantee connectivity.
    // Place lug so its inner face penetrates the cylinder by 'overlap'.
    lug_center_x = outer_d/2 + lug_len_radial/2 - overlap;

    translate([lug_center_x, 0, body_h/2])
        cube([lug_len_radial, lug_w_tan, lug_h_z], center=true);
}

module lug_notch_cut() {
    // Cut a notch from the OUTER face of the lug inward, offset in Y for asymmetry.
    lug_center_x = outer_d/2 + lug_len_radial/2 - overlap;
    lug_outer_face_x = lug_center_x + lug_len_radial/2;

    // Notch center positioned so its outer face is inset from lug outer face by notch_inset
    notch_center_x = lug_outer_face_x - notch_inset - notch_len/2;

    // Make the notch cut fully pass through the lug in Z so it reads clearly in orthographic views.
    // Also extend slightly in Y and Z for robust boolean.
    translate([notch_center_x, notch_y_offset, body_h/2])
        cube([notch_len + eps, notch_w + eps, max(notch_h, lug_h_z) + 2*eps], center=true);
}

module model() {
    union() {
        body_with_step();

        // Lug with notch removed (still connected to body via overlap)
        difference() {
            lug_solid();
            lug_notch_cut();
        }
    }
}

// ---- Final ----
model();
}

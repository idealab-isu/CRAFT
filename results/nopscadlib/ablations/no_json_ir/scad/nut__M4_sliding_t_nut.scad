$fn = 96;

// Target constraints
nut_thickness  = 3.7;   // Z thickness
nut_width_af   = 6.0;   // across flats (hex)
screw_diameter = 4.0;   // M4 clearance/through

// T-slot nut body sizing (typical)
body_len   = 12.0;      // length along slot (Y)
corner_r   = 1.2;       // end rounding for obround (<= min(body_len/2, body_w/2))

// Anti-rotation nibs (small bumps on the long sides)
nib_w = 1.0;            // nib width in X
nib_h = 0.6;            // nib protrusion in Y

// Robust overlap to guarantee connectivity (1–2mm as required)
overlap = 1.2;
eps     = 0.02;

// 2D obround (capsule) profile: length along Y, width along X
module obround2d(len_y, wid_x, r) {
    r2 = min(r, wid_x/2, len_y/2);
    hull() {
        translate([0,  len_y/2 - r2]) circle(r=r2);
        translate([0, -len_y/2 + r2]) circle(r=r2);
    }
}

// 2D regular hex with across-flats = af
module hex2d_af(af) {
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    polygon(points=[for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

// Nut (hex prism) that is physically attached to the T-slot body
module attached_hex_nut() {
    // Hex nut thickness: keep same as body to match original intent (3.7mm)
    nut_h = nut_thickness;

    // Place nut on +X side and overlap into body by 'overlap'
    // Body half-width in X is nut_width_af/2 (since body width uses nut_width_af)
    // Nut half-width across flats is nut_width_af/2 as well.
    // Center-to-center offset for overlap:
    // (body_half + nut_half - overlap)
    x_off = (nut_width_af/2) + (nut_width_af/2) - overlap;

    translate([x_off, 0, 0])
        linear_extrude(height=nut_h, center=true)
            hex2d_af(nut_width_af);
}

module t_slot_nut() {
    difference() {
        // ONE connected solid: main body + nibs + attached nut (with guaranteed overlap)
        union() {
            // Main body: obround block (X=nut_width_af, Y=body_len, Z=nut_thickness)
            linear_extrude(height=nut_thickness, center=true)
                obround2d(body_len, nut_width_af, corner_r);

            // Anti-rotation nibs on ±Y (intersect main body by 'overlap')
            for (sy = [-1, 1]) {
                translate([0,
                           sy * (body_len/2 + nib_h/2 - overlap),
                           0])
                    cube([nib_w, nib_h, nut_thickness], center=true);
            }

            // Missing part: nut (hex body) — attached with 1–2mm overlap
            attached_hex_nut();
        }

        // Central through-hole for M4 (through everything)
        cylinder(d=screw_diameter, h=nut_thickness + 4, center=true);

        // Hex pocket/profile (across flats = 6.0mm) in the MAIN BODY ONLY.
        // Limit the pocket to the body region so the added nut remains a solid "nut" part.
        // Body spans X in [-nut_width_af/2, +nut_width_af/2].
        // Clip the pocket to that range (with a tiny margin).
        intersection() {
            linear_extrude(height=nut_thickness + 4, center=true)
                hex2d_af(nut_width_af);

            translate([-nut_width_af/2 - eps, -body_len/2 - eps, -(nut_thickness/2 + 2)])
                cube([nut_width_af + 2*eps, body_len + 2*eps, nut_thickness + 4], center=false);
        }
    }
}

t_slot_nut();
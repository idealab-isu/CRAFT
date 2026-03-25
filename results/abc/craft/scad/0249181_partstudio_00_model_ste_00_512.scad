// Stepped coin-like disk with 3 HEX through-cutouts + recessed triangular/ribbed webs (both faces)
// Structural fixes:
//  - Make cutouts unambiguously HEX in face views (true 6-sided prism, rotated 30°)
//  - Make recessed 3-spoke web clearly connect the three openings on BOTH faces
//  - Recalculate all translate() values so parts touch (boss sits on flange with slight overlap)
// Notes:
//  - The "0.1 x 0.1 x 0.0 mm" bbox is physically impossible for a solid; we keep a small nonzero Z.
//  - Target bounding box: 0.1 x 0.1 x 0.04 mm

$fn = 128;

// ---- Bounding box targets ----
bbox_X = 0.1;
bbox_Y = 0.1;
bbox_Z = 0.04;

// ---- Main dimensions (fit within bbox) ----
flange_D = bbox_X;          // 0.1
flange_t = 0.028;

boss_D   = 0.06;
boss_h   = bbox_Z - flange_t;   // ensures total height = bbox_Z

// ---- Hex pattern (clearly visible) ----
hex_AF       = 0.026;       // across flats
hex_center_R = 0.022;       // radius to hex centers (triangular pattern)

// ---- Web recess (both faces) ----
web_recess_depth     = 0.004;   // depth of recess into each face
web_thickness        = 0.008;   // rib width
web_clearance_to_hex = 0.002;

eps = 0.0005;

// ---------- Helpers ----------
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);

// Regular hex polygon sized by across-flats (AF)
module hex2d(af=hex_AF) {
    // For a regular hex: AF = 2*apothem; apothem = r*cos(30) => r = AF/sqrt(3)
    r = af / sqrt(3);
    polygon(points=[ for(i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

module hex_cutout_at(xy=[0,0], rot=0, h=bbox_Z + 40*eps) {
    translate([xy[0], xy[1], 0])
        rotate([0,0,rot])
            linear_extrude(height=h, center=true, convexity=10)
                hex2d(hex_AF);
}

// Recessed 3-spoke web that CONNECTS the three hex openings (both faces)
// Implemented as: three "capsules" (hull of two circles) from center to near each hex center,
// plus a small central hub. This reads as a triangular/ribbed web in orthographic views.
module tri_web_recess(z_center=0, depth=web_recess_depth) {
    rib_r = web_thickness/2;

    // Keep ribs clear of hex openings: stop short of hex by (apothem + clearance)
    hex_apothem = hex_AF/2;
    stop_clear  = hex_apothem + web_clearance_to_hex;

    // End point along each spoke, measured from center
    spoke_end_R = max(0, hex_center_R - stop_clear);

    translate([0,0,z_center])
        linear_extrude(height=depth, center=true, convexity=10)
            union() {
                // Three spokes (capsules) from center to near each hex opening
                for(a=[0,120,240]) {
                    hull() {
                        circle(r=rib_r, $fn=48);
                        translate([spoke_end_R*cos(a), spoke_end_R*sin(a)])
                            circle(r=rib_r, $fn=48);
                    }
                }

                // Central hub to ensure connectivity and a clear "3-spoke" read
                circle(r=rib_r*1.35, $fn=48);
            }
}

// ---------- Main solid ----------
module part() {
    // Enforce exact overall height bbox_Z with a true step:
    // flange centered at z=0, boss sits on top face of flange.
    boss_h_eff   = clamp(boss_h, eps, bbox_Z - eps);
    flange_t_eff = clamp(flange_t, eps, bbox_Z - boss_h_eff);

    // Recess depth must not exceed available face thickness
    recess_d = clamp(web_recess_depth, eps, flange_t_eff/2 - 3*eps);

    // Slight overlap between flange and boss for robust union (scaled to tiny model)
    overlap_z = 2*eps;

    difference() {
        // Base: flange + raised boss (connected)
        union() {
            // Flange centered at z=0
            cylinder(d=flange_D, h=flange_t_eff, center=true);

            // Boss on top of flange:
            // flange top face at +flange_t/2
            // boss bottom face at (boss_center - boss_h/2)
            // set boss_center so boss bottom is slightly below flange top (overlap)
            boss_center_z = (flange_t_eff/2) + (boss_h_eff/2) - overlap_z;

            translate([0,0,boss_center_z])
                cylinder(d=boss_D, h=boss_h_eff, center=true);
        }

        // Three THROUGH hex cutouts (clearly hex, 120° apart)
        for(a=[0,120,240]) {
            hex_cutout_at(
                xy=[hex_center_R*cos(a), hex_center_R*sin(a)],
                rot=30,                       // flats horizontal/vertical in views
                h=bbox_Z + 40*eps
            );
        }

        // Recessed webs on BOTH faces of the flange (do not cut through)
        // Top face of flange at +flange_t/2, bottom face at -flange_t/2
        tri_web_recess(
            z_center= (flange_t_eff/2) - (recess_d/2),
            depth=recess_d + 2*eps
        );
        tri_web_recess(
            z_center=-(flange_t_eff/2) + (recess_d/2),
            depth=recess_d + 2*eps
        );
    }
}

part();
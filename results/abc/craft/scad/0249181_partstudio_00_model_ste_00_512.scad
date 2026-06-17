// Dimension-calibrated (target: 0.10 x 0.10 x 0.04 mm)
scale([1.000000, 1.000000, 2.058824])
{
// Round coin-like disk with stepped profile (wide flange + raised boss),
// three through hex cutouts in triangular pattern, and recessed/ribbed webs
// on BOTH faces connecting the hex openings.
// NOTE: The original "bbox 0.1 x 0.1 x 0.0 mm" is physically incompatible with a
// visible stepped boss. This version keeps the part plate-like but gives it a
// clear step in side view by using a small (but nonzero) thickness and boss height.

$fn = 96;

// -------------------- Parameters --------------------
plate_d = 0.10;          // overall flange diameter
plate_t = 0.012;         // flange thickness (thin/plate-like but visible)

boss_d  = 0.060;         // raised central boss diameter (smaller than flange)
boss_h  = 0.006;         // boss height above flange (clear step)

hex_af        = 0.020;   // hex across flats
hex_center_r  = 0.022;   // radius to each hex center (triangular pattern)

web_clearance_to_rim = 0.008;

web_recess_depth = 0.0020;   // recess depth on each face (clamped to available thickness)
rib_count        = 6;
rib_groove_w     = 0.0012;
rib_groove_depth = 0.0012;

overlap = 0.001;         // small overlap to ensure watertight unions/differences

// -------------------- Helpers --------------------
function hex_R_from_af(af) = af / sqrt(3); // circumradius for pointy-top hex

module hex2d(af){
    R = hex_R_from_af(af);
    polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module stepped_body(){
    // Single connected solid: flange + boss with slight Z overlap
    union(){
        // Flange centered at Z=0
        cylinder(d=plate_d, h=plate_t, center=true);

        // Boss sits on top face of flange (explicit step)
        // Translate computed so it touches with overlap (no floating).
        translate([0,0, plate_t/2 + boss_h/2 - overlap])
            cylinder(d=boss_d, h=boss_h, center=true);
    }
}

module hex_hole_at(angle_deg){
    // Through-hole across entire stepped thickness
    total_h = plate_t + boss_h;
    rotate([0,0,angle_deg])
        translate([hex_center_r, 0, 0])
            linear_extrude(height = total_h + 6*overlap, center=true)
                hex2d(hex_af);
}

module all_hex_holes(){
    union(){
        hex_hole_at(0);
        hex_hole_at(120);
        hex_hole_at(240);
    }
}

module web_triangle_2d(){
    // Triangle connecting the three hex centers, expanded to form a web region.
    r_lim = plate_d/2 - web_clearance_to_rim;
    r_use = min(hex_center_r, r_lim);

    pts = [
        [ r_use*cos(0),   r_use*sin(0)   ],
        [ r_use*cos(120), r_use*sin(120) ],
        [ r_use*cos(240), r_use*sin(240) ]
    ];

    offset(delta = 0.006) polygon(pts);
}

module recessed_web_face(z_sign=+1){
    // Recessed triangular web on one face (subtract)
    // Clamp to available thickness on that face.
    d = min(web_recess_depth, plate_t/2 - 2*overlap);
    z0 = z_sign*(plate_t/2 - d/2);

    translate([0,0,z0])
        linear_extrude(height=d + 2*overlap, center=true)
            web_triangle_2d();
}

module rib_grooves_on_face(z_sign=+1){
    // Grooves cut into the recessed web area, arranged along 3 spokes.
    d = min(rib_groove_depth, plate_t/2 - 2*overlap);
    z0 = z_sign*(plate_t/2 - d/2);

    r_in  = 0.0;
    r_out = plate_d/2 - web_clearance_to_rim;
    spoke_len = r_out - r_in;

    spoke_band_w = 0.010;
    groove_pitch = spoke_band_w/(rib_count+1);

    for (a = [0,120,240]){
        rotate([0,0,a])
            for (i = [1:rib_count]){
                y = (i - (rib_count+1)/2) * groove_pitch;
                translate([ (r_in + r_out)/2, y, z0 ])
                    cube([spoke_len + 2*overlap, rib_groove_w, d + 2*overlap], center=true);
            }
    }
}

module all_recesses_and_ribs(){
    union(){
        recessed_web_face(+1);
        recessed_web_face(-1);
        rib_grooves_on_face(+1);
        rib_grooves_on_face(-1);
    }
}

// -------------------- Final Model --------------------
difference(){
    stepped_body();          // flange + raised boss (explicit stepped profile)
    all_hex_holes();         // 3 through hex cutouts
    all_recesses_and_ribs(); // recessed triangular webs + rib grooves on both faces
}
}

$fn = 64;

// Solid State Relay module (single connected solid), overall: 58 x 45 x 33 mm
module ssr_module(len=58.0, wid=45.0, ht=33.0, corner_r=2.5) {

    eps = 0.25; // small overlap to guarantee connectivity

    // Base + body split (kept within overall height)
    base_th = 4.0;
    body_th = ht - base_th;

    // Side mounting ears (flanges) integrated into base, but kept within overall length
    ear_wid = wid * 0.22;
    ear_th  = base_th * 0.85;
    ear_ext = len * 0.08;                 // extension beyond body on each side
    body_len = len - 2*ear_ext;           // body length so ears bring total to len

    // Top terminal block (protrusion on top face), kept within overall envelope
    term_len = body_len * 0.78;
    term_wid = wid * 0.28;
    term_h   = ht * 0.18;

    // Underside ribs (heatsink-like), kept within overall envelope (do not extend below z=0)
    rib_count = 6;
    rib_h     = base_th * 0.55;
    rib_w     = wid * 0.06;
    rib_len   = body_len * 0.86;

    // Small top edge lip (subtle detail)
    lip_h = 1.2;
    lip_inset = 1.0;

    // Helper: rounded rectangle prism (rounded in XY, straight in Z)
    module rounded_prism_xy(L, W, H, R) {
        R2 = min(R, min(L, W)/2 - 0.01);
        minkowski() {
            cube([L - 2*R2, W - 2*R2, H], center=false);
            cylinder(h=0.01, r=R2, center=false);
        }
    }

    union() {

        // --- Base plate (metal) spans full overall length/width ---
        rounded_prism_xy(len, wid, base_th, max(0.8, corner_r*0.6));

        // --- Plastic body on top of base (shorter in length to allow ears within overall len) ---
        translate([ear_ext, 0, base_th - eps])
            rounded_prism_xy(body_len, wid, body_th + eps, corner_r);

        // --- Side mounting ears (connected to base), within overall length ---
        // Left ear occupies x=[0, ear_ext]
        translate([0, (wid - ear_wid)/2, 0])
            rounded_prism_xy(ear_ext + eps, ear_wid, ear_th, max(0.8, corner_r*0.4));

        // Right ear occupies x=[len-ear_ext, len]
        translate([len - ear_ext - eps, (wid - ear_wid)/2, 0])
            rounded_prism_xy(ear_ext + eps, ear_wid, ear_th, max(0.8, corner_r*0.4));

        // --- Top terminal block (connected), centered on body top ---
        translate([
            ear_ext + (body_len - term_len)/2,
            (wid - term_wid)/2,
            ht - term_h - eps
        ])
            rounded_prism_xy(term_len, term_wid, term_h + eps, max(1.0, corner_r*0.5));

        // --- Underside ribs (heatsink-like), connected to base underside but not below z=0 ---
        // Place ribs starting at z=0, overlapping into base by eps
        for (i = [0 : rib_count-1]) {
            translate([
                ear_ext + (body_len - rib_len)/2,
                (wid - rib_count*rib_w)/(rib_count+1) * (i+1) + rib_w*i,
                0
            ])
                cube([rib_len, rib_w, rib_h + eps], center=false);
        }

        // --- Small top edge lip (subtle detail), connected ---
        translate([ear_ext + lip_inset, lip_inset, ht - lip_h - eps])
            rounded_prism_xy(body_len - 2*lip_inset, wid - 2*lip_inset, lip_h + eps, max(1.0, corner_r*0.45));
    }
}

ssr_module();
$fn = 96;

// T-slot nut for 5.0mm screw, 6.0mm across flats, 3.7mm thick

// --- Critical dimensions ---
thickness = 3.7;          // overall thickness (Z)
screw_d   = 5.0;          // screw size (through hole diameter target)
clear_d   = 5.4;          // clearance for M5 (typical printed/laser)
af        = 6.0;          // across flats for hex capture

// --- T-slot nut body (generic T-profile) ---
len_top   = 12.0;         // top head length (X)
wid_top   = 10.0;         // top head width  (Y)

len_neck  = 8.0;          // neck length (X) - narrower section
wid_neck  = 6.0;          // neck width  (Y)

neck_h    = 1.6;          // neck height from bottom (Z)
head_h    = thickness - neck_h;

corner_r  = 0.8;          // corner radius
chamfer   = 0.35;         // edge chamfer height (top/bottom)

// --- Helpers ---
module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2)]) circle(r=r2);
    }
}

module hex_prism_af(af, h){
    // Regular hex with given across-flats
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module tslot_body(){
    // One connected solid: neck + head, with consistent Z stacking
    union(){
        // Neck (bottom)
        linear_extrude(height=neck_h)
            rounded_rect_2d(len_neck, wid_neck, min(corner_r, min(len_neck,wid_neck)/2));

        // Head (top)
        translate([0,0,neck_h])
            linear_extrude(height=head_h)
                rounded_rect_2d(len_top, wid_top, corner_r);
    }
}

module chamfer_shell(){
    // Apply top/bottom chamfers to the overall T-profile by scaling in Z slices
    // Bottom chamfer slice
    bottom_scale_x = (len_top - 2*chamfer) / len_top;
    bottom_scale_y = (wid_top - 2*chamfer) / wid_top;

    union(){
        // Bottom chamfer (slightly smaller footprint)
        linear_extrude(height=chamfer, scale=[bottom_scale_x, bottom_scale_y])
            // Use the head outline for chamfer footprint (keeps edges clean)
            rounded_rect_2d(len_top, wid_top, corner_r);

        // Middle straight section
        translate([0,0,chamfer])
            linear_extrude(height=thickness-2*chamfer)
                projection(cut=false)
                    translate([0,0,0])
                        // Project the unioned T body to 2D footprint at Z=0
                        // (ensures chamfered shell encloses the T profile)
                        tslot_body();

        // Top chamfer (slightly smaller footprint)
        translate([0,0,thickness-chamfer])
            linear_extrude(height=chamfer, scale=[bottom_scale_x, bottom_scale_y])
                rounded_rect_2d(len_top, wid_top, corner_r);
    }
}

difference(){
    // Base solid: true T-slot nut profile (neck + head), then chamfered outer shell
    // Intersect chamfer shell with actual T body to keep T profile while chamfering edges.
    intersection(){
        chamfer_shell();
        tslot_body();
    }

    // Through clearance hole (centered, guaranteed visible in top/bottom views)
    translate([0,0,-0.2])
        cylinder(h=thickness+0.4, d=clear_d);

    // Hex capture pocket on top (6.0mm across flats)
    hex_depth = min(2.2, thickness-1.0);
    translate([0,0,thickness-hex_depth])
        hex_prism_af(af, hex_depth+0.25);
}
$fn=96;

// Peacefair PZEM-001 AC panel meter (approximate, single connected solid)
// Units: mm
// Coordinate system: front face at z=0, body extends to +z, centered in X/Y

// ---------- Parameters ----------
body_w = 80;
body_h = 43;
body_d = 25;

bezel_w = 85;
bezel_h = 45;
bezel_t = 3;

corner_r = 2.5;

// Front display window (recess + opening)
face_recess = 1.2;
window_w = 62;
window_h = 26;
window_r = 1.5;

// Bottom front "button/label" strip (as a recessed band)
strip_h = 10;
strip_margin = 2.0;
strip_recess = 0.8;

// Right-side front buttons (two small recessed circles typical of PZEM-001)
btn_d = 5.2;
btn_spacing = 9.0;
btn_recess = 0.9;
btn_x_inset = 9.0;     // from right bezel edge
btn_y = -(bezel_h/2 - strip_h/2 - strip_margin); // aligned with strip band

// Terminal block at back (kept connected)
terminal_block_w = 80;
terminal_block_h = 12;
terminal_block_d = 10;

// Terminal holes (visual only; do not cut through entire body)
term_hole_d = 4.2;
term_hole_count = 7;
term_hole_pitch = 10;

// Bezel screw holes (countersunk)
screw_d = 3.2;
screw_head_d = 6.5;
screw_head_h = 1.8;
screw_offset_x = 38;
screw_offset_y = 18;

// Small overlap to guarantee connectivity
overlap = 0.6;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    }
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

module countersunk_hole(d_thru, d_head, h_head, depth){
    // For difference(): starts at z=0 and goes +z
    union(){
        cylinder(d=d_thru, h=depth, center=false);
        cylinder(d1=d_head, d2=d_thru, h=h_head, center=false);
    }
}

// ---------- Model ----------
module pzem001_meter(){
    // Derived placements (no arbitrary translations)
    body_z0 = bezel_t - overlap;                 // body starts slightly into bezel
    body_z1 = body_z0 + body_d;

    // Terminal block: attached to back of body with overlap
    term_z0 = body_z1 - overlap;
    term_y  = -(body_h/2 - terminal_block_h/2 - 1.5);

    // Front strip band position (bottom area on bezel)
    strip_y = -(bezel_h/2 - strip_h/2 - strip_margin);

    // Display window position (slightly above center like typical PZEM-001)
    win_y = 3.0;

    // Right-side button X position (from right edge)
    btn_x = (bezel_w/2 - btn_x_inset);

    difference(){
        union(){
            // Bezel (front flange)
            rounded_box(bezel_w, bezel_h, bezel_t, corner_r+0.8);

            // Main body behind bezel (connected via overlap)
            translate([0,0,body_z0])
                rounded_box(body_w, body_h, body_d, corner_r);

            // Terminal block at back (connected via overlap)
            translate([0, term_y, term_z0])
                rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.2);

            // Raised inner frame around window (characteristic face detail)
            frame_t = 0.7;
            frame_w = window_w + 7;
            frame_h = window_h + 7;
            translate([0, win_y, bezel_t - frame_t - overlap/2])
                rounded_box(frame_w, frame_h, frame_t + overlap, window_r+1.0);

            // Slight raised "button island" on lower-right (still one solid, overlaps bezel)
            island_w = 18;
            island_h = strip_h + 2.0;
            island_t = 0.6;
            island_x = (bezel_w/2 - island_w/2 - strip_margin);
            translate([island_x, strip_y, bezel_t - island_t - overlap/2])
                rounded_box(island_w, island_h, island_t + overlap, 1.2);
        }

        // Display window recess in bezel
        translate([0, win_y, 0])
            linear_extrude(height=face_recess)
                rounded_rect_2d(window_w, window_h, window_r);

        // Through window opening (cut through bezel only)
        translate([0, win_y, 0])
            linear_extrude(height=bezel_t + 0.2)
                rounded_rect_2d(window_w-4, window_h-4, max(0.8, window_r-0.5));

        // Bottom strip recess (suggests label/button area)
        translate([0, strip_y, 0])
            linear_extrude(height=strip_recess)
                rounded_rect_2d(bezel_w - 2*strip_margin, strip_h, 1.2);

        // Two recessed round buttons on lower-right (cut into bezel only)
        for (j=[-0.5, 0.5]){
            translate([btn_x, btn_y + j*btn_spacing, 0])
                cylinder(d=btn_d, h=btn_recess, center=false);
        }

        // Bezel screw holes (countersunk)
        for (sx=[-screw_offset_x, screw_offset_x])
        for (sy=[-screw_offset_y, screw_offset_y]){
            translate([sx, sy, 0])
                countersunk_hole(screw_d, screw_head_d, screw_head_h, bezel_t + 0.5);
        }

        // Terminal block wire entry holes (cut into terminal block only, not through body)
        // Place holes centered in terminal block depth
        term_holes_z = term_z0 + terminal_block_d/2;
        term_holes_y = term_y; // centered in terminal block height
        start_i = -(term_hole_count-1)/2;
        for (k=[0:term_hole_count-1]){
            x = (start_i + k) * term_hole_pitch;
            translate([x, term_holes_y, term_holes_z])
                rotate([90,0,0])
                    cylinder(d=term_hole_d, h=terminal_block_h + 2, center=true);
        }

        // Shallow groove line near bezel perimeter (face detail)
        groove_t = 0.5;
        groove_inset = 1.2;
        translate([0,0,bezel_t - groove_t])
        difference(){
            rounded_box(bezel_w - 2*groove_inset, bezel_h - 2*groove_inset, groove_t + 0.1, corner_r+0.6);
            translate([0,0,-0.1])
                rounded_box(bezel_w - 2*(groove_inset+1.4), bezel_h - 2*(groove_inset+1.4), groove_t + 0.4, corner_r+0.2);
        }
    }
}

// ---------- Render ----------
pzem001_meter();
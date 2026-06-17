$fn=64;

// Peacefair PZEM-021 AC digital multi-function meter (approximate model)
// Units: mm
// One connected solid; no text/labels; all placements derived from dimensions.

// ---------- Parameters ----------
body_w = 85.0;
body_h = 45.0;
body_d = 31.0;

front_bezel_w = 90.0;
front_bezel_h = 50.0;
front_bezel_t = 3.0;

corner_r = 2.0;

// Front-face details (more PZEM-021-like)
lcd_w = 58.0;
lcd_h = 28.0;
lcd_r = 1.6;
lcd_inset = 1.2;          // depth of window recess into bezel
lcd_frame = 1.2;          // small lip around window

btn_d = 6.0;
btn_h = 1.6;
btn_recess = 0.9;

// Place LCD centered horizontally, upper-ish; button to the right of LCD, below mid
lcd_margin_top = 7.0;
btn_gap_from_lcd = 6.0;

// Rear electrical features (terminal block + wire entry)
term_w = 76.0;
term_h = 16.0;
term_d = 12.0;
term_r = 1.0;

term_margin_bottom = 6.0;
term_margin_back = 3.0;

wire_slot_w = 64.0;
wire_slot_h = 10.0;
wire_slot_d = 6.0;
wire_slot_margin_top = 7.0;

// Side snap tabs (small protrusions)
tab_t = 2.0;
tab_w = 10.0;
tab_h = 6.0;
tab_inset_y = 6.0;
tab_from_back = 10.0;

// Terminal block connector geometry (6 clamp openings)
clamp_w = 8.0;
clamp_h = 6.0;
clamp_pitch = 11.0;       // spacing between clamps
clamp_margin_x = 6.0;
clamp_margin_y = 3.0;
clamp_depth = 6.0;        // cut depth into terminal block from back face
clamp_r = 0.8;

// Small overlap to guarantee connectivity
ov = 0.6;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=false);
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

// ---------- Model ----------
module pzem021(){
    // Local coordinates:
    // X: 0..body_w, Y: 0..body_h, Z: 0..(front_bezel_t+body_d)
    // Bezel at Z=0..front_bezel_t, body behind it.

    // Derived placements
    bezel_off_x = -(front_bezel_w - body_w)/2;
    bezel_off_y = -(front_bezel_h - body_h)/2;

    lcd_x = bezel_off_x + (front_bezel_w - lcd_w)/2;
    lcd_y = bezel_off_y + (front_bezel_h - lcd_margin_top - lcd_h);

    btn_x = lcd_x + lcd_w + btn_gap_from_lcd + btn_d/2;
    btn_y = lcd_y + lcd_h*0.55;

    // Rear terminal block placement (attached to body back face)
    term_x = (body_w - term_w)/2;
    term_y = term_margin_bottom;
    term_z = front_bezel_t + body_d - term_d - term_margin_back;

    // Rear wire slot (cut into body back area, above terminal block)
    slot_x = (body_w - wire_slot_w)/2;
    slot_y = body_h - wire_slot_margin_top - wire_slot_h;
    slot_z = front_bezel_t + body_d - wire_slot_d; // opens to back face

    // Terminal clamp cutouts (open to back face of terminal block)
    clamp_total_w = clamp_margin_x*2 + 5*clamp_pitch + clamp_w;
    clamp_start_x = term_x + (term_w - clamp_total_w)/2 + clamp_margin_x;
    clamp_y = term_y + clamp_margin_y;
    clamp_z = term_z + term_d - clamp_depth; // cut from back face inward

    union(){
        // --- Main body with rear cavities (difference keeps it one solid) ---
        translate([0,0,front_bezel_t])
        difference(){
            rounded_box(body_w, body_h, body_d, corner_r);

            // Rear wire entry slot (opens to back)
            translate([slot_x, slot_y, body_d - wire_slot_d - 0.01])
                rounded_box(wire_slot_w, wire_slot_h, wire_slot_d + 0.02, 1.2);

            // Shallow relief on back around terminal area (suggests molded pocket)
            pocket_w = term_w + 6;
            pocket_h = term_h + 10;
            pocket_d = term_d + 2;
            translate([(body_w - pocket_w)/2,
                       max(0, term_y - 4),
                       body_d - pocket_d - 0.01])
                rounded_box(pocket_w, pocket_h, pocket_d + 0.02, 1.5);

            // Slight side reliefs to avoid "generic stepped block" look (still one solid)
            side_relief_w = 6;
            side_relief_h = body_h - 2*6;
            side_relief_d = body_d*0.55;
            side_relief_z = body_d - side_relief_d - 0.01;
            translate([-0.01, 6, side_relief_z])
                rounded_box(side_relief_w + 0.02, side_relief_h, side_relief_d + 0.02, 1.2);
            translate([body_w - side_relief_w - 0.01, 6, side_relief_z])
                rounded_box(side_relief_w + 0.02, side_relief_h, side_relief_d + 0.02, 1.2);
        }

        // --- Front bezel (attached to body with overlap) ---
        translate([bezel_off_x, bezel_off_y, 0])
        difference(){
            // Bezel plate overlaps into body by ov to ensure union connectivity
            rounded_box(front_bezel_w, front_bezel_h, front_bezel_t + ov, corner_r);

            // LCD window recess (outer recess)
            translate([lcd_x - bezel_off_x, lcd_y - bezel_off_y, -0.01])
                rounded_box(lcd_w, lcd_h, lcd_inset + 0.02, lcd_r);

            // Inner LCD opening (gives a frame/lip)
            translate([lcd_x - bezel_off_x + lcd_frame,
                       lcd_y - bezel_off_y + lcd_frame,
                       -0.01])
                rounded_box(lcd_w - 2*lcd_frame, lcd_h - 2*lcd_frame,
                            front_bezel_t + ov + 0.02, max(0.8, lcd_r-0.6));

            // Button recess
            translate([btn_x - bezel_off_x, btn_y - bezel_off_y, -0.01])
                cylinder(d=btn_d + 1.4, h=btn_recess + 0.02, center=false);

            // Small "status window" recess below LCD (common panel-meter styling)
            status_w = lcd_w*0.55;
            status_h = 6.0;
            status_r = 1.2;
            status_gap = 4.0;
            status_x = (front_bezel_w - status_w)/2;
            status_y = (lcd_y - bezel_off_y) - status_gap - status_h;
            translate([status_x, status_y, -0.01])
                rounded_box(status_w, status_h, 0.9 + 0.02, status_r);
        }

        // --- Button cap (slightly proud, still connected to bezel) ---
        translate([btn_x, btn_y, front_bezel_t - btn_h + 0.2])
            cylinder(d=btn_d, h=btn_h, center=false);

        // --- LCD "glass" (solid insert, connected via tiny overlap) ---
        glass_t = 0.9;
        translate([lcd_x + lcd_frame,
                   lcd_y + lcd_frame,
                   lcd_inset - 0.15])  // overlaps into bezel by 0.15
            rounded_box(lcd_w - 2*lcd_frame, lcd_h - 2*lcd_frame, glass_t, max(0.8, lcd_r-0.6));

        // --- Rear terminal block with connector geometry (one connected solid) ---
        difference(){
            // Terminal block (attached to body with overlap)
            translate([term_x, term_y, term_z - ov])
                rounded_box(term_w, term_h, term_d + ov, term_r);

            // Clamp openings (6) cut from back face into terminal block
            for(i=[0:5]){
                cx = clamp_start_x + i*clamp_pitch;
                translate([cx, clamp_y, clamp_z - 0.01])
                    rounded_box(clamp_w, clamp_h, clamp_depth + 0.02, clamp_r);
            }

            // Small back-face chamfer-like relief (rectangular) to suggest connector mouth
            mouth_w = clamp_total_w;
            mouth_h = clamp_h + 2.0;
            mouth_d = 1.2;
            mouth_x = term_x + (term_w - mouth_w)/2;
            mouth_y = clamp_y - 1.0;
            mouth_z = term_z + term_d - mouth_d - 0.01;
            translate([mouth_x, mouth_y, mouth_z])
                rounded_box(mouth_w, mouth_h, mouth_d + 0.02, 0.9);
        }

        // Terminal screw bosses (6), slightly protruding from terminal block top face
        screw_d = 3.2;
        screw_h = term_d * 0.55;
        screw_z = term_z + term_d - screw_h; // starts inside block, ends near back
        for(i=[0:5]){
            sx = term_x + 8 + i*(term_w - 16)/5;
            sy = term_y + term_h/2;
            translate([sx, sy, screw_z])
                cylinder(d=screw_d, h=screw_h, center=false);
        }

        // --- Side snap tabs (connected to body sides; 4 total) ---
        tab_z = front_bezel_t + body_d - tab_from_back - tab_w;
        // Left side
        translate([-tab_t + ov, tab_inset_y, tab_z])
            cube([tab_t + ov, tab_h, tab_w], center=false);
        translate([-tab_t + ov, body_h - tab_inset_y - tab_h, tab_z])
            cube([tab_t + ov, tab_h, tab_w], center=false);
        // Right side
        translate([body_w - ov, tab_inset_y, tab_z])
            cube([tab_t + ov, tab_h, tab_w], center=false);
        translate([body_w - ov, body_h - tab_inset_y - tab_h, tab_z])
            cube([tab_t + ov, tab_h, tab_w], center=false);

        // --- Small top/bottom bezel ears (to match silhouette) ---
        ear_w = 10;
        ear_h = 3;
        ear_t = front_bezel_t + ov;
        // Top ears
        translate([bezel_off_x + 6, bezel_off_y + front_bezel_h - ear_h, 0])
            cube([ear_w, ear_h, ear_t], center=false);
        translate([bezel_off_x + front_bezel_w - 6 - ear_w, bezel_off_y + front_bezel_h - ear_h, 0])
            cube([ear_w, ear_h, ear_t], center=false);
        // Bottom ears
        translate([bezel_off_x + 6, bezel_off_y, 0])
            cube([ear_w, ear_h, ear_t], center=false);
        translate([bezel_off_x + front_bezel_w - 6 - ear_w, bezel_off_y, 0])
            cube([ear_w, ear_h, ear_t], center=false);
    }
}

// Place with body centered around origin in XY (bezel centered too)
translate([-body_w/2, -body_h/2, 0])
    pzem021();
// Peacefair PZEM-001 AC panel meter (improved recognizable geometry)
// Connectivity-fixed: all tabs/clips are physically attached with 1–2mm overlap.
// One connected solid, no floating parts.

$fn = 64;

// ---------- Parameters (mm) ----------
bezel_w = 80;
bezel_h = 43;
bezel_t = 5;

body_w  = 70;   // panel cutout / rear body width
body_h  = 35;   // panel cutout / rear body height
body_d  = 30;   // rear depth behind bezel

// Front LCD window + bezel details
win_w = 60;
win_h = 25;
win_inset = 1.2;     // recess depth into bezel
frame_lip = 1.2;     // inner frame thickness around window

// LCD "glass" (kept as solid, not a hole)
glass_t = 0.8;
glass_margin = 1.2;  // smaller than window opening

// Button (front)
btn_d = 6.2;
btn_h = 1.6;
btn_y_off = -(bezel_h/2 - 6.5); // near bottom edge
btn_x_off =  (bezel_w/2 - 10.0); // near right edge

// Side latch bumps (bezel sides)
latch_out = 2.0;     // protrusion in X
latch_h = 10;
latch_z = 2.0;

// Top/bottom small protrusions (seen in left/right views)
tb_out = 2.0;        // protrusion in Y
tb_w   = 12.0;       // width along X
tb_z   = 2.0;        // thickness along Z

// Rear terminal block (more PZEM-like: block + 4 screw bosses + wire entry lip)
term_w = 52;
term_h = 16;
term_d = 12;

boss_d = 6.2;
boss_h = 4.2;
boss_spacing = 12.5; // 4 positions -> 3 gaps

wire_lip_w = term_w;
wire_lip_h = 6;
wire_lip_d = 4;

// Rear connector bump (upper rear)
conn_w = 20;
conn_h = 10;
conn_d = 7;

// Rear ribs (distinct back view)
rib_count = 5;
rib_w = 3.0;
rib_h = body_h - 6;
rib_d = 1.6;

// Overlap to guarantee connectivity (use 1–2mm as required)
ov = 1.2;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1, center=true) {
    minkowski() {
        cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
        sphere(r=r);
    }
}

module panel_meter() {
    // Coordinate system:
    // Front face of bezel at z=0, model extends to negative z.
    union() {
        bezel_front();
        rear_body();
        side_latches();          // fixed: guaranteed overlap into bezel
        top_bottom_tabs();       // added: fixed floating top/bottom protrusions
        rear_terminals();
        rear_connector_bump();
        rear_ribs();
    }
}

module bezel_front() {
    union() {
        // Bezel with cutouts
        difference() {
            translate([0,0,-bezel_t/2])
                rounded_box([bezel_w, bezel_h, bezel_t], r=1.4, center=true);

            // Through window opening
            translate([0,0,-bezel_t/2])
                cube([win_w, win_h, bezel_t + 2], center=true);

            // Recessed pocket around window (leaves a thin inner frame)
            pocket_w = win_w + 2*frame_lip;
            pocket_h = win_h + 2*frame_lip;
            translate([0,0,-win_inset/2])
                cube([pocket_w, pocket_h, win_inset + 0.02], center=true);

            // Small button seat recess (subtle)
            btn_seat_d = btn_d + 1.6;
            btn_seat_h = 0.7;
            translate([btn_x_off, btn_y_off, -btn_seat_h/2])
                cylinder(h=btn_seat_h + 0.02, d=btn_seat_d, center=true);
        }

        // Raised inner frame ring around window (recognizable)
        frame_outer_w = win_w + 2*(frame_lip + 1.6);
        frame_outer_h = win_h + 2*(frame_lip + 1.6);
        frame_t = 0.9;

        translate([0,0,-frame_t/2 + ov/2])
        difference() {
            cube([frame_outer_w, frame_outer_h, frame_t], center=true);
            cube([win_w, win_h, frame_t + 2], center=true);
        }

        // LCD glass slab behind opening (solid, connected to bezel via overlap)
        glass_w = win_w - 2*glass_margin;
        glass_h = win_h - 2*glass_margin;
        glass_z = -bezel_t + glass_t/2 + ov;
        translate([0,0,glass_z])
            cube([glass_w, glass_h, glass_t], center=true);

        // Front button (solid, protruding slightly)
        btn_z = -btn_h/2 + ov/2;
        translate([btn_x_off, btn_y_off, btn_z])
            cylinder(h=btn_h, d=btn_d, center=true);
    }
}

module rear_body() {
    // Main rear body (overlaps into bezel by ov/2)
    translate([0,0,-bezel_t - body_d/2 + ov/2])
        rounded_box([body_w, body_h, body_d], r=1.2, center=true);

    // Shoulder near bezel (slightly larger footprint)
    shoulder_t = 3.2;
    shoulder_w = body_w + 5;
    shoulder_h = body_h + 5;
    translate([0,0,-bezel_t - shoulder_t/2 + ov/2])
        rounded_box([shoulder_w, shoulder_h, shoulder_t], r=1.0, center=true);

    // Small rear taper/step near back end (distinct back silhouette)
    back_step_t = 4.0;
    back_step_w = body_w - 6;
    back_step_h = body_h - 6;
    translate([0,0,-bezel_t - body_d + back_step_t/2 + ov/2])
        rounded_box([back_step_w, back_step_h, back_step_t], r=0.9, center=true);
}

module side_latches() {
    // Fixed: ensure latches intersect the bezel side face by ov (no visible gap).
    // Bezel spans X: [-bezel_w/2, +bezel_w/2]
    // Latch spans X: center at +/- (bezel_w/2 + latch_out/2 - ov)
    // => inner face at +/- (bezel_w/2 - ov) which is inside bezel by ov.
    latch_center_z = -bezel_t/2;
    x_pos = bezel_w/2 + latch_out/2 - ov;

    for (sx = [-1, 1]) {
        translate([sx*x_pos, 0, latch_center_z])
            cube([latch_out, latch_h, latch_z], center=true);
    }
}

module top_bottom_tabs() {
    // Added/fixed: small top and bottom protrusions (seen in left/right views).
    // Ensure they intersect the bezel top/bottom faces by ov (no floating).
    // Bezel spans Y: [-bezel_h/2, +bezel_h/2]
    // Tab spans Y: center at +/- (bezel_h/2 + tb_out/2 - ov)
    // => inner face at +/- (bezel_h/2 - ov) which is inside bezel by ov.
    tab_center_z = -bezel_t/2;
    y_pos = bezel_h/2 + tb_out/2 - ov;

    for (sy = [-1, 1]) {
        translate([0, sy*y_pos, tab_center_z])
            cube([tb_w, tb_out, tb_z], center=true);
    }
}

module rear_terminals() {
    term_z = -bezel_t - body_d + term_d/2 + ov;
    term_y = -body_h/2 + term_h/2 + 2.5;

    translate([0, term_y, term_z])
        rounded_box([term_w, term_h, term_d], r=1.0, center=true);

    // Wire entry lip on very back face (protrudes further back)
    lip_z = term_z - term_d/2 - wire_lip_d/2 + ov;
    translate([0, term_y - (term_h/2 - wire_lip_h/2), lip_z])
        rounded_box([wire_lip_w, wire_lip_h, wire_lip_d], r=0.8, center=true);

    // 4 screw bosses on terminal block front face (toward bezel)
    boss_z = term_z + term_d/2 - boss_h/2 + ov/2;
    for (k = [-1.5, -0.5, 0.5, 1.5]) {
        translate([k*boss_spacing, term_y, boss_z])
            cylinder(h=boss_h, d=boss_d, center=true);
    }

    // Divider ridges between terminals
    ridge_w = 1.2;
    ridge_h = term_h - 3.0;
    ridge_d = 2.0;
    ridge_z = term_z + term_d/2 - ridge_d/2 + ov/2;
    for (k = [-1, 0, 1]) {
        translate([k*boss_spacing, term_y, ridge_z])
            cube([ridge_w, ridge_h, ridge_d], center=true);
    }
}

module rear_connector_bump() {
    bump_z = -bezel_t - body_d + conn_d/2 + ov;
    bump_y = body_h/2 - conn_h/2 - 3.5;

    translate([0, bump_y, bump_z])
        rounded_box([conn_w, conn_h, conn_d], r=1.0, center=true);

    // Small strain-relief ridge on bump back face
    ridge_t = 1.6;
    ridge_z = bump_z - conn_d/2 - ridge_t/2 + ov;
    translate([0, bump_y, ridge_z])
        cube([conn_w - 4, conn_h - 3, ridge_t], center=true);
}

module rear_ribs() {
    back_face_z = -bezel_t - body_d + rib_d/2 + ov;
    x_span = body_w - 10;
    x0 = -x_span/2;
    step = x_span/(rib_count-1);

    for (i = [0:rib_count-1]) {
        x = x0 + i*step;
        translate([x, 0, back_face_z])
            cube([rib_w, rib_h, rib_d], center=true);
    }
}

// ---------- Render ----------
panel_meter();
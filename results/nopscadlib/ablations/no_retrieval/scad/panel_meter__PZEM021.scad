// Peacefair PZEM-021 AC panel meter (approximate geometry)
// One connected solid, no text/labels, all placements derived from dimensions.

$fn = 64;

// -------------------- Parameters --------------------
bezel_W = 85;                 // front flange width
bezel_H = 45;                 // front flange height
bezel_T = 3;                  // front flange thickness

body_W  = 76;                 // rear housing width (fits panel cutout)
body_H  = 36;                 // rear housing height
body_D  = 70;                 // rear housing depth

panel_T = 2;                  // thin "panel interface" slab behind bezel

// Display window / bezel recess
window_W = 60;
window_H = 26;
window_recess_D = 1.6;

// Inner "LCD plate" detail (raised, not text)
lcd_plate_T = 0.9;
lcd_margin  = 2.2;

// Clear window "lens" (raised rim + shallow lens)
lens_T = 0.9;
lens_gap = 0.6;               // inset from recess edge
lens_bulge = 0.25;            // slight convex look

// Two front buttons (typical PZEM style) - no labels
btn_d = 6.2;
btn_h = 1.4;
btn_spacing = 10.5;
btn_y_offset = -(window_H/2 + 6.5); // below window

// Mounting clips (side spring clips)
clip_T = 2;
clip_H = 10;
clip_D = 12;
clip_overhang = 2.5;
clip_z_offset = 10;           // distance from bezel back face into body

// Terminal block envelope (rear connector area)
terminal_block_W = 50;
terminal_block_H = 20;
terminal_block_D = 18;

// Terminal screw bosses (visual detail)
term_boss_r = 2.3;
term_boss_h = 3.2;
term_boss_cols = 4;

// Terminal entry "wire holes" (shallow recesses on rear face)
wire_hole_r = 2.0;
wire_hole_d = 2.2;

// Rear vent slots (cut into back face)
vent_slot_W = 22;
vent_slot_H = 2.6;
vent_slot_D = 2.2;
vent_slot_count = 4;
vent_slot_pitch = 5.2;

// Back-side step / shoulder (common on these meters)
back_step_inset = 2.0;        // inset from body sides
back_step_D = 10;             // depth of stepped region from rear face

// Small overlaps to guarantee manifold unions/differences
overlap = 0.8;

// Edge rounding (subtle)
bezel_r = 1.2;
body_r  = 1.0;

// -------------------- Helpers --------------------
module rbox(size=[10,10,10], r=1, center=true) {
    // Rounded box via hull of corner cylinders
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, min(sx, sy)/2 - 0.01);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull() {
        for (x = [-1,1], y = [-1,1])
            translate([x*(sx/2-rr), y*(sy/2-rr), 0])
                cylinder(r=rr, h=sz, center=true);
    }
}

module front_bezel() {
    rbox([bezel_W, bezel_H, bezel_T], r=bezel_r, center=true);
}

module display_window_recess() {
    // Recess into front bezel (from front face inward)
    translate([0, 0, bezel_T/2 - window_recess_D/2 + overlap/2])
        rbox([window_W, window_H, window_recess_D + overlap], r=0.9, center=true);
}

module lcd_plate_detail() {
    // Slight raised plate inside recess (still part of solid)
    translate([0, 0, bezel_T/2 - window_recess_D + lcd_plate_T/2 + overlap/2])
        rbox([window_W - 2*lcd_margin, window_H - 2*lcd_margin, lcd_plate_T], r=0.7, center=true);
}

module lens_detail() {
    // A shallow "lens" inside the recess (still solid, no transparency)
    lens_W = window_W - 2*(lcd_margin + lens_gap);
    lens_H = window_H - 2*(lcd_margin + lens_gap);

    // Base lens slab
    translate([0, 0, bezel_T/2 - window_recess_D + lens_T/2 + overlap/2])
        rbox([lens_W, lens_H, lens_T], r=0.6, center=true);

    // Slight bulge (convex hint) using hull of two thin slabs
    hull() {
        translate([0, 0, bezel_T/2 - window_recess_D + lens_T - 0.15 + overlap/2])
            rbox([lens_W*0.92, lens_H*0.92, 0.2], r=0.6, center=true);
        translate([0, 0, bezel_T/2 - window_recess_D + lens_T + lens_bulge + overlap/2])
            rbox([lens_W*0.82, lens_H*0.82, 0.2], r=0.6, center=true);
    }
}

module front_buttons() {
    // Two small round buttons below the window
    btn_z = bezel_T/2 + btn_h/2 - overlap/2; // protrude from front face, overlap slightly
    for (i=[-1,1]) {
        translate([i*btn_spacing/2, btn_y_offset, btn_z])
            cylinder(d=btn_d, h=btn_h + overlap, center=true);
    }
}

module panel_cutout_interface() {
    // Thin slab behind bezel to suggest panel thickness; overlaps into body
    translate([0, 0, -bezel_T/2 - panel_T/2 + overlap])
        rbox([body_W, body_H, panel_T + overlap], r=0.7, center=true);
}

module rear_housing() {
    // Main rear body, attached to bezel back face
    translate([0, 0, -bezel_T/2 - body_D/2 + overlap])
        rbox([body_W, body_H, body_D], r=body_r, center=true);
}

module back_step_detail() {
    // A stepped region near the rear face to break up the "plain block" look
    // This is an added solid that overlaps into the housing.
    step_W = body_W - 2*back_step_inset;
    step_H = body_H - 2*back_step_inset;

    // Rear face of housing at z = -bezel_T/2 - body_D
    rear_face_z = -bezel_T/2 - body_D;

    // Center of step block placed just inside rear face
    step_center_z = rear_face_z + back_step_D/2 + overlap/2;

    translate([0, 0, step_center_z])
        rbox([step_W, step_H, back_step_D + overlap], r=0.8, center=true);
}

module terminal_block() {
    // Rear terminal block attached to lower back area of housing
    translate([0,
               -body_H/2 + terminal_block_H/2 + overlap,
               (-bezel_T/2 - body_D) + terminal_block_D/2 + overlap])
        rbox([terminal_block_W, terminal_block_H, terminal_block_D], r=0.9, center=true);
}

module screw_boss_array() {
    // Bosses on terminal block rear face, protruding outward (more negative Z)
    x_span = terminal_block_W * 0.74;
    x0 = -x_span/2;
    dx = (term_boss_cols > 1) ? (x_span/(term_boss_cols-1)) : 0;

    tb_y = -body_H/2 + terminal_block_H/2 + overlap;
    tb_z = (-bezel_T/2 - body_D) + terminal_block_D/2 + overlap;

    tb_rear_face_z = tb_z - terminal_block_D/2;

    for (i=[0:term_boss_cols-1]) {
        translate([x0 + i*dx, tb_y, tb_rear_face_z - term_boss_h/2 + overlap/2])
            cylinder(r=term_boss_r, h=term_boss_h, center=true);
    }
}

module wire_entry_recesses_cut() {
    // Shallow circular recesses on the terminal block rear face (wire entry look)
    x_span = terminal_block_W * 0.74;
    x0 = -x_span/2;
    dx = (term_boss_cols > 1) ? (x_span/(term_boss_cols-1)) : 0;

    tb_y = -body_H/2 + terminal_block_H/2 + overlap;
    tb_z = (-bezel_T/2 - body_D) + terminal_block_D/2 + overlap;

    tb_rear_face_z = tb_z - terminal_block_D/2;

    // Cut into the rear face by wire_hole_d
    cut_center_z = tb_rear_face_z + wire_hole_d/2 + overlap/2;

    for (i=[0:term_boss_cols-1]) {
        translate([x0 + i*dx, tb_y, cut_center_z])
            cylinder(r=wire_hole_r, h=wire_hole_d + overlap, center=true);
    }
}

module mounting_clip(side=1) {
    // side = -1 (left), +1 (right)
    clip_center_x = side*(body_W/2 + clip_T/2 - overlap);
    clip_center_z = -bezel_T/2 - clip_z_offset;

    // Main clip bar
    translate([clip_center_x, 0, clip_center_z])
        cube([clip_T, clip_H, clip_D], center=true);

    // Hook lip that overhangs outward (grabs panel)
    hook_center_x = side*(body_W/2 + clip_T + clip_overhang/2 - overlap);
    hook_center_z = clip_center_z + (clip_D/2 - clip_T/2);
    translate([hook_center_x, 0, hook_center_z])
        cube([clip_overhang, clip_H, clip_T], center=true);

    // Gusset to ensure robust connection
    hull() {
        translate([clip_center_x - side*(clip_T/2 - overlap/2), 0, hook_center_z])
            cube([overlap, clip_H*0.8, clip_T], center=true);
        translate([hook_center_x + side*(clip_overhang/2 - overlap/2), 0, hook_center_z])
            cube([overlap, clip_H*0.8, clip_T], center=true);
    }
}

module rear_vent_slots_cut() {
    // Cut slots into the rear face of the housing (not through entire body)
    rear_face_z = -bezel_T/2 - body_D;

    for (i = [0:vent_slot_count-1]) {
        y = (i - (vent_slot_count-1)/2) * vent_slot_pitch;
        translate([0, y, rear_face_z + vent_slot_D/2 + overlap/2])
            cube([vent_slot_W, vent_slot_H, vent_slot_D + overlap], center=true);
    }
}

module side_ribs() {
    // Subtle ribs on the sides of the rear housing
    rib_T = 1.2;
    rib_H = body_H * 0.78;
    rib_D = body_D * 0.62;

    rib_center_z = -bezel_T/2 - body_D/2;
    for (side=[-1,1]) {
        translate([side*(body_W/2 - rib_T/2 + overlap/2), 0, rib_center_z])
            cube([rib_T, rib_H, rib_D], center=true);
    }
}

module front_bezel_frame_detail() {
    // A raised frame around the window (recognizable bezel feature)
    frame_T = 0.9;
    frame_gap = 1.6; // distance from window edge to frame outer edge

    outer_W = window_W + 2*frame_gap;
    outer_H = window_H + 2*frame_gap;

    // Place on front face, overlapping slightly
    zc = bezel_T/2 + frame_T/2 - overlap/2;

    translate([0,0,zc])
    difference() {
        rbox([outer_W, outer_H, frame_T + overlap], r=1.0, center=true);
        // inner opening aligned to window size
        rbox([window_W - 0.6, window_H - 0.6, frame_T + 2*overlap], r=0.9, center=true);
    }
}

// -------------------- Assembly --------------------
module meter_solid() {
    union() {
        // Bezel with recess removed
        difference() {
            front_bezel();
            display_window_recess();
        }

        // Front details (all connected to bezel)
        front_bezel_frame_detail();
        lcd_plate_detail();
        lens_detail();
        front_buttons();

        // Connected body stack
        panel_cutout_interface();
        rear_housing();

        // Back-side distinct geometry
        back_step_detail();

        // Rear terminal block + screw bosses
        terminal_block();
        screw_boss_array();

        // Side ribs
        side_ribs();

        // Mounting clips (both sides)
        mounting_clip(-1);
        mounting_clip( 1);
    }
}

// Final: subtract vents + wire entry recesses from the connected solid
difference() {
    meter_solid();
    rear_vent_slots_cut();
    wire_entry_recesses_cut();
}
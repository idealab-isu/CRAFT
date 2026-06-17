// DSN-DC 100V 10A panel meter (approximate model)
// Units: mm
// One connected solid, no text.
// Simplified for fast rendering: no hull-based rounding, minimal booleans.

$fn = 28;

// ---------- Parameters ----------
body_w = 48.0;
body_h = 29.0;
body_d = 22.0;

bezel_w = 50.0;
bezel_h = 31.0;
bezel_t = 2.2;

face_recess = 0.6;

screen_w = 36.0;
screen_h = 18.0;
screen_border = 1.2;

back_lip_w = 44.0;
back_lip_h = 25.0;
back_lip_t = 1.2;

// Rear terminal block (DSN-DC style)
terminal_block_w = 44.0;
terminal_block_h = 10.0;
terminal_block_d = 7.0;

term_count = 6;
terminal_pitch = 7.2;
terminal_d = 3.0;
terminal_len = 5.5;

screw_head_d = 4.2;
screw_head_h = 1.6;

// Mounting clips (side spring clips)
clip_w = 6.0;
clip_h = 12.0;
clip_t = 2.2;
clip_bump = 1.2;

// Display segmentation (no text): two windows (V/A) with divider
seg_gap = 0.8;
seg_div_t = 1.0;

// Small rear PCB bump (common on these)
pcb_w = 34;
pcb_h = 16;
pcb_d = 6;

// Overlap to ensure connectivity
ov = 0.6;

// ---------- Helpers (fast) ----------
module box(w,h,d){
    translate([-w/2,-h/2,0]) cube([w,h,d], center=false);
}

// ---------- Model ----------
module panel_meter(){
    union(){
        // Main body (z: 0..body_d)
        color([0.12,0.12,0.12])
        box(body_w, body_h, body_d);

        // Front bezel (connected with slight overlap into body)
        color([0.05,0.05,0.05])
        translate([0,0,body_d-ov])
        difference(){
            box(bezel_w, bezel_h, bezel_t+ov);

            // Face recess (shallow pocket)
            translate([0,0,(bezel_t+ov)-face_recess])
                box(bezel_w-2.0, bezel_h-2.0, face_recess+0.05);

            // Screen opening
            translate([0,0,-0.05])
                box(screen_w, screen_h, bezel_t+ov+0.10);
        }

        // Screen border frame (inside)
        color([0.02,0.02,0.02])
        translate([0,0,body_d + bezel_t - face_recess - 0.15])
        difference(){
            box(screen_w + 2*screen_border, screen_h + 2*screen_border, 0.95);
            translate([0,0,-0.05])
                box(screen_w, screen_h, 1.05);
        }

        // Display segmentation: two "glass" panes with a center divider (no text)
        seg_w = (screen_w - seg_gap)/2;
        seg_h = screen_h - 0.6;

        // Left pane
        color([0.05,0.12,0.18,0.65])
        translate([-(seg_gap/2 + seg_w/2), 0, body_d + bezel_t - face_recess + 0.05])
            box(seg_w, seg_h, 0.85);

        // Right pane
        color([0.05,0.12,0.18,0.65])
        translate([ (seg_gap/2 + seg_w/2), 0, body_d + bezel_t - face_recess + 0.05])
            box(seg_w, seg_h, 0.85);

        // Divider bar (connected)
        color([0.02,0.02,0.02])
        translate([0,0,body_d + bezel_t - face_recess + 0.02])
            box(seg_div_t, seg_h + 1.0, 0.95);

        // Back lip (panel cutout retention), connected with overlap into body
        color([0.10,0.10,0.10])
        translate([0,0,-back_lip_t])
            box(back_lip_w, back_lip_h, back_lip_t+ov);

        // Side mounting clips (simplified), connected to body sides
        clip_z = body_d*0.55;
        for (sx=[-1,1]){
            color([0.10,0.10,0.10])
            translate([sx*(body_w/2 + clip_t/2 - ov), 0, clip_z])
            rotate([0,90,0])
            union(){
                // main clip plate
                box(clip_w, clip_h, clip_t);
                // outward bump
                translate([0, 0, clip_t-ov])
                    box(clip_w*0.55, clip_h*0.55, clip_bump);
            }
        }

        // Rear terminal block (connected to back face with overlap)
        term_y = -(body_h/2 - terminal_block_h/2 - 1.0);
        term_z0 = -terminal_block_d; // z: -terminal_block_d .. 0
        color([0.16,0.16,0.16])
        translate([0, term_y, term_z0])
            box(terminal_block_w, terminal_block_h, terminal_block_d+ov);

        // Terminal barrels + screw head bumps
        term_span = (term_count-1)*terminal_pitch;
        for (k=[0:term_count-1]){
            x = -term_span/2 + k*terminal_pitch;

            // barrel: starts slightly inside block to guarantee union
            color([0.75,0.62,0.25])
            translate([x, term_y, term_z0 - terminal_len + ov])
                cylinder(d=terminal_d, h=terminal_len + (terminal_block_d*0.15), center=false);

            // screw head bumps on top of block
            color([0.20,0.20,0.20])
            translate([x, term_y, 0 - screw_head_h + ov])
                cylinder(d=screw_head_d, h=screw_head_h, center=false);
        }

        // Rear PCB bump (connected to body back)
        color([0.08,0.08,0.08])
        pcb_z = -pcb_d + ov; // overlaps body at z=0
        translate([0, body_h*0.18, pcb_z])
            box(pcb_w, pcb_h, pcb_d);

        // Small side nub (simplified), connected
        nub_d = 4.0;
        nub_w = 6.0;
        nub_h = 8.0;
        translate([body_w/2 - ov, 0, body_d*0.70])
            rotate([0,90,0])
                box(nub_w, nub_h, nub_d);
    }
}

// ---------- Render ----------
panel_meter();
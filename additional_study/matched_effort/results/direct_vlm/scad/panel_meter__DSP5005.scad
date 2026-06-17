$fn=96;

// Ruideng-style panel meter / power supply module (front bezel + display window + buttons + encoder + rear terminals)
// Units: mm
// One connected solid; all translate() values derived from dimensions (no arbitrary placement).

// ---------- Parameters ----------
body_w = 71.0;
body_h = 39.0;
body_d = 24.0;

bezel_w = 79.0;
bezel_h = 43.0;
bezel_t = 2.2;

corner_r = 2.2;

// Bezel step (typical front frame geometry)
bezel_step_inset = 2.0;   // inset from bezel outer edge
bezel_step_depth = 0.9;   // depth of recessed frame on front

// Front features
screen_w = 46.0;
screen_h = 24.0;

screen_margin_top = 7.0;    // from bezel top to screen top
screen_margin_left = 6.5;   // from bezel left to screen left

btn_d = 5.2;
btn_h = 1.2;
btn_spacing = 8.0;
btn_row_y_from_bottom = 8.0; // from bezel bottom to button centerline
btn_row_x_from_right = 10.0; // from bezel right to rightmost button center

enc_d = 12.0;
enc_h = 3.0;
enc_x_from_right = 14.0;
enc_y_from_bottom = 20.0;

// Rear features
terminal_block_w = 22.0;
terminal_block_h = 14.0;
terminal_block_d = 11.0;

terminal_hole_d = 3.2;
terminal_hole_spacing = 10.0;

mount_hole_d = 3.0;
mount_hole_inset_x = 6.0;
mount_hole_inset_y = 6.0;

lip_t = 1.2; // small rear lip around body

rear_boss_w = 34.0;
rear_boss_h = 18.0;
rear_boss_d = 6.0;

// Internal cavity
wall = 2.0;

// Connectivity overlap (small, to ensure watertight unions)
ov = 0.6;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

// ---------- Model ----------
module panel_meter(){
    // Coordinate system:
    // Front face of bezel at z=0, body extends to +z.
    // Centered at origin in X/Y.

    // Derived placements (formulas only)
    screen_x = -bezel_w/2 + screen_margin_left + screen_w/2;
    screen_y =  bezel_h/2 - screen_margin_top - screen_h/2;

    btn_y = -bezel_h/2 + btn_row_y_from_bottom;
    enc_x =  bezel_w/2 - enc_x_from_right;
    enc_y = -bezel_h/2 + enc_y_from_bottom;

    // Rear terminal block: attached to rear face of body
    tb_y = (body_h/2 - terminal_block_h/2 - 2);
    tb_z0 = bezel_t + body_d - terminal_block_d; // front of terminal block starts here

    // Rear boss: attached to rear face of body
    boss_z0 = bezel_t + body_d - rear_boss_d;

    // Bezel step geometry (front recess frame)
    step_w = bezel_w - 2*bezel_step_inset;
    step_h = bezel_h - 2*bezel_step_inset;

    difference(){
        union(){
            // Outer bezel (front flange)
            rounded_box(bezel_w, bezel_h, bezel_t, corner_r);

            // Main body behind bezel (overlap into bezel)
            translate([0,0,bezel_t-ov])
                rounded_box(body_w, body_h, body_d+ov, corner_r);

            // Rear lip (slight step) - attached at rear
            lip_d = 3;
            translate([0,0,bezel_t + body_d - lip_d])
                rounded_box(body_w + 2*lip_t, body_h + 2*lip_t, lip_d, corner_r);

            // Rear terminal block (attached with overlap)
            translate([0, tb_y, tb_z0-ov])
                rounded_box(terminal_block_w, terminal_block_h, terminal_block_d+ov, 1.2);

            // Rear connector boss (attached with overlap)
            translate([0, 0, boss_z0-ov])
                rounded_box(rear_boss_w, rear_boss_h, rear_boss_d+ov, 2.0);

            // Front buttons (protruding, connected by starting slightly inside bezel)
            for(i=[0:2]){
                x = (bezel_w/2 - btn_row_x_from_right) - i*btn_spacing;
                translate([x, btn_y, bezel_t - 0.2])
                    cylinder(d=btn_d, h=btn_h+0.2, center=false);
            }

            // Front encoder/knob (protruding, connected)
            translate([enc_x, enc_y, bezel_t - 0.2])
                cylinder(d=enc_d, h=enc_h+0.2, center=false);
        }

        // --- Front bezel step recess (typical frame) ---
        // Cut a shallow recessed area on the bezel front, leaving an outer rim.
        translate([0,0,0])
            rounded_box(step_w, step_h, bezel_step_depth, max(0.8, corner_r-0.6));

        // --- Screen window cutout (through bezel only) ---
        translate([screen_x, screen_y, -0.1])
            rounded_box(screen_w, screen_h, bezel_t + 0.3, 1.2);

        // --- Screen recess pocket (shallow, around window) ---
        // Keep it within bezel thickness (do not break through).
        pocket_z = max(0.2, bezel_step_depth); // start at/after step recess
        pocket_d = max(0.6, bezel_t - pocket_z - 0.2);
        translate([screen_x, screen_y, pocket_z])
            rounded_box(screen_w+2.0, screen_h+2.0, pocket_d, 1.6);

        // --- Mounting holes through bezel/body (4 corners) ---
        for(sx=[-1,1], sy=[-1,1]){
            hx = sx*(bezel_w/2 - mount_hole_inset_x);
            hy = sy*(bezel_h/2 - mount_hole_inset_y);
            translate([hx,hy,-0.1])
                cylinder(d=mount_hole_d, h=bezel_t + body_d + 0.6, center=false);
        }

        // --- Terminal block wire holes (rear): two holes through terminal block ---
        for(ix=[-0.5,0.5]){
            translate([ix*terminal_hole_spacing, tb_y, tb_z0 + terminal_block_d/2])
                rotate([90,0,0])
                    cylinder(d=terminal_hole_d, h=terminal_block_h + 2, center=true);
        }

        // --- Rear boss cable slot (connector opening suggestion) ---
        slot_w = rear_boss_w - 10;
        slot_h = 6;
        translate([0, 0, boss_z0 + rear_boss_d/2])
            rotate([90,0,0])
                rounded_box(slot_w, slot_h, rear_boss_h + 2, 2.0);

        // --- Back cavity (hollow) ---
        // Keep walls; do not break through front bezel.
        cavity_z0 = bezel_t + wall;
        cavity_d  = max(0.1, body_d - wall - 1.0);
        translate([0,0,cavity_z0])
            rounded_box(body_w-2*wall, body_h-2*wall, cavity_d, max(0.8,corner_r-0.8));
    }
}

panel_meter();
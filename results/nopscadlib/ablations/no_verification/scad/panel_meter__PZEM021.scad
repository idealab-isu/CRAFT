// Peacefair PZEM-021 style panel meter (approximate) - ONE connected solid
// Fixes: adds recognizable front bezel/frame, display window recess, front button,
// and rear terminal block + small signal connector. All placements are formula-based.

$fn = 48;

// ---------- Parameters ----------
bezel_width = 85;            //[42.5:170:1]
bezel_height = 45;           //[22.5:90:1]
bezel_thickness = 3;         //[1.5:6:0.5]

body_width = 80;             //[40:160:1]
body_height = 40;            //[20:80:1]
body_depth = 55;             //[27.5:110:1]

corner_radius = 2;           //[0:6:0.5]

display_window_width = 60;   //[30:120:1]
display_window_height = 22;  //[11:44:1]
display_window_offset_x = 0; //[-10:10:0.5]
display_window_offset_y = 3; //[-10:10:0.5]
aperture_depth = 6;          //[3:12:0.5]

button_diameter = 6;         //[3:12:0.5]
button_height = 2;           //[1:6:0.5]
button_offset_x = 0;         //[-20:20:0.5]
button_offset_y = -16.5;     //[-30:30:0.5]

tab_width = 10;              //[5:20:1]
tab_height = 18;             //[9:36:1]
tab_thickness = 2.5;         //[1:5:0.5]
tab_offset_z = 12;           //[0:30:1]

tolerance = 0.2;             //[0:1:0.05]
overlap = 1;                 //[0.5:2:0.1]

// Rear terminal block (typical screw terminal area)
term_block_w = 46;           //[20:70:1]
term_block_h = 16;           //[8:30:1]
term_block_d = 14;           //[6:25:1]
term_block_offset_y = -8;    //[-15:15:0.5]

// Terminal screws (visual)
screw_d = 4.2;               //[2:6:0.2]
screw_head_d = 6.2;          //[3:9:0.2]
screw_head_h = 2.2;          //[1:4:0.1]
num_screws = 4;              //[2:6:1]
screw_pitch = 12;            //[8:16:0.5]

// Small rear signal connector (2-pin style)
sig_conn_w = 14;             //[8:25:1]
sig_conn_h = 10;             //[6:18:1]
sig_conn_d = 10;             //[5:18:1]
sig_conn_offset_y = 10;      //[-15:15:0.5]

// ---------- Helpers ----------
module rrect(size=[10,10,10], r=1, center=true, fn=32) {
    // Rounded rectangle prism via hull of cylinders
    w=size[0]; h=size[1]; d=size[2];
    rr = min(r, min(w,h)/2);
    translate(center ? [0,0,0] : [w/2,h/2,d/2])
    hull() {
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2-rr), sy*(h/2-rr), -d/2])
                cylinder(r=rr, h=d, $fn=fn);
    }
}

module screw_visual(d=screw_d, head_d=screw_head_d, head_h=screw_head_h, depth=term_block_d) {
    // A simple screw head + shallow shank (solid), intended to sit on terminal block face
    union() {
        cylinder(d=head_d, h=head_h, $fn=36);
        translate([0,0,head_h - overlap])
            cylinder(d=d, h=max(0.1, depth - head_h + overlap), $fn=24);
    }
}

// ---------- Main Model ----------
module pzem021_panel_meter() {

    // Coordinate convention:
    // Front face of bezel at z=0, body extends to +z.
    // Centered in X/Y.

    // Derived Z positions
    z_front_face   = 0;
    z_bezel_center = -bezel_thickness/2;
    z_back_face    = bezel_thickness + body_depth;

    // Ensure body overlaps into bezel so it's one connected solid
    z_body_center  = bezel_thickness + body_depth/2 - overlap;

    // Bezel frame details (recognizable PZEM-021 look)
    frame_inset = 2.2;                         // outer-to-inner step
    frame_thickness = max(0.9, bezel_thickness*0.55);
    frame_r = max(0, corner_radius - 0.6);

    // Display recess
    recess_depth = min(aperture_depth, bezel_thickness + 1);
    pocket_margin = 1.2;
    pocket_depth = min(2.0, max(0.6, bezel_thickness - 0.4));

    // Terminal block placement (attached to rear face)
    z_term_center = z_back_face + term_block_d/2 - overlap;

    // Signal connector placement (attached to rear face)
    z_sig_center = z_back_face + sig_conn_d/2 - overlap;

    // Mounting tabs: attach to body sides
    z_tab_center = bezel_thickness + tab_offset_z;
    x_tab_center_left  = -(body_width/2 + tab_thickness/2 - overlap);
    x_tab_center_right =  (body_width/2 + tab_thickness/2 - overlap);

    // Button placement on bezel front (slightly embedded)
    z_button_center = z_front_face - button_height/2 + overlap;

    // Signal connector X position (near left rear, typical)
    x_sig = -(body_width/2 - sig_conn_w/2 - 6);

    union() {

        // --- Main connected solid with cutouts ---
        difference() {
            union() {
                // Main bezel slab (rounded)
                translate([0,0,z_bezel_center])
                    rrect([bezel_width, bezel_height, bezel_thickness], r=corner_radius, center=true, fn=48);

                // Bezel frame step on front (adds recognizable bezel)
                translate([0,0, -(frame_thickness/2) + overlap])
                    rrect([bezel_width - 2*frame_inset,
                           bezel_height - 2*frame_inset,
                           frame_thickness],
                          r=frame_r, center=true, fn=48);

                // Rear body (slightly smaller than bezel)
                translate([0,0,z_body_center])
                    rrect([body_width, body_height, body_depth], r=max(0, corner_radius-0.5), center=true, fn=48);

                // Mounting tabs (left/right), connected to body
                translate([x_tab_center_left, 0, z_tab_center])
                    cube([tab_thickness, tab_height, tab_width], center=true);
                translate([x_tab_center_right, 0, z_tab_center])
                    cube([tab_thickness, tab_height, tab_width], center=true);

                // Rear terminal block (connected)
                translate([0, term_block_offset_y, z_term_center])
                    rrect([term_block_w, term_block_h, term_block_d], r=1.2, center=true, fn=36);

                // Rear signal connector block (connected)
                translate([x_sig, sig_conn_offset_y, z_sig_center])
                    rrect([sig_conn_w, sig_conn_h, sig_conn_d], r=1.0, center=true, fn=36);

                // Front button (connected)
                translate([button_offset_x, button_offset_y, z_button_center])
                    cylinder(d=button_diameter, h=button_height, center=true, $fn=48);

                // Small front "badge" bump (no text)
                badge_w = 18;
                badge_h = 6;
                badge_t = 0.8;
                translate([bezel_width/2 - badge_w/2 - 6,
                           -bezel_height/2 + badge_h/2 + 5,
                           -(badge_t/2) + overlap])
                    rrect([badge_w, badge_h, badge_t], r=1.2, center=true, fn=36);

                // Rear strain relief ridge (connected)
                ridge_w = body_width - 10;
                ridge_h = 3;
                ridge_d = 2.2;
                translate([0, term_block_offset_y, z_back_face - ridge_d/2 + overlap])
                    rrect([ridge_w, ridge_h, ridge_d], r=1.0, center=true, fn=36);

                // Slight rear "boss" around terminal area (adds enclosure realism)
                boss_w = term_block_w + 10;
                boss_h = term_block_h + 8;
                boss_d = 3.0;
                translate([0, term_block_offset_y, z_back_face - boss_d/2 + overlap])
                    rrect([boss_w, boss_h, boss_d], r=1.2, center=true, fn=36);
            }

            // --- Display window cutout (through bezel thickness) ---
            translate([display_window_offset_x, display_window_offset_y, -recess_depth/2 - 0.01])
                cube([display_window_width, display_window_height, recess_depth + 0.02], center=true);

            // --- Display pocket (shallow recess around window) ---
            translate([display_window_offset_x, display_window_offset_y, -(pocket_depth/2) + overlap*0.2])
                cube([display_window_width + 2*pocket_margin,
                      display_window_height + 2*pocket_margin,
                      pocket_depth], center=true);

            // --- Button top dimple (small recess) ---
            dimple_d = max(1.2, button_diameter*0.35);
            dimple_h = min(0.8, button_height*0.6);
            translate([button_offset_x, button_offset_y, z_front_face - dimple_h/2 - 0.01])
                cylinder(d=dimple_d, h=dimple_h + 0.02, center=true, $fn=36);

            // --- Rear terminal screw recesses (shallow) ---
            screw_recess_depth = min(2.2, term_block_d - 1);
            x0 = -((num_screws-1) * screw_pitch)/2;
            for (i=[0:num_screws-1]) {
                translate([x0 + i*screw_pitch, term_block_offset_y, z_back_face + screw_recess_depth/2 - overlap])
                    cylinder(d=screw_head_d + 0.6, h=screw_recess_depth, center=true, $fn=36);
            }

            // --- Rear signal connector pin recesses (2) ---
            pin_d = 2.2;
            pin_pitch = 5.0;
            pin_recess = min(2.0, sig_conn_d - 1);
            for (px=[-pin_pitch/2, pin_pitch/2]) {
                translate([x_sig + px, sig_conn_offset_y, z_back_face + pin_recess/2 - overlap])
                    cylinder(d=pin_d + 0.4, h=pin_recess, center=true, $fn=24);
            }

            // --- Rear terminal wire entry slots (visual) ---
            // Cut shallow rectangular slots on terminal block rear face.
            slot_w = (term_block_w - 10) / 2;
            slot_h = 4.0;
            slot_d = min(2.0, term_block_d - 1.2);
            slot_y = term_block_offset_y - term_block_h/2 + slot_h/2 + 2.2;
            for (sx=[-1,1]) {
                translate([sx*(slot_w/2 + 3.0), slot_y, z_back_face + slot_d/2 - overlap])
                    cube([slot_w, slot_h, slot_d], center=true);
            }
        }

        // --- Add screw visuals as solids on terminal block (connected) ---
        x0 = -((num_screws-1) * screw_pitch)/2;
        for (i=[0:num_screws-1]) {
            translate([x0 + i*screw_pitch, term_block_offset_y, z_back_face - overlap])
                screw_visual(depth=term_block_d);
        }

        // --- Add small cable clamp bar on terminal block (connected) ---
        clamp_w = term_block_w - 6;
        clamp_h = 3.2;
        clamp_d = 2.2;
        translate([0,
                   term_block_offset_y + term_block_h/2 - clamp_h/2 - 1.2,
                   z_back_face + clamp_d/2 - overlap])
            rrect([clamp_w, clamp_h, clamp_d], r=0.8, center=true, fn=36);

        // --- Add small rear feet/ribs (connected) to avoid "plain block" look ---
        rib_w = body_width - 14;
        rib_h = 2.4;
        rib_d = 2.0;
        rib_y_off = body_height/2 - rib_h/2 - 3.0;
        translate([0,  rib_y_off, z_back_face - rib_d/2 + overlap])
            rrect([rib_w, rib_h, rib_d], r=0.8, center=true, fn=24);
        translate([0, -rib_y_off, z_back_face - rib_d/2 + overlap])
            rrect([rib_w, rib_h, rib_d], r=0.8, center=true, fn=24);
    }
}

pzem021_panel_meter();
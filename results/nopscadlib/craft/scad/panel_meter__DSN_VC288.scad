// DSN-DC 100V 10A Panel Meter (voltmeter/ammeter) - single connected solid
// Connectivity-fixed: all protrusions overlap the main body by overlap_mm (1-2mm) to avoid floating parts.

$fn = 48;

// Parameters
cutout_offset_clearance_mm = 0.2; //[0.0:1.0:0.05]
overlap_mm = 1.2; //[0.5:2.0:0.1]

bezel_width = 48; //[24:96:1]
bezel_height = 29; //[15:58:1]
bezel_thickness = 3; //[1.5:6:0.5]

body_width = 45; //[22.5:90:1]
body_height = 26; //[13:52:1]
body_depth = 22; //[11:44:1]

display_aperture_width = 36; //[18:72:1]
display_aperture_height = 14; //[7:28:1]
display_aperture_depth = 6; //[3:12:1]

include_retention_tabs = 1; //[0:1:1]
tab_width = 6; //[3:12:0.5]
tab_height = 10; //[5:20:1]
tab_thickness = 2; //[1:4:0.5]
tab_z_offset_from_bezel_back = 10; //[4:20:1]

include_buttons = 1; //[0:1:1]
button_diameter = 4; //[2:8:0.5]
button_height = 2; //[1:5:0.5]
button_spacing_x = 8; //[4:16:1]
button_offset_y = 9; //[4:14:1]

include_pcb_volume = 0; //[0:1:1]
pcb_clearance_width = 42; //[21:84:1]
pcb_clearance_height = 24; //[12:48:1]
pcb_clearance_depth = 18; //[9:36:1]

panel_thickness = 3; //[1:8:0.5]

// Added DSN-DC details
lens_thickness = 1.2;
lens_inset = 0.6;
lens_margin = 1.2;

face_recess_depth = 0.8;
face_recess_margin = 2.0;

terminal_block_w = 34;
terminal_block_h = 10;
terminal_block_d = 6;

terminal_post_d = 3.2;
terminal_post_h = 4.5;
terminal_post_spacing_x = 10;
terminal_post_spacing_y = 6;

wire_boss_d = 6;
wire_boss_h = 4;

// Extra exterior details that were floating in the provided views (now attached)
include_front_bar = 1;          // small front/bottom orange bar under display
front_bar_w = 18;
front_bar_h = 2.2;
front_bar_d = 1.6;

include_right_strip = 1;        // right-side orange strip/plate
right_strip_w = 1.8;            // thickness in X
right_strip_h = 14;             // height in Y
right_strip_d = 10;             // depth in Z

include_bottom_pins = 1;        // bottom terminal pins/posts visible in top/bottom views
bottom_pin_d = 3.2;
bottom_pin_h = 6.0;
bottom_pin_spacing_x = 8.0;
bottom_pin_count = 4;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_prism(size=[10,10,10], r=1, center=true) {
    r2 = clamp(r, 0, min(size[0], size[1]) / 2 - 0.01);
    if (r2 <= 0) {
        cube(size, center=center);
    } else {
        minkowski() {
            cube([size[0]-2*r2, size[1]-2*r2, size[2]], center=center);
            cylinder(r=r2, h=0.01, center=true);
        }
    }
}

module panel_meter_solid() {
    // Coordinate convention:
    // Front face of bezel at z = +bezel_thickness/2
    // Back extends to negative z.

    // Derived Z positions
    z_bezel_center = 0;
    z_bezel_front  = z_bezel_center + bezel_thickness/2;
    z_bezel_back   = z_bezel_center - bezel_thickness/2;

    // Body overlaps into bezel by overlap_mm
    z_body_center  = z_bezel_back - body_depth/2 + overlap_mm;
    z_body_front   = z_body_center + body_depth/2;
    z_body_back    = z_body_center - body_depth/2;

    // Lens placement (touch/overlap bezel)
    z_lens_center  = z_bezel_front - lens_inset - lens_thickness/2;

    // Terminal block placement (attached to back of body)
    z_term_center  = z_body_back - terminal_block_d/2 + overlap_mm;

    // Wire bosses (attached to terminal block back)
    z_boss_center  = (z_term_center - terminal_block_d/2) - wire_boss_h/2 + overlap_mm;

    // Face recess (subtractive)
    recess_w = display_aperture_width + 2*(lens_margin + face_recess_margin);
    recess_h = display_aperture_height + 2*(lens_margin + face_recess_margin);

    // Lens size
    lens_w = display_aperture_width + 2*lens_margin;
    lens_h = display_aperture_height + 2*lens_margin;

    // Terminal post positions (4 posts typical)
    post_xs = [-terminal_post_spacing_x/2, terminal_post_spacing_x/2];
    post_ys = [-terminal_post_spacing_y/2, terminal_post_spacing_y/2];

    union() {
        difference() {
            union() {
                // Bezel
                translate([0,0,z_bezel_center])
                    rounded_rect_prism([bezel_width, bezel_height, bezel_thickness], r=1.2, center=true);

                // Rear body
                translate([0,0,z_body_center])
                    rounded_rect_prism([body_width, body_height, body_depth], r=1.0, center=true);

                // Retention tabs/clips (left/right) - ensure overlap into body (no gap)
                if (include_retention_tabs) {
                    // Overlap into body by overlap_mm: inner face at x = body_width/2 - overlap_mm
                    x_tab = body_width/2 + tab_width/2 - overlap_mm;
                    // Keep them within body depth region so they intersect the body volume
                    z_tab_center = clamp(z_bezel_back - tab_z_offset_from_bezel_back,
                                        z_body_back + tab_thickness/2,
                                        z_body_front - tab_thickness/2);
                    translate([ x_tab, 0, z_tab_center])
                        cube([tab_width, tab_height, tab_thickness], center=true);
                    translate([-x_tab, 0, z_tab_center])
                        cube([tab_width, tab_height, tab_thickness], center=true);
                }

                // Terminal block (attached to back of body)
                translate([0, 0, z_term_center])
                    rounded_rect_prism([terminal_block_w, terminal_block_h, terminal_block_d], r=0.8, center=true);

                // Terminal posts (4), attached to terminal block back face (overlap)
                for (ix = post_xs)
                    for (iy = post_ys)
                        translate([ix, iy, (z_term_center - terminal_block_d/2) - terminal_post_h/2 + overlap_mm])
                            cylinder(d=terminal_post_d, h=terminal_post_h, center=true);

                // Wire bosses (2), attached behind terminal block (overlap)
                boss_x = terminal_block_w/2 - wire_boss_d/2 - 2;
                translate([ boss_x, 0, z_boss_center])
                    cylinder(d=wire_boss_d, h=wire_boss_h, center=true);
                translate([-boss_x, 0, z_boss_center])
                    cylinder(d=wire_boss_d, h=wire_boss_h, center=true);

                // Bottom terminal pins/posts (visible in top/bottom views) - attach to bottom of body
                if (include_bottom_pins) {
                    // Attach to bottom face (negative Y) of body with overlap
                    y_pin = -body_height/2 - bottom_pin_h/2 + overlap_mm;
                    // Place them within the body depth so they intersect the body (use body center Z)
                    z_pin = z_body_center;
                    x0 = -bottom_pin_spacing_x*(bottom_pin_count-1)/2;
                    for (i=[0:bottom_pin_count-1]) {
                        translate([x0 + i*bottom_pin_spacing_x, y_pin, z_pin])
                            cylinder(d=bottom_pin_d, h=bottom_pin_h, center=true);
                    }
                }

                // Buttons (2) on front, connected to bezel front
                if (include_buttons) {
                    z_btn_center = z_bezel_front + button_height/2 - overlap_mm;
                    translate([-button_spacing_x/2, -button_offset_y, z_btn_center])
                        cylinder(d=button_diameter, h=button_height, center=true);
                    translate([ button_spacing_x/2, -button_offset_y, z_btn_center])
                        cylinder(d=button_diameter, h=button_height, center=true);
                }

                // Small front/bottom bar under display - attach to bezel front face with overlap
                if (include_front_bar) {
                    // Put it on the front face, slightly embedded
                    z_bar = z_bezel_front + front_bar_d/2 - overlap_mm;
                    // Under the display window (towards bottom)
                    y_bar = -bezel_height*0.28;
                    translate([0, y_bar, z_bar])
                        cube([front_bar_w, front_bar_h, front_bar_d], center=true);
                }

                // Right-side strip/plate - attach to right side of body with overlap
                if (include_right_strip) {
                    // Embed into body side by overlap_mm
                    x_strip = body_width/2 + right_strip_w/2 - overlap_mm;
                    // Keep within body height and depth so it intersects
                    y_strip = 0;
                    z_strip = z_body_center;
                    translate([x_strip, y_strip, z_strip])
                        cube([right_strip_w, right_strip_h, right_strip_d], center=true);
                }

                // Lens (overlapping into bezel)
                translate([0, 0, z_lens_center])
                    rounded_rect_prism([lens_w, lens_h, lens_thickness], r=0.8, center=true);
            }

            // Display aperture cut-through in bezel
            translate([0, 0, z_bezel_center])
                cube([display_aperture_width, display_aperture_height, bezel_thickness + 2*overlap_mm], center=true);

            // Shallow face recess around lens
            translate([0, 0, z_bezel_front - face_recess_depth/2 + overlap_mm])
                rounded_rect_prism([recess_w, recess_h, face_recess_depth + 2*overlap_mm], r=1.0, center=true);

            // Optional: small notch on bottom edge (subtractive)
            notch_w = bezel_width * 0.35;
            notch_h = 2.0;
            notch_d = 1.2;
            translate([0, -bezel_height/2 + notch_h/2 + 0.6, z_bezel_front - notch_d/2 + overlap_mm])
                cube([notch_w, notch_h, notch_d + 2*overlap_mm], center=true);
        }
    }
}

// Cutout helper (kept as a connected "panel" slab so it doesn't float as a separate part)
show_panel_cutout = 0; //[0:1:1]

module panel_with_cutout() {
    panel_w = bezel_width + 20;
    panel_h = bezel_height + 20;

    z_bezel_center = 0;
    z_bezel_front  = z_bezel_center + bezel_thickness/2;

    // Put panel in front of bezel, overlapping slightly
    z_panel_center = z_bezel_front + panel_thickness/2 - overlap_mm;

    difference() {
        union() {
            panel_meter_solid();
            if (show_panel_cutout)
                translate([0,0,z_panel_center])
                    cube([panel_w, panel_h, panel_thickness], center=true);
        }
        if (show_panel_cutout) {
            translate([0,0,z_panel_center])
                cube([body_width + 2*cutout_offset_clearance_mm,
                      body_height + 2*cutout_offset_clearance_mm,
                      panel_thickness + 2*overlap_mm], center=true);
        }
    }
}

panel_with_cutout();
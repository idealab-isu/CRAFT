$fn=96;

// DSN-DC 100V 10A Voltmeter/Ammeter panel meter (approximate model)
// Units: mm

// ---------- Parameters ----------
body_w = 48.0;
body_h = 29.0;
body_d = 22.0;

bezel_w = 50.0;
bezel_h = 31.0;
bezel_t = 2.2;

corner_r = 2.2;

face_recess = 0.8;          // slight recess for display window
window_margin = 2.2;
window_r = 1.2;

window_w = bezel_w - 2*window_margin;
window_h = bezel_h - 2*window_margin;

clip_w = 6.0;
clip_h = 10.0;
clip_t = 1.6;
clip_offset_z = 9.0;        // from front face into body

terminal_block_w = 44.0;
terminal_block_h = 10.0;
terminal_block_d = 7.0;

terminal_pitch = 8.0;
terminal_count = 5;
terminal_d = 3.2;
terminal_len = 6.0;

label_t = 0.35;

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

module recessed_window(){
    // cutout/recess on bezel face
    translate([0,0,bezel_t-face_recess])
        linear_extrude(height=face_recess+0.02)
            rounded_rect_2d(window_w, window_h, window_r);
}

module terminal_block(){
    // block at rear
    translate([0,0,bezel_t+body_d-terminal_block_d])
        rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.2);
}

module terminals(){
    // cylindrical terminals protruding from rear block
    x0 = -(terminal_pitch*(terminal_count-1))/2;
    for(i=[0:terminal_count-1]){
        translate([x0 + i*terminal_pitch, 0, bezel_t+body_d])
            rotate([90,0,0])
                cylinder(d=terminal_d, h=terminal_len, center=false);
    }
}

module side_clips(){
    // simple spring clips on left/right sides
    for(s=[-1,1]){
        translate([s*(body_w/2 + clip_t/2), 0, bezel_t + clip_offset_z])
            rotate([0,90,0])
                linear_extrude(height=clip_t)
                    rounded_rect_2d(clip_h, clip_w, 1.0);
    }
}

module face_label(){
    // subtle raised label on bezel top edge
    translate([0, bezel_h/2 - 4.2, bezel_t])
        linear_extrude(height=label_t)
            offset(r=0.4)
                text("DSN-DC", size=4.2, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

// ---------- Model ----------
module panel_meter(){
    difference(){
        union(){
            // Bezel (front flange)
            rounded_box(bezel_w, bezel_h, bezel_t, corner_r);

            // Main body behind bezel
            translate([0,0,bezel_t])
                rounded_box(body_w, body_h, body_d, corner_r);

            // Side clips
            side_clips();

            // Rear terminal block
            terminal_block();

            // Terminals
            terminals();

            // Label
            face_label();
        }

        // Display window recess
        recessed_window();

        // Slight inner cavity behind window (gives impression of screen)
        translate([0,0,bezel_t-0.01])
            linear_extrude(height=bezel_t+6)
                rounded_rect_2d(window_w-1.2, window_h-1.2, window_r);

        // Small notch at bottom center (common on some bezels)
        translate([0, -bezel_h/2 + 1.2, 0])
            cube([10, 2.4, bezel_t+0.2], center=true);
    }

    // Dark "screen" insert
    color([0.05,0.05,0.05])
        translate([0,0,bezel_t-face_recess+0.05])
            linear_extrude(height=0.6)
                rounded_rect_2d(window_w-1.6, window_h-1.6, window_r);

    // Red top strip hint (many DSN modules have red LED display)
    color([0.6,0.0,0.0])
        translate([0, (window_h/2 - 4.2), bezel_t-face_recess+0.08])
            cube([window_w-4.0, 6.0, 0.35], center=true);

    // Blue bottom strip hint (ammeter/voltmeter dual display often red/blue)
    color([0.0,0.15,0.6])
        translate([0, -(window_h/2 - 4.2), bezel_t-face_recess+0.08])
            cube([window_w-4.0, 6.0, 0.35], center=true);
}

panel_meter();
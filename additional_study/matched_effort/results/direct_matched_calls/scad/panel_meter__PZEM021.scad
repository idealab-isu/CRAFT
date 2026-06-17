$fn=96;

// Peacefair PZEM-021 AC digital multi-function meter (approximate external model)
// Units: mm

// ---------- Parameters ----------
body_w = 85.0;
body_h = 45.0;
body_d = 30.0;

front_bezel_w = 90.0;
front_bezel_h = 50.0;
front_bezel_t = 3.0;

corner_r = 2.0;

screen_w = 60.0;
screen_h = 26.0;
screen_inset = 1.2;

screen_margin_top = 8.0;   // from top of bezel
screen_margin_left = (front_bezel_w - screen_w)/2;

button_d = 6.0;
button_h = 1.5;
button_offset_y = 10.0; // from bottom of bezel
button_spacing = 18.0;

terminal_block_w = 78.0;
terminal_block_h = 12.0;
terminal_block_d = 10.0;

terminal_screw_d = 3.2;
terminal_screw_pitch = 10.0;
terminal_count = 6;

clip_w = 10.0;
clip_h = 6.0;
clip_t = 2.0;

label_depth = 0.4;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=false);
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

module bezel(){
    // Bezel plate with slight chamfer impression
    difference(){
        translate([-(front_bezel_w-body_w)/2, -(front_bezel_h-body_h)/2, body_d])
            rounded_box(front_bezel_w, front_bezel_h, front_bezel_t, corner_r+0.8);

        // Screen recess
        translate([-(front_bezel_w/2) + screen_margin_left, -(front_bezel_h/2) + (front_bezel_h - screen_margin_top - screen_h), body_d + front_bezel_t - screen_inset])
            cube([screen_w, screen_h, screen_inset+0.2], center=false);

        // Button recesses (two)
        for(i=[-0.5,0.5]){
            translate([0 + i*button_spacing, -(front_bezel_h/2) + button_offset_y, body_d + front_bezel_t - 0.8])
                cylinder(d=button_d+0.8, h=1.0, center=false);
        }
    }

    // Screen "glass"
    color([0.05,0.08,0.10])
    translate([-(front_bezel_w/2) + screen_margin_left + 0.6, -(front_bezel_h/2) + (front_bezel_h - screen_margin_top - screen_h) + 0.6, body_d + front_bezel_t - screen_inset + 0.05])
        cube([screen_w-1.2, screen_h-1.2, 0.8], center=false);

    // Buttons
    color([0.15,0.15,0.15])
    for(i=[-0.5,0.5]){
        translate([0 + i*button_spacing, -(front_bezel_h/2) + button_offset_y, body_d + front_bezel_t])
            cylinder(d=button_d, h=button_h, center=false);
    }

    // Simple embossed label
    color([0.85,0.85,0.85])
    translate([-(front_bezel_w/2)+6, (front_bezel_h/2)-8, body_d + front_bezel_t - label_depth])
        linear_extrude(height=label_depth)
            text("PZEM-021", size=5.5, font="Liberation Sans:style=Bold", halign="left", valign="top");
}

module main_body(){
    // Main housing
    color([0.92,0.92,0.92])
    difference(){
        translate([-body_w/2, -body_h/2, 0])
            rounded_box(body_w, body_h, body_d, corner_r);

        // Rear cavity hint
        translate([-body_w/2+2, -body_h/2+2, 2])
            cube([body_w-4, body_h-4, body_d-6], center=false);

        // Terminal opening at rear top
        translate([-terminal_block_w/2, body_h/2 - terminal_block_h - 2, -0.1])
            cube([terminal_block_w, terminal_block_h+2, 6], center=false);
    }

    // Rear terminal block
    color([0.85,0.85,0.85])
    translate([-terminal_block_w/2, body_h/2 - terminal_block_h - 2, -terminal_block_d])
        cube([terminal_block_w, terminal_block_h, terminal_block_d], center=false);

    // Terminal screws
    color([0.35,0.35,0.35])
    for(i=[0:terminal_count-1]){
        x = -((terminal_count-1)*terminal_screw_pitch)/2 + i*terminal_screw_pitch;
        translate([x, body_h/2 - terminal_block_h/2 - 2, -terminal_block_d/2])
            rotate([90,0,0])
                cylinder(d=terminal_screw_d, h=terminal_block_h+1, center=true);
    }

    // Side clips (approx)
    color([0.75,0.75,0.75])
    for(side=[-1,1]){
        translate([side*(body_w/2 + clip_t/2), 0, body_d*0.55])
            rotate([0,90,0])
                cube([clip_h, clip_w, clip_t], center=true);
    }
}

module panel_meter(){
    main_body();
    bezel();
}

// ---------- Render ----------
panel_meter();
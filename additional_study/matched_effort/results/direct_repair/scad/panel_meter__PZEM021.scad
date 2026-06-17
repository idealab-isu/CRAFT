$fn=96;

// Peacefair PZEM-021 AC digital multi-function meter (approximate model)
// Units: mm

// ---------- Parameters ----------
body_w = 85.0;
body_h = 45.0;
body_d = 31.0;

front_bezel_w = 90.0;
front_bezel_h = 50.0;
front_bezel_t = 3.0;

corner_r = 2.5;

screen_w = 50.0;
screen_h = 22.0;
screen_inset = 1.2;

button_d = 6.0;
button_h = 2.0;

terminal_block_w = 85.0;
terminal_block_h = 12.0;
terminal_block_d = 10.0;

screw_d = 3.2;
screw_head_d = 6.0;
screw_head_h = 1.6;

label_depth = 0.6;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

module countersunk_hole(d_thru, d_head, h_head, depth){
    // Through hole + shallow counterbore (not true countersink)
    union(){
        cylinder(d=d_thru, h=depth+0.2, center=false);
        translate([0,0,depth-h_head])
            cylinder(d=d_head, h=h_head+0.2, center=false);
    }
}

module bezel(){
    // Front bezel plate with window and button holes
    difference(){
        translate([0,0,body_d])
            rounded_box(front_bezel_w, front_bezel_h, front_bezel_t, corner_r+1.0);

        // Screen window
        translate([0, 6.0, body_d + front_bezel_t - screen_inset])
            linear_extrude(height=screen_inset+0.3)
                rounded_rect_2d(screen_w, screen_h, 1.5);

        // Button holes (3)
        for(i=[-1,0,1]){
            translate([i*12.0, -14.0, body_d + front_bezel_t - 2.0])
                cylinder(d=button_d+0.8, h=3.0, center=false);
        }

        // Corner screw holes (approx)
        for(x=[-front_bezel_w/2+8, front_bezel_w/2-8])
        for(y=[-front_bezel_h/2+8, front_bezel_h/2-8]){
            translate([x,y,body_d])
                countersunk_hole(screw_d, screw_head_d, screw_head_h, front_bezel_t+0.2);
        }
    }
}

module body(){
    // Main housing behind bezel
    translate([0,0,0])
        rounded_box(body_w, body_h, body_d, corner_r);
}

module screen(){
    // Slightly recessed dark screen area behind window
    translate([0, 6.0, body_d + front_bezel_t - screen_inset - 0.8])
        color([0.05,0.05,0.06])
            linear_extrude(height=0.8)
                rounded_rect_2d(screen_w-1.0, screen_h-1.0, 1.2);
}

module buttons(){
    // Three small buttons on front
    for(i=[-1,0,1]){
        translate([i*12.0, -14.0, body_d + front_bezel_t - 1.8])
            color([0.85,0.85,0.85])
                cylinder(d=button_d, h=button_h, center=false);
    }
}

module terminal_block(){
    // Rear terminal block protrusion
    translate([0, -body_h/2 - terminal_block_h/2 + 2.0, 6.0])
        color([0.15,0.15,0.15])
            rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.2);

    // Terminal slots (6)
    difference(){
        translate([0, -body_h/2 - terminal_block_h/2 + 2.0, 6.0])
            rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.2);

        for(i=[-2.5,-1.5,-0.5,0.5,1.5,2.5]){
            translate([i*(terminal_block_w/6.5), -body_h/2 - terminal_block_h/2 + 2.0, 6.0 + terminal_block_d/2])
                rotate([90,0,0])
                    cylinder(d=3.2, h=terminal_block_h+2, center=true);
        }
    }
}

module side_clips(){
    // Simple mounting clips on sides (approx)
    clip_w = 10;
    clip_h = 18;
    clip_t = 2.5;
    clip_z = body_d/2;

    for(s=[-1,1]){
        translate([s*(body_w/2 + clip_t/2), 0, clip_z])
            color([0.2,0.2,0.2])
                rotate([0,90,0])
                    linear_extrude(height=clip_t, center=true)
                        rounded_rect_2d(clip_h, clip_w, 1.5);
    }
}

module front_text(){
    // Minimal embossed label
    translate([0, front_bezel_h/2 - 7.5, body_d + front_bezel_t - 0.8])
        color([0.9,0.9,0.9])
            linear_extrude(height=label_depth)
                text("PZEM-021", size=6.5, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

// ---------- Assembly ----------
module pzem021(){
    color([0.92,0.92,0.92]) body();
    color([0.95,0.95,0.95]) bezel();
    screen();
    buttons();
    terminal_block();
    side_clips();
    front_text();
}

pzem021();
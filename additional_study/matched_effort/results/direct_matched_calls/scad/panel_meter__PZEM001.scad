$fn=96;

// Peacefair PZEM-001 style panel meter (approximate dimensions)
// Units: mm

// ---------- Parameters ----------
body_w = 80;
body_h = 43;
body_d = 25;

bezel_w = 85;
bezel_h = 45;
bezel_t = 3;

corner_r = 2.5;

screen_w = 50;
screen_h = 26;
screen_inset = 1.2;

screen_margin_top = 7.5;   // from top of bezel to screen opening
screen_margin_left = (bezel_w - screen_w)/2;

button_d = 6.5;
button_h = 1.6;
button_offset_x = 28;      // from center
button_y = - (bezel_h/2 - 9.5);

terminal_block_w = 78;
terminal_block_h = 14;
terminal_block_d = 10;
terminal_block_offset_z = - (body_d/2 + terminal_block_d/2 - 2);

wire_hole_d = 4.2;
wire_hole_spacing = 10;
wire_hole_count = 6;

clip_w = 10;
clip_h = 6;
clip_d = 6;
clip_offset_y = 0;
clip_offset_z = -2;

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
    linear_extrude(height=d, center=true)
        rounded_rect_2d(w,h,r);
}

module screw_terminal_block(){
    // simple block with wire entry holes
    difference(){
        translate([0,0,terminal_block_offset_z])
            rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.2);

        // wire holes along front face
        for(i=[0:wire_hole_count-1]){
            x = (-(wire_hole_spacing*(wire_hole_count-1))/2) + i*wire_hole_spacing;
            translate([x, terminal_block_h/2 + 0.01, terminal_block_offset_z])
                rotate([90,0,0])
                    cylinder(d=wire_hole_d, h=terminal_block_h+2, center=true);
        }

        // shallow screw recesses on top
        for(i=[0:wire_hole_count-1]){
            x = (-(wire_hole_spacing*(wire_hole_count-1))/2) + i*wire_hole_spacing;
            translate([x, 0, terminal_block_offset_z + terminal_block_d/2 - 2.2])
                cylinder(d=5.2, h=3.0, center=true);
        }
    }
}

module front_bezel(){
    // bezel plate with screen opening and two buttons
    difference(){
        translate([0,0,(body_d/2 + bezel_t/2)])
            rounded_box(bezel_w, bezel_h, bezel_t, corner_r);

        // screen opening
        translate([
            -bezel_w/2 + screen_margin_left + screen_w/2,
            bezel_h/2 - screen_margin_top - screen_h/2,
            (body_d/2 + bezel_t/2)
        ])
        translate([0,0,0])
            cube([screen_w, screen_h, bezel_t+0.5], center=true);

        // slight recess around screen (cosmetic)
        translate([
            -bezel_w/2 + screen_margin_left + screen_w/2,
            bezel_h/2 - screen_margin_top - screen_h/2,
            (body_d/2 + bezel_t/2) - 0.6
        ])
            cube([screen_w+4, screen_h+4, bezel_t], center=true);
    }

    // buttons (raised)
    for(s=[-1,1]){
        translate([s*button_offset_x, button_y, body_d/2 + bezel_t + button_h/2])
            cylinder(d=button_d, h=button_h, center=true);
    }

    // screen "glass" (tinted insert)
    translate([
        -bezel_w/2 + screen_margin_left + screen_w/2,
        bezel_h/2 - screen_margin_top - screen_h/2,
        body_d/2 + bezel_t - 0.35
    ])
    color([0.05,0.08,0.10,0.85])
        cube([screen_w-1.0, screen_h-1.0, 0.7], center=true);
}

module main_body(){
    // main housing behind bezel
    difference(){
        rounded_box(body_w, body_h, body_d, corner_r);

        // slight back cavity (to suggest shell)
        translate([0,0,-2])
            rounded_box(body_w-4, body_h-4, body_d-6, corner_r-0.8);

        // side clip notches
        for(s=[-1,1]){
            translate([s*(body_w/2-1.5), clip_offset_y, clip_offset_z])
                cube([4, clip_h, clip_d], center=true);
        }
    }

    // side clips (simple tabs)
    for(s=[-1,1]){
        translate([s*(body_w/2 + clip_w/2 - 1.0), clip_offset_y, clip_offset_z])
            cube([clip_w, clip_h, clip_d], center=true);
    }
}

module panel_meter(){
    color([0.12,0.12,0.12]) main_body();
    color([0.10,0.10,0.10]) front_bezel();
    color([0.18,0.18,0.18]) screw_terminal_block();
}

// ---------- Render ----------
panel_meter();
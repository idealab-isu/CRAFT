$fn=64;

meter_body_w = 72;
meter_body_h = 72;
meter_body_d = 30;

front_bezel_w = 80;
front_bezel_h = 80;
front_bezel_t = 3;

cutout_w = 68;
cutout_h = 68;

screen_w = 50;
screen_h = 26;
screen_inset = 1.2;

button_d = 6;
button_h = 2.2;

screw_hole_d = 3.2;
screw_hole_inset = 6.5;

terminal_block_w = 72;
terminal_block_h = 16;
terminal_block_d = 10;

terminal_count = 4;
terminal_pitch = 14;
terminal_hole_d = 4.2;
terminal_hole_depth = 8;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module bezel(){
    difference(){
        linear_extrude(height=front_bezel_t)
            rounded_rect_2d(front_bezel_w, front_bezel_h, 3);
        translate([0,0,-0.1])
            linear_extrude(height=front_bezel_t+0.2)
                rounded_rect_2d(cutout_w, cutout_h, 1.5);
    }
}

module body(){
    translate([0,0,-meter_body_d/2])
        cube([meter_body_w, meter_body_h, meter_body_d], center=true);
}

module screen_window(){
    translate([0, 10, front_bezel_t - screen_inset])
        linear_extrude(height=screen_inset+0.2)
            rounded_rect_2d(screen_w, screen_h, 1.5);
}

module button(){
    translate([0, -22, front_bezel_t])
        cylinder(d=button_d, h=button_h, center=false);
}

module screw_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(front_bezel_w/2 - screw_hole_inset), sy*(front_bezel_h/2 - screw_hole_inset), -0.1])
            cylinder(d=screw_hole_d, h=front_bezel_t+0.2, center=false);
    }
}

module terminal_block(){
    translate([0, -(meter_body_h/2 + terminal_block_h/2), -meter_body_d/2 + terminal_block_d/2])
        difference(){
            cube([terminal_block_w, terminal_block_h, terminal_block_d], center=true);
            for(i=[0:terminal_count-1]){
                x = (i-(terminal_count-1)/2)*terminal_pitch;
                translate([x, 0, terminal_block_d/2 - terminal_hole_depth/2 + 0.01])
                    cylinder(d=terminal_hole_d, h=terminal_hole_depth, center=true);
            }
        }
}

module panel_meter(){
    union(){
        difference(){
            union(){
                translate([0,0,0]) bezel();
                translate([0,0,-front_bezel_t - meter_body_d/2]) body();
                terminal_block();
            }
            screen_window();
            screw_holes();
        }
        button();
    }
}

panel_meter();
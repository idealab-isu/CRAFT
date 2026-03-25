$fn=64;

L = 0.3;
W = 0.1;
H = 0.3;

wall = 0.01;
bottom = 0.02;

lip_w = 0.02;
lip_t = 0.01;

corner_r = 0.02;
inner_r = max(0.001, corner_r - wall);

hole_w = 0.018;
hole_h = 0.028;
hole_pitch_x = 0.035;
hole_pitch_z = 0.05;

module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        translate([ l/2 - r2,  w/2 - r2]) circle(r=r2);
        translate([-l/2 + r2,  w/2 - r2]) circle(r=r2);
        translate([ l/2 - r2, -w/2 + r2]) circle(r=r2);
        translate([-l/2 + r2, -w/2 + r2]) circle(r=r2);
    }
}

module tray_shell(){
    difference(){
        linear_extrude(height=H)
            rounded_rect_2d(L, W, corner_r);
        translate([0,0,bottom])
            linear_extrude(height=H-bottom+0.001)
                rounded_rect_2d(L-2*wall, W-2*wall, inner_r);
    }
}

module lip(){
    translate([0,0,H-lip_t])
    difference(){
        linear_extrude(height=lip_t)
            rounded_rect_2d(L+2*lip_w, W+2*lip_w, corner_r+lip_w);
        translate([0,0,-0.001])
            linear_extrude(height=lip_t+0.002)
                rounded_rect_2d(L, W, corner_r);
    }
}

module diamond_hole(thickness, w, h){
    rotate([0,90,0])
        linear_extrude(height=thickness, center=true)
            rotate(45)
                square([w,h], center=true);
}

module perforate_long_sides(){
    x_inset = wall*0.6;
    y_pos = W/2 - wall/2;
    z0 = bottom + 0.03;
    z1 = H - lip_t - 0.03;

    for (x = [-L/2 + corner_r + 0.02 : hole_pitch_x : L/2 - corner_r - 0.02])
        for (z = [z0 : hole_pitch_z : z1])
            translate([x, y_pos, z])
                diamond_hole(wall*2.2, hole_w, hole_h);

    for (x = [-L/2 + corner_r + 0.02 : hole_pitch_x : L/2 - corner_r - 0.02])
        for (z = [z0 : hole_pitch_z : z1])
            translate([x, -y_pos, z])
                diamond_hole(wall*2.2, hole_w, hole_h);
}

module perforate_short_sides(){
    y_inset = wall*0.6;
    x_pos = L/2 - wall/2;
    z0 = bottom + 0.03;
    z1 = H - lip_t - 0.03;

    for (y = [-W/2 + corner_r + 0.01 : hole_pitch_x : W/2 - corner_r - 0.01])
        for (z = [z0 : hole_pitch_z : z1])
            translate([x_pos, y, z])
                rotate([0,0,90])
                    diamond_hole(wall*2.2, hole_w, hole_h);

    for (y = [-W/2 + corner_r + 0.01 : hole_pitch_x : W/2 - corner_r - 0.01])
        for (z = [z0 : hole_pitch_z : z1])
            translate([-x_pos, y, z])
                rotate([0,0,90])
                    diamond_hole(wall*2.2, hole_w, hole_h);
}

module tray(){
    difference(){
        union(){
            tray_shell();
            lip();
        }
        perforate_long_sides();
        perforate_short_sides();
    }
}

translate([0,0,-H/2])
    tray();
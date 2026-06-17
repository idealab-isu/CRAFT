$fn=64;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    }
}

module panel_cutout(w,h,r,th){
    linear_extrude(height=th, center=true) rounded_rect_2d(w,h,r);
}

module screw_post(h=8, od=6, id=3.2){
    difference(){
        cylinder(h=h, d=od, center=false);
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=id, center=false);
    }
}

module seven_seg_window(w,h,th){
    translate([0,0,th/2]) cube([w,h,th], center=true);
}

module button(d=6, h=2){
    cylinder(h=h, d=d, center=false);
}

module ruideng_panel_meter(){
    // Approximate common Ruideng panel module dimensions
    body_w = 79;
    body_h = 43;
    body_t = 24;

    bezel_w = 82;
    bezel_h = 45;
    bezel_t = 2.5;
    bezel_r = 2.5;

    face_t = 1.6;

    // Front display window
    win_w = 60;
    win_h = 22;
    win_r = 1.5;

    // Button layout (3 buttons)
    btn_d = 6.2;
    btn_h = 1.8;
    btn_y = -14;
    btn_x_spacing = 12;

    // Rear mounting posts
    post_h = 10;
    post_od = 6.5;
    post_id = 3.2;
    post_x = 34;
    post_y = 16;

    difference(){
        union(){
            // Main body
            translate([0,0,-body_t/2]) cube([body_w, body_h, body_t], center=true);

            // Bezel
            translate([0,0,bezel_t/2]) linear_extrude(height=bezel_t, center=true)
                rounded_rect_2d(bezel_w, bezel_h, bezel_r);

            // Face plate (slightly inset)
            translate([0,0,bezel_t + face_t/2]) linear_extrude(height=face_t, center=true)
                rounded_rect_2d(bezel_w-1.2, bezel_h-1.2, bezel_r);

            // Buttons
            for(i=[-1:1]){
                translate([i*btn_x_spacing, btn_y, bezel_t + face_t]) button(d=btn_d, h=btn_h);
            }

            // Rear screw posts
            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*post_x, sy*post_y, -body_t + 2]) screw_post(h=post_h, od=post_od, id=post_id);
            }
        }

        // Display window cutout through face+bezel
        translate([0,6,bezel_t/2 + face_t/2]) linear_extrude(height=bezel_t+face_t+0.2, center=true)
            rounded_rect_2d(win_w, win_h, win_r);

        // Button recesses (slight)
        for(i=[-1:1]){
            translate([i*btn_x_spacing, btn_y, bezel_t + face_t + btn_h/2])
                cylinder(h=btn_h+0.4, d=btn_d-1.0, center=true);
        }

        // Rear connector cavity (approx)
        translate([0,0,-body_t/2]) translate([0,0,-6])
            cube([60, 28, 14], center=true);

        // Side ventilation slots (approx)
        for(y=[-14:7:14]){
            translate([body_w/2, y, -body_t/2]) rotate([0,90,0])
                cube([10, 2.2, 2.0], center=true);
            translate([-body_w/2, y, -body_t/2]) rotate([0,90,0])
                cube([10, 2.2, 2.0], center=true);
        }
    }
}

ruidend_panel_meter();
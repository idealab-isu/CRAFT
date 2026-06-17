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

module rounded_box(w,h,d,r){
    linear_extrude(height=d, center=true)
        rounded_rect_2d(w,h,r);
}

module seven_seg_digit_2d(w=10,h=18,th=2,gap=1){
    segL = w - 2*th;
    segV = (h - 3*th)/2;
    module segH(y){
        translate([0,y]) square([segL, th], center=true);
    }
    module segVx(x,y){
        translate([x,y]) square([th, segV], center=true);
    }
    union(){
        segH( (h/2) - th/2 );
        segH( 0 );
        segH( -(h/2) + th/2 );
        segVx( -(w/2) + th/2,  (h/4) );
        segVx(  (w/2) - th/2,  (h/4) );
        segVx( -(w/2) + th/2, -(h/4) );
        segVx(  (w/2) - th/2, -(h/4) );
    }
}

module display_window(w=44,h=18,depth=2,corner=2){
    linear_extrude(height=depth, center=true)
        rounded_rect_2d(w,h,corner);
}

module screw_post(d=6,h=18,hole=2.6){
    difference(){
        cylinder(d=d,h=h,center=true);
        cylinder(d=hole,h=h+2,center=true);
    }
}

module terminal_block(w=52,h=12,d=10,holes=4,hole_d=3.2,spacing=12){
    difference(){
        translate([0,0,0]) rounded_box(w,h,d,1.5);
        for(i=[0:holes-1]){
            x = (i-(holes-1)/2)*spacing;
            translate([x,0,0]) rotate([90,0,0]) cylinder(d=hole_d,h=h+2,center=true);
        }
    }
}

module panel_meter(){
    body_w = 48;
    body_h = 29;
    body_d = 24;

    bezel_w = 50;
    bezel_h = 31;
    bezel_d = 3;

    face_recess_d = 1.2;

    window_w = 44;
    window_h = 18;

    cut_w = 45.5;
    cut_h = 26.5;

    post_offset_x = 18;
    post_offset_y = 10;
    post_h = 18;

    union(){
        // Main body with front bezel and face recess
        difference(){
            union(){
                translate([0,0,-(body_d/2 - bezel_d/2)])
                    rounded_box(body_w, body_h, body_d, 2);

                translate([0,0, body_d/2 - bezel_d/2])
                    rounded_box(bezel_w, bezel_h, bezel_d, 2.5);
            }

            // Panel cutout indication (internal cavity) from back side
            translate([0,0,-2])
                rounded_box(cut_w, cut_h, body_d+10, 1.5);

            // Display window recess on front
            translate([0,0, body_d/2 - face_recess_d/2])
                display_window(window_w, window_h, face_recess_d+0.2, 2);

            // Slight inner cavity behind window
            translate([0,0, body_d/2 - bezel_d - 6])
                rounded_box(window_w-2, window_h-2, 10, 1.5);
        }

        // Simple "LCD" plate behind window
        translate([0,0, body_d/2 - bezel_d - 2.5])
            color([0.05,0.05,0.05])
                rounded_box(window_w-1, window_h-1, 1.2, 1.5);

        // Stylized digits (raised slightly)
        translate([0,0, body_d/2 - bezel_d - 1.8])
            color([0.8,0.1,0.1])
            linear_extrude(height=0.8, center=true)
                union(){
                    translate([-12,0]) seven_seg_digit_2d(10,18,2);
                    translate([  0,0]) seven_seg_digit_2d(10,18,2);
                    translate([ 12,0]) seven_seg_digit_2d(10,18,2);
                    translate([ 20,-6]) circle(d=2.2);
                }

        // Internal screw posts
        for(sx=[-1,1], sy=[-1,1]){
            translate([sx*post_offset_x, sy*post_offset_y, -(body_d/2) + post_h/2 + 2])
                screw_post(d=6,h=post_h,hole=2.6);
        }

        // Rear terminal block
        translate([0, -(body_h/2 + 7), -(body_d/2) + 6])
            terminal_block(w=52,h=12,d=10,holes=4,hole_d=3.2,spacing=12);
    }
}

panel_meter();
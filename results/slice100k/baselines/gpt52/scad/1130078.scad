$fn=96;

bbox_x = 52.3;
bbox_y = 50.0;
bbox_z = 38.8;

th = 8.0;

stem_len = 18.0;
stem_w = 18.0;

plate_len = bbox_y - stem_len; // 32
plate_w_front = bbox_x;        // 52.3
plate_w_back  = 30.0;

step_in = 3.0;
step_h = 2.0;

hole_d = 8.0;
hole_y_from_end = 6.0;

ridge_w = 6.0;
ridge_h = 3.0;

module v_plate(len, w0, w1, t){
    linear_extrude(height=t, center=true, convexity=10)
        polygon(points=[
            [-w0/2, 0],
            [ w0/2, 0],
            [ w1/2, len],
            [-w1/2, len]
        ]);
}

module stem(len, w, t){
    translate([0, -len/2, 0])
        cube([w, len, t], center=true);
}

module stepped_shell(){
    union(){
        // Main body
        union(){
            translate([0, -bbox_y/2 + plate_len/2, 0])
                v_plate(plate_len, plate_w_front, plate_w_back, th);

            translate([0, bbox_y/2 - stem_len/2, 0])
                stem(stem_len, stem_w, th);
        }

        // Side step (raised rim) on V-plate
        translate([0, -bbox_y/2 + plate_len/2, th/2 - step_h/2])
            v_plate(plate_len, plate_w_front - 2*step_in, plate_w_back - 2*step_in, step_h);

        // Side step on stem
        translate([0, bbox_y/2 - stem_len/2, th/2 - step_h/2])
            cube([stem_w - 2*step_in, stem_len, step_h], center=true);

        // Central ridge/crease along V-plate
        translate([0, -bbox_y/2 + plate_len/2, th/2 + ridge_h/2])
            linear_extrude(height=ridge_h, center=true, convexity=10)
                polygon(points=[
                    [-ridge_w/2, 0],
                    [ ridge_w/2, 0],
                    [ ridge_w/4, plate_len],
                    [-ridge_w/4, plate_len]
                ]);
    }
}

module hole(){
    translate([0, bbox_y/2 - hole_y_from_end, 0])
        cylinder(d=hole_d, h=th+2, center=true);
}

difference(){
    stepped_shell();
    hole();
}
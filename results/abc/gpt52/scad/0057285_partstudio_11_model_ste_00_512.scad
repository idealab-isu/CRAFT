$fn=64;

plate_x = 0.2;
plate_y = 0.1;
thickness = 0.01;

corner_r = 0.01;

cutout_size = 0.018;
cutout_offset_x = 0.02;
cutout_offset_y = 0.02;
cutout_rot = 45;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module corner_cutout_2d(s){
    rotate(cutout_rot)
        circle(r=s/2, $fn=6);
}

module plate(){
    linear_extrude(height=thickness, center=true)
        rounded_rect_2d(plate_x, plate_y, corner_r);
}

module cutouts(){
    for (sx = [-1, 1], sy = [-1, 1]){
        translate([sx*(plate_x/2 - cutout_offset_x), sy*(plate_y/2 - cutout_offset_y), 0])
            linear_extrude(height=thickness*3, center=true)
                corner_cutout_2d(cutout_size);
    }
}

difference(){
    plate();
    cutouts();
}
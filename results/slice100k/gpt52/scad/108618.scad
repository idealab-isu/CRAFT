$fn=64;

plate_w = 65.0;
plate_h = 20.0;
plate_t = 4.0;

corner_r = 3.0;

win_w = 22.0;
win_h = 14.0;
win_r = 1.5;
win_gap = 3.0;

center_hole_d = 3.0;
center_hole_spacing = 6.0;

end_hole_d = 3.2;
end_hole_inset_x = 5.0;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_rect_prism(w,h,t,r){
    linear_extrude(height=t, center=true)
        rounded_rect_2d(w,h,r);
}

module window_cutout(){
    rounded_rect_prism(win_w, win_h, plate_t+0.4, win_r);
}

module hole(d){
    cylinder(d=d, h=plate_t+0.6, center=true);
}

difference(){
    rounded_rect_prism(plate_w, plate_h, plate_t, corner_r);

    // Two large windows side-by-side
    translate([-(win_w/2 + win_gap/2), 0, 0]) window_cutout();
    translate([ (win_w/2 + win_gap/2), 0, 0]) window_cutout();

    // Two small circular holes centered between windows
    translate([0,  center_hole_spacing/2, 0]) hole(center_hole_d);
    translate([0, -center_hole_spacing/2, 0]) hole(center_hole_d);

    // Mounting holes near each end
    translate([-(plate_w/2 - end_hole_inset_x), 0, 0]) hole(end_hole_d);
    translate([ (plate_w/2 - end_hole_inset_x), 0, 0]) hole(end_hole_d);
}
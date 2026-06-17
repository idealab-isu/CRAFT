$fn=96;

plate_len = 100;
plate_w   = 20;
th        = 2.5;

end_r = plate_w/2;

hole_center_x = plate_len/2 - end_r;
hole_flat_d = 12;
hole_rot = 22.5;

slot_count = 4;
slot_spacing = 16;
slot_start_x = -18;

stem_w = 4;
stem_l = 10;
head_w = 14;
head_l = 5;

module rounded_plate(L, W, T){
    linear_extrude(height=T, center=true)
        hull(){
            translate([-(L/2 - W/2),0]) circle(r=W/2);
            translate([ (L/2 - W/2),0]) circle(r=W/2);
        }
}

module oct_hole(flat_d, T){
    rotate([0,0,hole_rot])
        cylinder(h=T+0.6, r=flat_d/(2*cos(180/8)), $fn=8, center=true);
}

module t_slot(T){
    union(){
        translate([0,0,0]) cube([stem_l, stem_w, T+0.6], center=true);
        translate([stem_l/2 - head_l/2,0,0]) cube([head_l, head_w, T+0.6], center=true);
    }
}

module all_t_slots(T){
    for(i=[0:slot_count-1]){
        x = slot_start_x + i*slot_spacing;
        translate([x,0,0]) t_slot(T);
    }
}

difference(){
    rounded_plate(plate_len, plate_w, th);
    translate([hole_center_x,0,0]) oct_hole(hole_flat_d, th);
    all_t_slots(th);
}
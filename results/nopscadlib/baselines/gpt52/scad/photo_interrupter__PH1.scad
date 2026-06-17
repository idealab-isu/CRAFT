$fn=64;

module pin(d=0.6, h=3.0){
    cylinder(d=d, h=h, center=false);
}

module pins_row(count=3, pitch=2.54, d=0.6, h=3.0){
    for(i=[0:count-1]){
        translate([i*pitch, 0, 0]) pin(d=d, h=h);
    }
}

module photo_interrupter_body(
    body_w=10.0,
    body_d=4.0,
    body_h=8.0,
    slot_w=3.0,
    slot_d=2.0,
    slot_h=6.0,
    gap_w=4.0,
    gap_d=2.0,
    gap_h=6.0,
    top_relief_h=1.2
){
    difference(){
        union(){
            translate([0,0,body_h/2]) cube([body_w, body_d, body_h], center=true);

            translate([0,0,body_h - top_relief_h/2])
                cube([body_w*0.9, body_d*0.9, top_relief_h], center=true);

            translate([0,0,body_h/2])
                cube([body_w, body_d, body_h], center=true);
        }

        translate([0,0,slot_h/2 + 1.0])
            cube([slot_w, slot_d, slot_h], center=true);

        translate([0,0,gap_h/2 + 1.0])
            cube([gap_w, gap_d, gap_h], center=true);

        translate([0,0,body_h/2 + 1.0])
            cube([gap_w, body_d+0.2, gap_h], center=true);
    }
}

module photo_interrupter(
    body_w=10.0,
    body_d=4.0,
    body_h=8.0,
    pin_pitch=2.54,
    pin_d=0.6,
    pin_h=3.0,
    pin_offset_y=0.0,
    pin_z=0.0
){
    union(){
        translate([0,0,pin_h])
            photo_interrupter_body(
                body_w=body_w,
                body_d=body_d,
                body_h=body_h,
                slot_w=3.0,
                slot_d=2.0,
                slot_h=6.0,
                gap_w=4.0,
                gap_d=2.0,
                gap_h=6.0,
                top_relief_h=1.2
            );

        translate([-pin_pitch, pin_offset_y, pin_z])
            pins_row(count=3, pitch=pin_pitch, d=pin_d, h=pin_h);

        translate([pin_pitch*0.5, pin_offset_y, pin_z])
            pins_row(count=3, pitch=pin_pitch, d=pin_d, h=pin_h);
    }
}

translate([0,0,-(3.0 + 8.0/2)]) photo_interrupter();
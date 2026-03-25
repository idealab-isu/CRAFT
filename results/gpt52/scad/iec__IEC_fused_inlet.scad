$fn=64;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module slot_2d(len, wid){
    hull(){
        translate([ len/2 - wid/2, 0]) circle(d=wid);
        translate([-len/2 + wid/2, 0]) circle(d=wid);
    }
}

module iec_inlet_jr101_1f_panel_cutout(
    face_w=36.0,
    face_h=27.0,
    face_t=3.0,
    body_depth=30.0,
    flange_r=2.0,
    cut_w=30.0,
    cut_h=22.0,
    cut_r=1.5,
    screw_hole_d=3.2,
    screw_spacing=30.0,
    screw_offset_y=0.0,
    screw_csk_d=6.5,
    screw_csk_h=1.6
){
    difference(){
        union(){
            linear_extrude(height=face_t, center=true)
                rounded_rect_2d(face_w, face_h, flange_r);

            translate([0,0,-(face_t/2 + body_depth/2)])
                linear_extrude(height=body_depth, center=true)
                    rounded_rect_2d(cut_w, cut_h, cut_r);
        }

        translate([0,0,0])
            linear_extrude(height=face_t + 0.2, center=true)
                rounded_rect_2d(cut_w, cut_h, cut_r);

        for(x=[-screw_spacing/2, screw_spacing/2]){
            translate([x, screw_offset_y, 0])
                cylinder(d=screw_hole_d, h=face_t + 0.4, center=true);

            translate([x, screw_offset_y, face_t/2 - screw_csk_h/2])
                cylinder(d1=screw_csk_d, d2=screw_hole_d, h=screw_csk_h, center=true);
        }
    }
}

iec_inlet_jr101_1f_panel_cutout();
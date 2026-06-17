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

module slot_2d(w, h){
    hull(){
        translate([ w/2 - h/2, 0]) circle(r=h/2);
        translate([-w/2 + h/2, 0]) circle(r=h/2);
    }
}

module iec_fused_inlet_old_cutout(
    face_w=36.0,
    face_h=27.0,
    face_th=3.0,
    body_w=30.0,
    body_h=22.0,
    body_depth=28.0,
    corner_r=2.0,
    clearance=0.2,
    flange_overhang=1.0,
    screw_d=3.2,
    screw_x=30.0,
    screw_y=21.0
){
    union(){
        // Main body cutout through panel
        translate([0,0,-(body_depth/2)])
            linear_extrude(height=body_depth, center=true)
                rounded_rect_2d(body_w + 2*clearance, body_h + 2*clearance, corner_r);

        // Front flange relief (shallow)
        translate([0,0,face_th/2])
            linear_extrude(height=face_th + 0.5, center=true)
                rounded_rect_2d(face_w + 2*clearance, face_h + 2*clearance, corner_r);

        // Screw holes (typical panel mount)
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*screw_x/2, sy*screw_y/2, 0])
                cylinder(d=screw_d + 2*clearance, h=body_depth + face_th + 10, center=true);
        }
    }
}

module panel(size=80, th=3){
    translate([0,0,0])
        cube([size,size,th], center=true);
}

difference(){
    panel(80, 3);
    translate([0,0,0])
        iec_fused_inlet_old_cutout();
}
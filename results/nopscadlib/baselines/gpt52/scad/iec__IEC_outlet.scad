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

module iec_inlet_cutout_2d(){
    // Panel cutout for IEC C14 style inlet (approximate)
    // Outer flange size: 40 x 32 (given)
    // Typical panel cutout: 27.5 x 20.0 with corner radius ~2
    rounded_rect_2d(27.5, 20.0, 2.0);
}

module iec_inlet_flange_3d(th=3.0){
    linear_extrude(height=th)
        rounded_rect_2d(40.0, 32.0, 2.0);
}

module iec_inlet_body_3d(depth=28.0){
    // Body behind panel (approximate)
    translate([0,0,-depth])
        linear_extrude(height=depth)
            rounded_rect_2d(30.0, 24.0, 2.0);
}

module iec_inlet_mount_holes_2d(){
    // Two mounting holes (approximate) centered vertically, spaced horizontally
    hole_d = 3.2;
    spacing = 30.0;
    translate([ spacing/2, 0]) circle(d=hole_d);
    translate([-spacing/2, 0]) circle(d=hole_d);
}

module iec_inlet_module(){
    union(){
        // Flange at panel plane (z=0..th)
        iec_inlet_flange_3d(3.0);
        // Body behind panel (negative z)
        iec_inlet_body_3d(28.0);
    }
}

module iec_inlet_negative(panel_th=3.0, extra=0.5){
    // Negative volume to cut into a panel: cutout + mounting holes
    union(){
        translate([0,0,-extra])
            linear_extrude(height=panel_th + 2*extra)
                iec_inlet_cutout_2d();
        translate([0,0,-extra])
            linear_extrude(height=panel_th + 2*extra)
                iec_inlet_mount_holes_2d();
    }
}

// Render the inlet module centered at origin, with panel plane at z=0
iec_inlet_module();
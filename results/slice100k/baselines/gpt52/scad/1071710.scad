$fn=96;

L = 43.9;
W = 11.0;
H = 10.9;

t = 2.0;                 // constant thickness (Z)
pad_len = 12.0;          // central pad length along X
arm_len = (L - pad_len)/2;

arm_w = 9.0;             // arm width in Y
pad_w = 11.0;            // pad width in Y

arm_rise = (H - t)/2;    // Z rise from pad to arm ends
fillet_r = 6.0;          // large concave/filleted transition radius

module rounded_rect_2d(len, wid, r){
    r2 = min(r, min(len, wid)/2);
    hull(){
        translate([ len/2 - r2,  wid/2 - r2]) circle(r=r2);
        translate([-len/2 + r2,  wid/2 - r2]) circle(r=r2);
        translate([ len/2 - r2, -wid/2 + r2]) circle(r=r2);
        translate([-len/2 + r2, -wid/2 + r2]) circle(r=r2);
    }
}

module slab(len, wid, thick, r=1.0){
    linear_extrude(height=thick, center=true)
        rounded_rect_2d(len, wid, r);
}

module arm(sign=1){
    x0 = sign*(pad_len/2);
    x1 = sign*(L/2);
    z0 = 0;
    z1 = arm_rise;

    hull(){
        translate([x0, 0, z0]) slab(2.0, arm_w, t, r=1.0);
        translate([x1, 0, z1]) slab(2.0, arm_w, t, r=1.0);
    }
}

module pad(){
    slab(pad_len, pad_w, t, r=1.2);
}

module concave_fillet(sign=1){
    xj = sign*(pad_len/2);
    translate([xj, 0, 0])
        rotate([0, 90, 0])
            cylinder(r=fillet_r, h=W+2, center=true);
}

difference(){
    union(){
        pad();
        arm(1);
        arm(-1);
    }
    concave_fillet(1);
    concave_fillet(-1);
}
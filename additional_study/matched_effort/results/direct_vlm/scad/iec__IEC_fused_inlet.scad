$fn=96;

// IEC fused inlet module (JR-101-1F style) - approximate 3D model
// Faceplate: 36.0 x 27.0 mm
// Coordinate system: faceplate centered at origin in X/Y, front face at Z=0, body extends to negative Z.

module rounded_rect_2d(w, h, r){
    r2 = min(r, w/2, h/2);
    offset(r=r2) offset(delta=-r2) square([w, h], center=true);
}

// IEC C14 opening (more recognizable): rounded rect + top key notch
module c14_opening_2d(w=27.0, h=19.0, r=2.0, notch_w=10.0, notch_h=3.2){
    union(){
        rounded_rect_2d(w, h, r);
        // top center notch (key)
        translate([0, h/2 - notch_h/2])
            square([notch_w, notch_h], center=true);
    }
}

// Simple rocker switch opening (rect with slight corner radius)
module rocker_opening_2d(w=12.8, h=7.6, r=0.8){
    rounded_rect_2d(w, h, r);
}

// Fuse drawer outline (front feature)
module fuse_drawer_2d(w=14.0, h=9.0, r=1.0){
    rounded_rect_2d(w, h, r);
}

module iec_inlet_jr101_1f(
    // Faceplate
    face_w=36.0,
    face_h=27.0,
    face_t=3.0,
    face_r=3.0,

    // Main body behind panel
    body_w=30.0,
    body_h=22.0,
    body_d=28.0,
    body_r=1.6,

    // Rear strain relief / terminal block
    rear_w=26.0,
    rear_h=18.0,
    rear_d=8.0,
    rear_r=1.2,

    // Bezel/lip step behind faceplate
    lip_w=1.2,
    lip_h=1.2,
    lip_d=1.2,
    lip_r=2.0,

    // IEC C14 opening (front)
    c14_w=27.0,
    c14_h=19.0,
    c14_r=2.0,
    c14_notch_w=10.0,
    c14_notch_h=3.2,
    c14_y=-2.0,          // slight downward offset typical of combo modules
    c14_depth=14.0,      // cavity depth behind faceplate

    // Inner "socket bezel" recess around C14 (visual)
    bezel_clear=1.6,
    bezel_depth=1.2,

    // Fuse drawer (front, top-left)
    fuse_w=14.0,
    fuse_h=9.0,
    fuse_out=2.6,
    fuse_r=1.0,
    fuse_margin_x=2.0,   // from left edge of faceplate
    fuse_margin_y=2.0,   // from top edge of faceplate
    fuse_recess=0.8,     // shallow recess line

    // Switch (front, top-right)
    sw_w=12.8,
    sw_h=7.6,
    sw_out=2.2,
    sw_r=0.9,
    sw_margin_x=2.0,     // from right edge of faceplate
    sw_margin_y=2.2,     // from top edge of faceplate
    sw_recess=0.7,

    // Pin holes (front) - simplified
    pin_r=1.25,
    pin_depth=10.0,
    pin_spacing_x=7.0,
    pin_spacing_y=5.0
){
    // Derived placements (no arbitrary numbers)
    fuse_cx = -face_w/2 + fuse_margin_x + fuse_w/2;
    fuse_cy =  face_h/2 - fuse_margin_y - fuse_h/2;

    sw_cx   =  face_w/2 - sw_margin_x - sw_w/2;
    sw_cy   =  face_h/2 - sw_margin_y - sw_h/2;

    // Ensure rear block connects to main body with overlap
    rear_zc = -(body_d + rear_d/2 - 1.0);

    difference(){
        union(){
            // Faceplate (front)
            linear_extrude(height=face_t)
                rounded_rect_2d(face_w, face_h, face_r);

            // Lip/step behind faceplate (connected with overlap)
            translate([0,0,-lip_d + 0.25])
                linear_extrude(height=lip_d)
                    rounded_rect_2d(body_w + 2*lip_w, body_h + 2*lip_h, lip_r);

            // Main body behind panel (connected to lip with overlap)
            translate([0,0,-body_d + 0.25])
                linear_extrude(height=body_d)
                    rounded_rect_2d(body_w, body_h, body_r);

            // Rear strain relief / terminal block (connected to body with overlap)
            translate([0,0,rear_zc])
                linear_extrude(height=rear_d, center=true)
                    rounded_rect_2d(rear_w, rear_h, rear_r);

            // Fuse drawer protrusion (front, top-left) - connected to faceplate
            translate([fuse_cx, fuse_cy, face_t - 0.25])
                linear_extrude(height=fuse_out)
                    fuse_drawer_2d(fuse_w, fuse_h, fuse_r);

            // Switch bump (front, top-right) - connected to faceplate
            translate([sw_cx, sw_cy, face_t - 0.25])
                linear_extrude(height=sw_out)
                    rounded_rect_2d(sw_w, sw_h, sw_r);
        }

        // IEC C14 inlet opening through faceplate (more recognizable)
        translate([0, c14_y, -0.05])
            linear_extrude(height=face_t + 0.1)
                c14_opening_2d(c14_w, c14_h, c14_r, c14_notch_w, c14_notch_h);

        // Bezel recess around opening (shallow pocket on front face)
        translate([0, c14_y, face_t - bezel_depth + 0.02])
            linear_extrude(height=bezel_depth + 0.05)
                difference(){
                    rounded_rect_2d(c14_w + 2*bezel_clear, c14_h + 2*bezel_clear, c14_r + 0.8);
                    c14_opening_2d(c14_w, c14_h, c14_r, c14_notch_w, c14_notch_h);
                }

        // Cavity behind opening (slightly larger) into body
        translate([0, c14_y, -c14_depth])
            linear_extrude(height=c14_depth + 0.25)
                rounded_rect_2d(c14_w + 2.6, c14_h + 2.6, c14_r + 0.6);

        // Pin holes (3) inside socket area
        for(p = [
            [-pin_spacing_x/2, c14_y - pin_spacing_y/2],
            [ pin_spacing_x/2, c14_y - pin_spacing_y/2],
            [0,                c14_y + pin_spacing_y/2]
        ]){
            translate([p[0], p[1], -pin_depth])
                cylinder(h=pin_depth + face_t + 0.8, r=pin_r);
        }

        // Switch opening (cut through faceplate) to look like a real rocker cutout
        translate([sw_cx, sw_cy, -0.05])
            linear_extrude(height=face_t + 0.1)
                rocker_opening_2d(sw_w-1.2, sw_h-1.0, max(0.6, sw_r-0.2));

        // Fuse drawer recess line (visual detail)
        translate([fuse_cx, fuse_cy, face_t + 0.15])
            linear_extrude(height=max(0.05, fuse_out - 0.35))
                offset(delta=-fuse_recess)
                    fuse_drawer_2d(fuse_w, fuse_h, fuse_r);

        // Switch recess line (visual detail)
        translate([sw_cx, sw_cy, face_t + 0.15])
            linear_extrude(height=max(0.05, sw_out - 0.35))
                offset(delta=-sw_recess)
                    rounded_rect_2d(sw_w, sw_h, sw_r);
    }
}

// Render
iec_inlet_jr101_1f();
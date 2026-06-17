$fn=96;

// IEC C14 switched fused inlet module (approximate), overall faceplate 40x27mm
// One connected solid with recognizable C14 opening + pin apertures, rocker switch + fuse drawer features, and mounting holes.

module iec_inlet_module(
    // Faceplate (verify: 40 x 27)
    face_w=40.0,
    face_h=27.0,
    face_t=2.4,
    corner_r=2.2,

    // Main body behind faceplate
    body_w=30.0,
    body_h=22.0,
    body_d=28.0,

    // Mounting holes (2 holes, left/right)
    hole_d=3.2,
    hole_x=16.0,          // half spacing in X from center
    hole_y=9.0,           // Y offset from center (both holes share same Y)
    hole_csk_d=6.2,
    hole_csk_h=1.2,

    // Front features (protrusions on front face)
    fuse_w=16.5,
    fuse_h=8.5,
    fuse_out=2.0,
    fuse_inset_x=-9.0,
    fuse_inset_y=6.0,

    switch_w=18.0,
    switch_h=12.0,
    switch_out=2.2,
    switch_inset_x=8.5,
    switch_inset_y=5.0,

    // IEC C14 opening (centered)
    c14_w=27.5,
    c14_h=20.0,
    c14_corner_r=2.0,
    c14_recess=1.2,        // shallow front recess
    c14_through=0,         // auto if 0

    // Pin aperture geometry (approximate)
    pin_w=6.3,
    pin_h=2.2,
    pin_depth=6.0,         // depth of pin apertures into body from front face
    pin_gap=2.0,           // gap between the two lower pins
    earth_d=4.8,
    earth_depth=6.0
){
    eps = 0.02;
    overlap = 0.6; // small overlap to guarantee connectivity

    c14_through_eff = (c14_through <= 0) ? (body_d + face_t + 1.0) : c14_through;

    module rounded_rect_2d(w,h,r){
        r2 = min(r, min(w,h)/2);
        offset(r=r2) offset(delta=-r2) square([w,h], center=true);
    }

    module rounded_box(w,h,d,r,center=false){
        if(center)
            translate([0,0,-d/2]) linear_extrude(height=d) rounded_rect_2d(w,h,r);
        else
            linear_extrude(height=d) rounded_rect_2d(w,h,r);
    }

    // Lip around the C14 opening to make it read as an inlet
    module c14_lip(){
        lip_w = c14_w + 3.0;
        lip_h = c14_h + 3.0;
        lip_t = 0.9;
        translate([0,0,face_t - lip_t])
            difference(){
                rounded_box(lip_w, lip_h, lip_t+eps, c14_corner_r+0.9);
                translate([0,0,-eps])
                    rounded_box(c14_w, c14_h, lip_t+3*eps, c14_corner_r);
            }
    }

    // Pin apertures (negative volumes) placed within the C14 opening
    module c14_pin_apertures(){
        // Start just behind the recess so the lip remains intact
        z_start = face_t - c14_recess - eps;

        // Typical C14 layout: earth at top center, L/N at bottom left/right
        y_lower = -c14_h*0.22;
        y_earth =  c14_h*0.28;

        // Lower blades (rectangular apertures)
        for (sx=[-1,1]){
            x_pin = sx*(pin_w/2 + pin_gap/2);
            translate([x_pin - pin_w/2, y_lower - pin_h/2, z_start - pin_depth])
                cube([pin_w, pin_h, pin_depth + 2*eps], center=false);
        }

        // Earth (round aperture)
        translate([0, y_earth, z_start - earth_depth])
            cylinder(d=earth_d, h=earth_depth + 2*eps, center=false);
    }

    // Engraved outline around a feature on the face
    module engraved_outline(w,h,r,depth=0.6,stroke=0.7){
        translate([0,0,face_t - depth])
            linear_extrude(height=depth+eps)
                difference(){
                    offset(delta=stroke) rounded_rect_2d(w,h,r);
                    rounded_rect_2d(w,h,r);
                }
    }

    difference(){
        union(){
            // Faceplate: z from 0..face_t
            rounded_box(face_w, face_h, face_t, corner_r);

            // Main body behind faceplate: z from -(body_d-overlap)..overlap
            translate([0,0,-body_d + overlap])
                rounded_box(body_w, body_h, body_d, 1.5);

            // Fuse drawer protrusion (front): connected to faceplate with overlap
            translate([fuse_inset_x, fuse_inset_y, face_t - overlap])
                rounded_box(fuse_w, fuse_h, fuse_out + overlap, 1.0);

            // Rocker switch protrusion (front): connected to faceplate with overlap
            translate([switch_inset_x, switch_inset_y, face_t - overlap])
                rounded_box(switch_w, switch_h, switch_out + overlap, 1.2);

            // C14 lip detail (front)
            c14_lip();
        }

        // Mounting holes through faceplate (2 holes: left/right)
        for (sx=[-1,1]){
            translate([sx*hole_x, -hole_y, -eps])
                cylinder(d=hole_d, h=face_t + 2*eps, center=false);

            translate([sx*hole_x, -hole_y, face_t - hole_csk_h])
                cylinder(d1=hole_csk_d, d2=hole_d, h=hole_csk_h + eps, center=false);
        }

        // IEC C14 opening: recess + through opening so it reads as an inlet
        // Recess (front)
        translate([0,0,face_t - c14_recess])
            linear_extrude(height=c14_recess + eps)
                rounded_rect_2d(c14_w, c14_h, c14_corner_r);

        // Through cut (behind recess) to create real opening
        translate([0,0,face_t - c14_recess - eps])
            linear_extrude(height=c14_through_eff)
                rounded_rect_2d(c14_w - 1.0, c14_h - 1.0, max(0.9, c14_corner_r-0.5));

        // Pin apertures inside the opening (recognizable C14 geometry)
        c14_pin_apertures();

        // Engraved separation lines around fuse and switch
        translate([fuse_inset_x, fuse_inset_y, 0])
            engraved_outline(fuse_w, fuse_h, 1.0, depth=0.6, stroke=0.7);

        translate([switch_inset_x, switch_inset_y, 0])
            engraved_outline(switch_w, switch_h, 1.2, depth=0.6, stroke=0.7);

        // Rocker "pivot" groove (subtle)
        translate([switch_inset_x, switch_inset_y, face_t - 0.7])
            cube([switch_w*0.85, 0.9, 0.9], center=true);

        // Fuse drawer finger notch (subtle)
        translate([fuse_inset_x + fuse_w*0.25, fuse_inset_y, face_t - 0.9])
            cylinder(d=3.2, h=1.4, center=false);
    }
}

// Render
iec_inlet_module();
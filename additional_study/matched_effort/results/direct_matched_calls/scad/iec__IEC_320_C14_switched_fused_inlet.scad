$fn=64;

// IEC C14 switched fused inlet module (approximate external model)
// Overall faceplate: 40 x 27 mm
// Includes: faceplate, inlet body, switch rocker, fuse drawer, and simplified C14 opening.

module iec_inlet_module(
    face_w=40.0,
    face_h=27.0,
    face_t=2.6,

    body_w=34.0,
    body_h=22.0,
    body_d=28.0,

    bezel_r=1.2,

    // C14 opening (simplified)
    c14_w=27.5,
    c14_h=19.5,
    c14_corner_r=2.0,
    c14_inset=0.6,

    // Switch rocker (approx)
    sw_w=19.0,
    sw_h=13.0,
    sw_t=2.2,
    sw_offset_x=-9.5,   // left side
    sw_offset_y=0.0,

    // Fuse drawer (approx)
    fuse_w=19.0,
    fuse_h=9.0,
    fuse_t=2.0,
    fuse_offset_x=10.0, // right side
    fuse_offset_y=6.0
){
    // Faceplate centered at origin, normal +Z
    difference() {
        // Faceplate with rounded corners
        linear_extrude(height=face_t)
            rounded_rect(face_w, face_h, bezel_r);

        // C14 opening cut (centered)
        translate([0, 0, -0.01])
            linear_extrude(height=face_t + 0.02)
                rounded_rect(c14_w, c14_h, c14_corner_r);

        // Switch window cut (left)
        translate([sw_offset_x, sw_offset_y, -0.01])
            linear_extrude(height=face_t + 0.02)
                rounded_rect(sw_w+0.6, sw_h+0.6, 1.2);

        // Fuse window cut (right/top-ish)
        translate([fuse_offset_x, fuse_offset_y, -0.01])
            linear_extrude(height=face_t + 0.02)
                rounded_rect(fuse_w+0.6, fuse_h+0.6, 1.0);
    }

    // Main body behind faceplate
    translate([0, 0, -body_d])
        difference() {
            // Outer body
            translate([0,0,body_d/2])
                cube([body_w, body_h, body_d], center=true);

            // Hollow cavity (simplified)
            translate([0,0,body_d/2])
                cube([body_w-3.0, body_h-3.0, body_d-3.0], center=true);

            // C14 throat (behind opening)
            translate([0,0,body_d - 10])
                cube([c14_w-2.0, c14_h-2.0, 14], center=true);
        }

    // Slight recessed lip around C14 opening (visual)
    translate([0,0,face_t - c14_inset])
        difference() {
            linear_extrude(height=c14_inset)
                rounded_rect(c14_w+2.0, c14_h+2.0, c14_corner_r+0.8);
            translate([0,0,-0.01])
                linear_extrude(height=c14_inset+0.02)
                    rounded_rect(c14_w, c14_h, c14_corner_r);
        }

    // Switch rocker (protruding slightly)
    translate([sw_offset_x, sw_offset_y, face_t-0.2])
        rocker(sw_w, sw_h, sw_t);

    // Fuse drawer (protruding slightly)
    translate([fuse_offset_x, fuse_offset_y, face_t-0.2])
        fuse_drawer(fuse_w, fuse_h, fuse_t);
}

// Helpers
module rounded_rect(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2-r2), sy*(h/2-r2)])
                circle(r=r2);
    }
}

module rocker(w,h,t){
    // Slightly convex rocker
    difference(){
        // Base
        linear_extrude(height=t)
            rounded_rect(w,h,1.6);
        // Top scoop to suggest rocker curvature
        translate([0,0,t*0.55])
            rotate([90,0,0])
                cylinder(r=h*0.75, h=w+2, center=true);
    }
}

module fuse_drawer(w,h,t){
    // Drawer with small finger notch
    difference(){
        linear_extrude(height=t)
            rounded_rect(w,h,1.2);
        // notch
        translate([0, -h/2+1.2, -0.01])
            linear_extrude(height=t+0.02)
                rounded_rect(w*0.55, 2.6, 1.0);
        // shallow label recess
        translate([0,0,t*0.35])
            linear_extrude(height=t*0.5)
                rounded_rect(w*0.85, h*0.7, 0.9);
    }
}

// Render
iec_inlet_module();
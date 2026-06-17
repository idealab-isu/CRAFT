$fn=96;

// IEC fused inlet module (JR-101-1F style) - simplified solid model
// Overall faceplate: 36.0 x 27.0 mm
// Includes: front flange, main body, fuse drawer bump, rear terminals block (simplified)

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    }
}

module iec_inlet_jr101_1f(
    face_w=36.0,
    face_h=27.0,
    face_t=2.6,
    face_r=2.0,

    body_w=30.0,
    body_h=22.0,
    body_d=28.0,
    body_r=1.2,

    fuse_w=18.0,
    fuse_h=10.0,
    fuse_d=6.0,
    fuse_offset_y=5.0,

    term_w=26.0,
    term_h=18.0,
    term_d=8.0
){
    // Front faceplate centered at origin, front at z=0, extends to +z
    union(){
        // Faceplate
        linear_extrude(height=face_t)
            rounded_rect_2d(face_w, face_h, face_r);

        // Main body behind faceplate (extends further +z)
        translate([0,0,face_t])
            linear_extrude(height=body_d)
                rounded_rect_2d(body_w, body_h, body_r);

        // Fuse drawer bump on front (slightly protruding)
        translate([0, fuse_offset_y, 0])
            linear_extrude(height=fuse_d)
                rounded_rect_2d(fuse_w, fuse_h, 1.2);

        // Rear terminals block (simplified)
        translate([0,0,face_t+body_d])
            linear_extrude(height=term_d)
                rounded_rect_2d(term_w, term_h, 1.0);

        // Small rear cable strain relief nub (simplified)
        translate([0, -body_h*0.25, face_t+body_d+term_d])
            cylinder(h=6, r=5.5);
    }
}

iec_inlet_jr101_1f();
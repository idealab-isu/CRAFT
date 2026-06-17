$fn=96;

// IEC fused inlet module (old style) - simplified parametric model
// Overall faceplate: 36 x 27 mm
// Includes: faceplate, main body, fuse drawer bump, and two mounting holes.

module iec_fused_inlet_old(
    face_w=36.0,
    face_h=27.0,
    face_t=2.2,

    body_w=30.0,
    body_h=22.0,
    body_d=28.0,

    // Fuse drawer bump (front protrusion)
    fuse_w=18.0,
    fuse_h=10.0,
    fuse_d=6.0,

    // Mounting holes (typical M3 clearance)
    hole_d=3.2,
    hole_x= (36.0/2 - 5.0),   // distance from center to hole in X
    hole_y= (27.0/2 - 5.0),   // distance from center to hole in Y

    // Cosmetic recess on face
    recess_w=28.0,
    recess_h=18.0,
    recess_d=0.8,

    // IEC C14 opening (approx)
    c14_w=27.5,
    c14_h=20.0,
    c14_d=3.0
){
    difference() {
        union() {
            // Faceplate centered at origin, front at Z=0, body extends to +Z
            translate([0,0,face_t/2])
                cube([face_w, face_h, face_t], center=true);

            // Main body behind faceplate
            translate([0,0,face_t + body_d/2])
                cube([body_w, body_h, body_d], center=true);

            // Fuse drawer bump on front (protrudes out of faceplate)
            translate([0, -face_h*0.18, -fuse_d/2 + 0.01])
                cube([fuse_w, fuse_h, fuse_d], center=true);
        }

        // Mounting holes through faceplate
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*hole_x, sy*hole_y, 0])
                cylinder(d=hole_d, h=face_t+0.6, center=true);
        }

        // Cosmetic recess on faceplate
        translate([0,0,face_t - recess_d/2 + 0.001])
            cube([recess_w, recess_h, recess_d], center=true);

        // IEC C14 opening through faceplate and slightly into body
        translate([0,0,face_t/2 + 0.2])
            cube([c14_w, c14_h, face_t + c14_d], center=true);

        // Small chamfer-like corner reliefs (approx) on opening
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(c14_w/2), sy*(c14_h/2), face_t/2 + 0.2])
                rotate([0,0,45])
                    cube([3.0,3.0,face_t + c14_d + 0.2], center=true);
        }
    }
}

// Render
iec_fused_inlet_old();
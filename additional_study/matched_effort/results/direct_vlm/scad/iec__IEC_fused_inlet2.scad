$fn=96;

// IEC fused inlet module (old style) - simplified but featureful parametric model
// Faceplate: 36.0 x 27.0 mm
// One connected solid (with cutouts) including: faceplate, rear body, front fuse drawer bump,
// IEC C14 socket opening, fuse window opening, mounting holes, rear terminal bumps.

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull() {
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
    }
}

module iec_fused_inlet_old(
    // Faceplate
    plate_w=36.0,
    plate_h=27.0,
    plate_t=2.2,

    // Rear body (behind plate)
    body_w=30.0,
    body_h=22.0,
    body_d=28.0,

    // Small rear shoulder (helps look like a real module)
    shoulder_w=32.0,
    shoulder_h=24.0,
    shoulder_d=3.0,

    // Fuse drawer bump (front protrusion)
    fuse_w=18.0,
    fuse_h=10.0,
    fuse_d=6.0,

    // Mounting holes (M3 clearance)
    hole_d=3.2,
    hole_x=(36.0/2 - 5.0),
    hole_y=(27.0/2 - 5.0),

    // IEC C14 socket opening (front)
    sock_w=22.0,
    sock_h=16.0,
    sock_r=2.0,

    // Fuse window opening (front, above socket)
    fuse_win_w=16.0,
    fuse_win_h=6.0,
    fuse_win_r=1.2,

    // Rear terminal bumps (visual)
    term_w=6.0,
    term_h=4.0,
    term_d=6.0,
    term_pitch=8.0
){
    eps = 0.25;
    overlap = 0.8; // positive overlap to guarantee watertight unions

    // Z layout (front face of plate at z=0; positive z goes "back")
    plate_center_z    = plate_t/2;
    shoulder_center_z = plate_t + shoulder_d/2 - overlap;
    body_center_z     = plate_t + shoulder_d + body_d/2 - overlap;

    body_back_z       = body_center_z + body_d/2;
    term_center_z     = body_back_z + term_d/2 - overlap;

    // Feature positions on face
    sock_y     = -plate_h*0.12;
    fuse_y     =  plate_h*0.22;
    fuse_win_y =  fuse_y;

    // Make the faceplate slightly rounded so it doesn't look like a plain rectangle
    plate_r = 1.2;

    difference() {
        union() {
            // Faceplate (rounded)
            translate([0,0,plate_center_z])
                linear_extrude(height=plate_t, center=true)
                    rounded_rect_2d(plate_w, plate_h, plate_r);

            // Rear shoulder (connected)
            translate([0,0,shoulder_center_z])
                cube([shoulder_w, shoulder_h, shoulder_d], center=true);

            // Main rear body (connected)
            translate([0,0,body_center_z])
                cube([body_w, body_h, body_d], center=true);

            // Fuse drawer bump on front (upper area), connected to plate with overlap
            // Centered so its front is near z=0 and it overlaps into the plate.
            fuse_center_z = fuse_d/2 - overlap;
            translate([0, fuse_y, fuse_center_z])
                cube([fuse_w, fuse_h, fuse_d], center=true);

            // Small "lip" around the IEC opening (a shallow bezel) to add recognizable detail
            bezel_t = 0.9;
            bezel_w = sock_w + 3.0;
            bezel_h = sock_h + 3.0;
            bezel_center_z = plate_t - bezel_t/2; // sits on the front face region, still connected
            translate([0, sock_y, bezel_center_z])
                linear_extrude(height=bezel_t, center=true)
                    rounded_rect_2d(bezel_w, bezel_h, sock_r+0.8);

            // Rear terminal bumps (3), attached to back of body with overlap
            for (i=[-1,0,1]) {
                translate([i*term_pitch, -body_h*0.25, term_center_z])
                    cube([term_w, term_h, term_d], center=true);
            }
        }

        // Mounting holes through faceplate (ensure they fully cut)
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*hole_x, sy*hole_y, -eps])
                cylinder(d=hole_d, h=plate_t + 2*eps, center=false);
        }

        // IEC C14 socket opening through plate (lower area)
        translate([0, sock_y, -eps])
            linear_extrude(height=plate_t + 2*eps)
                rounded_rect_2d(sock_w, sock_h, sock_r);

        // Add two small keying notches inside the IEC opening (visual detail)
        notch_w = 3.0;
        notch_h = 2.2;
        notch_x = sock_w*0.28;
        translate([0, sock_y, -eps])
            linear_extrude(height=plate_t + 2*eps)
                union() {
                    translate([ notch_x,  sock_h/2 - notch_h/2]) square([notch_w, notch_h], center=true);
                    translate([-notch_x,  sock_h/2 - notch_h/2]) square([notch_w, notch_h], center=true);
                }

        // Fuse window opening through plate (upper area)
        translate([0, fuse_win_y, -eps])
            linear_extrude(height=plate_t + 2*eps)
                rounded_rect_2d(fuse_win_w, fuse_win_h, fuse_win_r);

        // Shallow recess in the fuse bump front face to suggest drawer outline (doesn't detach)
        // Cut only into the bump depth, starting at z=0.
        translate([0, fuse_win_y, -eps])
            linear_extrude(height=fuse_d + 2*eps)
                rounded_rect_2d(fuse_w-3.0, fuse_h-2.0, 1.0);

        // Add a shallow "step" recess around the fuse window on the plate for more definition
        step_t = 0.8;
        translate([0, fuse_win_y, plate_t - step_t - eps])
            linear_extrude(height=step_t + 2*eps)
                rounded_rect_2d(fuse_win_w+2.2, fuse_win_h+2.2, fuse_win_r+0.6);
    }
}

// Render
iec_fused_inlet_old();
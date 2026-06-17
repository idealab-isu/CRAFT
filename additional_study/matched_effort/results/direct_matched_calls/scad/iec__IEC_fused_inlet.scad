$fn=96;

// IEC fused inlet module (JR-101-1F style) overall faceplate 36 x 27 mm
// Parametric approximation suitable for panel cutout visualization / enclosure design.

module iec_fused_inlet_JR101_1F(
    face_w=36.0,
    face_h=27.0,
    face_t=2.6,

    body_w=30.0,
    body_h=22.0,
    body_d=26.0,

    flange_r=2.0,

    // Panel cutout (typical for 36x27 fused inlet modules; adjust to your datasheet)
    cutout_w=28.0,
    cutout_h=20.0,

    // Mounting holes on faceplate
    hole_d=3.2,
    hole_x= (36.0/2 - 5.0),   // from center
    hole_y= (27.0/2 - 5.0),   // from center

    // Front features
    fuse_window_w=12.0,
    fuse_window_h=6.0,
    fuse_window_y= (27.0/2 - 7.5),

    switch_window_w=12.0,
    switch_window_h=8.0,
    switch_window_y= 0.0,

    // IEC C14 opening (approx)
    iec_w=22.0,
    iec_h=16.0,
    iec_y= -(27.0/2 - 9.0),

    // Lip around IEC opening
    iec_lip=1.2,
    iec_depth=2.0
){
    difference() {
        union() {
            // Faceplate with rounded corners
            linear_extrude(height=face_t)
                offset(r=flange_r)
                    square([face_w-2*flange_r, face_h-2*flange_r], center=true);

            // Rear body (goes into enclosure)
            translate([0,0,-body_d])
                linear_extrude(height=body_d)
                    offset(r=1.0)
                        square([body_w-2.0, body_h-2.0], center=true);

            // Small front bezel around IEC opening (raised lip)
            translate([0, iec_y, 0])
                linear_extrude(height=iec_depth)
                    offset(r=1.0)
                        square([iec_w+2*iec_lip, iec_h+2*iec_lip], center=true);
        }

        // Mounting holes
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*hole_x, sy*hole_y, -1])
                cylinder(d=hole_d, h=face_t+2);

        // IEC C14 opening through faceplate
        translate([0, iec_y, -1])
            linear_extrude(height=face_t+2)
                offset(r=1.0)
                    square([iec_w, iec_h], center=true);

        // Fuse drawer window (front)
        translate([0, fuse_window_y, -1])
            linear_extrude(height=face_t+2)
                offset(r=0.8)
                    square([fuse_window_w, fuse_window_h], center=true);

        // Switch window (front) - many JR-101-1F variants include a rocker
        translate([0, switch_window_y, -1])
            linear_extrude(height=face_t+2)
                offset(r=0.8)
                    square([switch_window_w, switch_window_h], center=true);

        // Panel cutout guide (rear body clearance) - subtract only from rear body region
        // This represents the required rectangular cutout in the panel.
        translate([0,0,-body_d-1])
            linear_extrude(height=body_d+2)
                square([cutout_w, cutout_h], center=true);
    }
}

// Render
iec_fused_inlet_JR101_1F();
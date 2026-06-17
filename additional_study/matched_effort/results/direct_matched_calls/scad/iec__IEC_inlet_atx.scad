$fn=96;

// IEC C14 (ATX-style) inlet module outline (approximate) for panel cutout / mockup
// Overall faceplate: 40 x 27 mm
// Body: recessed behind faceplate
// Flange holes: 2x M3 clearance (3.2mm) typical, centered vertically
// NOTE: Dimensions are approximate; adjust to your specific inlet datasheet.

module iec_inlet_module(
    face_w=40.0,
    face_h=27.0,
    face_t=2.5,

    body_w=30.0,
    body_h=22.0,
    body_d=18.0,

    // Panel cutout (typical IEC C14 snap-in style is ~27.5 x 20.0,
    // but flanged screw-mount modules vary; keep as a reasonable ATX-ish cutout)
    cutout_w=28.0,
    cutout_h=20.0,

    // Screw holes on flange
    hole_d=3.2,
    hole_x=16.0,   // half spacing from center (i.e., spacing = 32mm)
    hole_y=0.0,    // centered vertically

    // Cosmetic inlet opening on front
    inlet_w=26.0,
    inlet_h=18.0,
    inlet_depth=6.0,

    // Corner rounding for faceplate
    face_r=2.0
){
    difference() {
        // Faceplate with rounded corners
        linear_extrude(height=face_t)
            offset(r=face_r)
                square([face_w-2*face_r, face_h-2*face_r], center=true);

        // Screw holes through faceplate
        for (sx=[-1,1]) {
            translate([sx*hole_x, hole_y, -0.1])
                cylinder(d=hole_d, h=face_t+0.2);
        }

        // Front inlet opening (cosmetic recess)
        translate([0,0, -0.1])
            linear_extrude(height=inlet_depth+0.2)
                square([inlet_w, inlet_h], center=true);
    }

    // Rear body (the part that goes through the panel)
    // Positioned behind the faceplate
    translate([0,0, -body_d])
        difference() {
            // Main body block
            translate([0,0, body_d/2])
                cube([body_w, body_h, body_d], center=true);

            // Through cutout void (panel cutout / internal clearance)
            translate([0,0, body_d/2])
                cube([cutout_w, cutout_h, body_d+0.5], center=true);

            // Slight lead-in chamfer-ish relief at front of body
            translate([0,0, body_d-2])
                linear_extrude(height=2.5)
                    offset(delta=1.0)
                        square([cutout_w, cutout_h], center=true);
        }
}

// Render
iec_inlet_module();
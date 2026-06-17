$fn=96;

// IEC power inlet module (approx. RS 811-7193 style)
// Overall faceplate: 40 x 32 mm
// Includes: faceplate, recessed body, flange screw holes, and IEC C14-ish cutout opening.

module iec_inlet_module(
    plate_w=40.0,
    plate_h=32.0,
    plate_t=3.0,

    body_w=30.0,
    body_h=22.0,
    body_d=24.0,          // depth behind plate

    recess=1.2,           // front recess depth for the opening
    opening_w=27.5,       // IEC opening (approx)
    opening_h=19.5,
    opening_r=2.0,

    // flange screw holes (approx positions)
    hole_d=3.2,
    hole_x=16.0,          // from center to hole in X
    hole_y=11.0           // from center to hole in Y
){
    difference() {
        union() {
            // Faceplate
            translate([-plate_w/2, -plate_h/2, 0])
                cube([plate_w, plate_h, plate_t], center=false);

            // Rear body (centered)
            translate([-body_w/2, -body_h/2, -body_d])
                cube([body_w, body_h, body_d], center=false);
        }

        // Main opening through plate + a bit into body
        translate([0,0,-0.01])
            rounded_rect_hole(opening_w, opening_h, opening_r, plate_t + recess + 0.02);

        // Slightly larger relief behind opening (helps resemble molded inlet cavity)
        translate([0,0,-(recess+0.01)])
            rounded_rect_hole(opening_w+2.0, opening_h+2.0, opening_r+1.0, body_d + recess + 0.02);

        // Screw holes through plate
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*hole_x, sy*hole_y, -0.5])
                cylinder(d=hole_d, h=plate_t+1.0);
        }
    }
}

// Helper: rounded rectangle "hole" extruded along Z
module rounded_rect_hole(w,h,r,depth){
    r2 = min(r, min(w,h)/2);
    linear_extrude(height=depth)
        offset(r=r2)
            square([w-2*r2, h-2*r2], center=true);
}

iec_inlet_module();
$fn=96;

// IEC 60320 C14-style lugless inlet (approximate), panel-mount body + flange + pins.
// "Lugless" interpreted as no solder lugs; uses straight blade pins.

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module iec_c14_lugless(
    body_w=27.5,
    body_h=20.5,
    body_d=28.0,

    flange_w=33.0,
    flange_h=25.0,
    flange_t=3.0,
    flange_r=2.0,

    cutout_w=27.0,
    cutout_h=20.0,
    cutout_r=2.0,

    face_recess=1.2,          // shallow recess on face
    face_recess_margin=2.0,

    screw_hole_d=3.2,
    screw_hole_x=12.0,        // from center
    screw_hole_y=0.0,

    pin_w=1.6,
    pin_t=0.8,
    pin_len=10.0,
    pin_pitch_x=8.0,          // L-N spacing
    pin_pitch_y=6.5           // Earth offset
){
    difference(){
        union(){
            // Main body (behind panel)
            translate([0,0,-body_d/2])
                cube([body_w, body_h, body_d], center=true);

            // Front flange (panel side)
            translate([0,0,flange_t/2])
                linear_extrude(height=flange_t, center=true)
                    rounded_rect_2d(flange_w, flange_h, flange_r);

            // Pins (lugless blades)
            // Coordinate system: +Z is outward from flange; pins extend backward (-Z)
            for (sx=[-1,1]){
                translate([sx*pin_pitch_x/2, -pin_pitch_y/2, -body_d + pin_len/2])
                    cube([pin_w, pin_t, pin_len], center=true);
            }
            // Earth pin (centered in X, above)
            translate([0, pin_pitch_y/2, -body_d + pin_len/2])
                cube([pin_w, pin_t, pin_len], center=true);
        }

        // Panel cutout through flange and a bit into body
        translate([0,0,0])
            linear_extrude(height=flange_t + 2, center=true)
                rounded_rect_2d(cutout_w, cutout_h, cutout_r);

        // Face recess (gives typical IEC inlet lip)
        translate([0,0,flange_t/2 - face_recess/2])
            linear_extrude(height=face_recess, center=true)
                rounded_rect_2d(cutout_w - face_recess_margin,
                                cutout_h - face_recess_margin,
                                max(0, cutout_r-0.5));

        // Screw holes in flange (optional; many lugless snap-in exist, but include holes)
        for (sx=[-1,1]){
            translate([sx*screw_hole_x, screw_hole_y, 0])
                cylinder(d=screw_hole_d, h=flange_t+4, center=true);
        }
    }
}

iec_c14_lugless();
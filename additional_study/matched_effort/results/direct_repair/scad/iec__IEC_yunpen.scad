$fn=96;

// IEC C14 filtered inlet module (approximate external model)
// Overall faceplate: 40 x 29 mm
// Body: rectangular can behind plate
// Cutout: typical ~27.5 x 20.0 mm (for reference; not used unless you enable preview helpers)

module iec_inlet_filtered(
    plate_w=40.0,
    plate_h=29.0,
    plate_t=2.5,

    corner_r=2.0,

    body_w=30.0,
    body_h=22.0,
    body_d=28.0,     // depth behind plate

    flange_lip=0.8,  // small raised rim on front
    flange_inset=1.2,

    // IEC C14 opening (front)
    opening_w=27.0,
    opening_h=19.0,
    opening_r=2.0,
    opening_depth=plate_t + 1.0,

    // Pin holes (approx)
    pin_d=4.8,
    pin_spacing_x=10.0,
    pin_spacing_y=8.0,
    pin_depth=body_d + plate_t + 2.0,

    // Ground pin (top center)
    gnd_d=4.8,
    gnd_offset_y=7.5
){
    difference() {
        union() {
            // Faceplate with rounded corners
            linear_extrude(height=plate_t)
                rounded_rect_2d(plate_w, plate_h, corner_r);

            // Small front rim (subtle)
            translate([0,0,plate_t])
                linear_extrude(height=flange_lip)
                    difference() {
                        rounded_rect_2d(plate_w, plate_h, corner_r);
                        rounded_rect_2d(plate_w-2*flange_inset, plate_h-2*flange_inset, max(0,corner_r-flange_inset));
                    }

            // Main body can behind plate
            translate([0,0,-body_d])
                linear_extrude(height=body_d)
                    rounded_rect_2d(body_w, body_h, 1.5);

            // Small side bumps (suggestive of latch features)
            for (sx=[-1,1]) {
                translate([sx*(body_w/2 + 1.2), 0, -body_d*0.55])
                    rotate([0,90,0])
                        cylinder(d=3.0, h=2.4, center=true);
            }

            // Rear strain relief / filter bulge (approx)
            translate([0,0,-body_d-6])
                hull() {
                    translate([0,0,0]) cylinder(d=18, h=6);
                    translate([0,0,2]) cylinder(d=22, h=4);
                }
        }

        // IEC opening on front
        translate([0,0,-0.01])
            linear_extrude(height=opening_depth+0.02)
                rounded_rect_2d(opening_w, opening_h, opening_r);

        // Pin holes (rear-facing)
        // Two lower pins
        for (sx=[-1,1]) {
            translate([sx*pin_spacing_x/2, -pin_spacing_y/2, plate_t+0.5])
                rotate([180,0,0])
                    cylinder(d=pin_d, h=pin_depth);
        }
        // Ground pin (upper center)
        translate([0, gnd_offset_y, plate_t+0.5])
            rotate([180,0,0])
                cylinder(d=gnd_d, h=pin_depth);

        // Slight recess around opening (cosmetic)
        translate([0,0,plate_t-0.8])
            linear_extrude(height=0.9)
                difference() {
                    rounded_rect_2d(opening_w+3.0, opening_h+3.0, opening_r+1.0);
                    rounded_rect_2d(opening_w, opening_h, opening_r);
                }
    }
}

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull() {
        for (x=[-w/2 + r2, w/2 - r2])
            for (y=[-h/2 + r2, h/2 - r2])
                translate([x,y]) circle(r=r2);
    }
}

// Render
iec_inlet_filtered();
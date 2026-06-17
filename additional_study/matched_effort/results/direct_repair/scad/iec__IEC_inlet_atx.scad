$fn=96;

// IEC C14 inlet module (panel-mount style) nominal outer size 40 x 27 mm
// This is a simplified, renderable model suitable for enclosure layout.
// Units: mm

module iec_c14_inlet_module(
    outer_w=40.0,
    outer_h=27.0,
    flange_t=3.0,
    body_depth=22.0,
    body_w=30.0,
    body_h=22.0,
    corner_r=2.0,

    // Panel cutout (typical-ish for C14): ~27.5 x 20.0
    cutout_w=27.5,
    cutout_h=20.0,

    // Screw ears / holes (common on fused/switch modules; kept generic)
    ear_w=6.0,
    ear_h=10.0,
    hole_d=3.2,
    hole_offset_x=16.0,   // from center to hole along X
    hole_offset_y=0.0
){
    difference() {
        union() {
            // Front flange plate with rounded corners
            linear_extrude(height=flange_t)
                rounded_rect(outer_w, outer_h, corner_r);

            // Rear body (rectangular) centered behind flange
            translate([0,0,flange_t])
                linear_extrude(height=body_depth)
                    rounded_rect(body_w, body_h, 1.5);

            // Optional small ears integrated into flange (left/right)
            // (kept subtle; holes still provided)
            translate([0,0,0])
                linear_extrude(height=flange_t)
                    union() {
                        translate([ outer_w/2 - ear_w/2, 0, 0]) rounded_rect(ear_w, ear_h, 1.0);
                        translate([-outer_w/2 + ear_w/2, 0, 0]) rounded_rect(ear_w, ear_h, 1.0);
                    }
        }

        // Panel cutout opening through flange and into body
        translate([0,0,-0.1])
            linear_extrude(height=flange_t + body_depth + 0.2)
                rounded_rect(cutout_w, cutout_h, 1.0);

        // Screw holes through flange
        for (sx = [-1, 1]) {
            translate([sx*hole_offset_x, hole_offset_y, -0.2])
                cylinder(d=hole_d, h=flange_t + 0.4);
        }

        // Slight rear relief to suggest connector cavity (optional)
        translate([0,0,flange_t + 2])
            linear_extrude(height=body_depth - 4)
                rounded_rect(body_w-4, body_h-4, 1.0);
    }
}

module rounded_rect(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull() {
        for (x=[-w/2 + r2, w/2 - r2])
            for (y=[-h/2 + r2, h/2 - r2])
                translate([x,y]) circle(r=r2);
    }
}

// Render
iec_c14_inlet_module();
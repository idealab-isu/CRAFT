$fn=96;

// IEC C14 filtered inlet module (approximate external model)
// Overall faceplate: 40 x 29 mm
// Body: rectangular can behind plate
// Cutout: typical ~27.5 x 20.0 mm (for reference)
// Mount holes: 2x M3-ish on 33 mm pitch (common), centered vertically

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module iec_inlet_filtered_40x29(
    plate_w=40,
    plate_h=29,
    plate_t=3.0,
    corner_r=2.0,

    // body behind plate
    body_w=30.0,
    body_h=22.0,
    body_d=28.0,
    body_corner_r=1.2,

    // front recess / bezel detail
    bezel_inset=1.0,
    bezel_depth=1.2,
    bezel_r=1.5,

    // IEC opening (front)
    opening_w=27.5,
    opening_h=20.0,
    opening_depth=plate_t + 0.8,

    // mounting holes
    hole_pitch=33.0,
    hole_d=3.4,
    hole_head_d=6.6,
    hole_csk_depth=1.2,

    // small flange lip around opening
    lip=1.2
){
    difference(){
        union(){
            // Faceplate
            linear_extrude(height=plate_t)
                rounded_rect_2d(plate_w, plate_h, corner_r);

            // Rear body (centered)
            translate([0,0,-body_d])
                linear_extrude(height=body_d)
                    rounded_rect_2d(body_w, body_h, body_corner_r);

            // Slight front bezel ridge around opening
            translate([0,0,plate_t - bezel_depth])
                linear_extrude(height=bezel_depth)
                    rounded_rect_2d(opening_w + 2*lip, opening_h + 2*lip, bezel_r);
        }

        // IEC opening cut through plate (and a bit into body)
        translate([0,0,-0.2])
            linear_extrude(height=opening_depth + 0.4)
                rounded_rect_2d(opening_w, opening_h, 1.2);

        // Mounting through-holes + shallow counterbore on front
        for(x=[-hole_pitch/2, hole_pitch/2]){
            // through
            translate([x,0,-body_d-0.5])
                cylinder(d=hole_d, h=body_d + plate_t + 1.0);

            // counterbore/countersink-ish (simple counterbore)
            translate([x,0,plate_t - hole_csk_depth])
                cylinder(d=hole_head_d, h=hole_csk_depth + 0.01);
        }

        // Slight rear cavity to suggest filter can hollow (visual only)
        translate([0,0,-body_d+2.0])
            linear_extrude(height=body_d-4.0)
                rounded_rect_2d(body_w-4.0, body_h-4.0, max(0.6, body_corner_r-0.4));
    }
}

// Render
iec_inlet_filtered_40x29();
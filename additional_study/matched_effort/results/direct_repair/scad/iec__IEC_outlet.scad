$fn=96;

// IEC power inlet module (approximation of RS 811-7193 style)
// Overall faceplate: 40 x 32 mm
// Includes: faceplate, recessed body, flange holes, and IEC C14-ish opening.

module iec_inlet_module(
    plate_w=40.0,
    plate_h=32.0,
    plate_t=3.0,

    body_w=30.0,
    body_h=22.0,
    body_d=26.0,          // depth behind plate

    recess=1.2,           // front recess depth for opening lip

    // IEC opening (front cutout through plate + into body)
    cut_w=27.5,
    cut_h=19.5,
    cut_r=2.0,

    // flange mounting holes
    hole_d=3.4,
    hole_x=16.0,          // half spacing in X from center
    hole_y=11.0,          // half spacing in Y from center
    hole_csk_d=6.8,
    hole_csk_h=1.2,

    // small chamfer on plate edges
    edge_chamfer=0.6
){
    difference() {
        union() {
            // Faceplate with slight chamfer
            if (edge_chamfer > 0) {
                minkowski() {
                    translate([0,0,edge_chamfer])
                        cube([plate_w-2*edge_chamfer, plate_h-2*edge_chamfer, plate_t-2*edge_chamfer], center=true);
                    cylinder(h=edge_chamfer, r=edge_chamfer, center=false);
                }
            } else {
                cube([plate_w, plate_h, plate_t], center=true);
            }

            // Body behind plate
            translate([0,0,-(plate_t/2 + body_d/2)])
                cube([body_w, body_h, body_d], center=true);

            // Small front lip around opening (visual detail)
            translate([0,0,plate_t/2 - recess/2])
                difference() {
                    cube([cut_w+4.0, cut_h+4.0, recess], center=true);
                    rounded_rect_prism(cut_w+1.0, cut_h+1.0, recess+0.2, cut_r+0.8);
                }
        }

        // IEC opening cut through plate and into body
        translate([0,0,0])
            rounded_rect_prism(cut_w, cut_h, plate_t + body_d + 2.0, cut_r);

        // Mounting holes (through plate)
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*hole_x, sy*hole_y, 0])
                cylinder(h=plate_t + 2.0, d=hole_d, center=true);

            // Countersink / counterbore on front
            translate([sx*hole_x, sy*hole_y, plate_t/2 - hole_csk_h/2])
                cylinder(h=hole_csk_h + 0.01, d=hole_csk_d, center=true);
        }

        // Slight back relief around opening (helps resemble molded body)
        translate([0,0,-(plate_t/2 + body_d/2)])
            rounded_rect_prism(cut_w+2.0, cut_h+2.0, body_d*0.65, cut_r+0.8);
    }
}

module rounded_rect_prism(w,h,t,r){
    r2 = min(r, min(w,h)/2);
    linear_extrude(height=t, center=true)
        offset(r=r2)
            square([w-2*r2, h-2*r2], center=true);
}

// Render
iec_inlet_module();
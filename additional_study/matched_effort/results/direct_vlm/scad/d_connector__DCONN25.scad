$fn = 96;

// Simplified D-sub connector (one connected solid)
module d_connector(
    // Flange
    flange_w = 40,
    flange_h = 16,
    flange_t = 2.5,
    corner_r = 2.0,
    hole_d = 3.2,
    hole_spacing = 32,

    // Shell (D-shaped)
    body_w = 30,
    body_h = 12,
    body_d = 10,
    shell_wall = 1.5,
    shell_front_bevel = 1.2,

    // Pins
    pin_rows = 2,
    pins_per_row = 5,
    pin_pitch = 2.54,
    row_pitch = 2.84,
    pin_d = 1.0,
    pin_len = 6,

    // Rear block
    rear_d = 6,
    rear_r = 1.5
) {
    eps = 0.02;
    overlap = 0.6; // ensures unions are watertight

    // Rounded rectangle prism
    module rounded_rect_prism(w,h,d,r){
        r2 = min(r, min(w,h)/2);
        linear_extrude(height=d, convexity=10)
            offset(r=r2)
                square([w-2*r2, h-2*r2], center=true);
    }

    // 2D D-profile (flat left, rounded right)
    module d_profile(w,h){
        // Build as union of a rectangle (flat side) and a semicircle (rounded side)
        // Total width = w, total height = h
        union() {
            // Flat portion: from x = -w/2 to x = +w/2 - h/2
            translate([-(h/2)/2, 0])
                square([w - h/2, h], center=true);

            // Rounded portion: semicircle on the right
            translate([w/2 - h/2, 0])
                intersection() {
                    circle(r=h/2);
                    translate([h/4, 0]) square([h/2, h], center=true); // keep right half
                }
        }
    }

    module d_prism(w,h,d){
        linear_extrude(height=d, convexity=10)
            d_profile(w,h);
    }

    // Pin layout extents
    pin_block_w = (pins_per_row-1)*pin_pitch + pin_pitch/2; // allow stagger
    pin_block_h = (pin_rows-1)*row_pitch;

    // Z references (front face at z=0)
    z_flange0 = 0;
    z_flange1 = z_flange0 + flange_t;

    z_shell0  = z_flange1 - overlap;          // overlap into flange
    z_shell1  = z_shell0 + body_d;

    z_rear0   = z_shell1 - overlap;           // overlap into shell
    z_rear1   = z_rear0 + rear_d;

    // Pins protrude from front (negative z) and overlap into flange for connectivity
    z_pin0 = -pin_len;
    z_pin1 = z_flange0 + overlap;

    union() {
        // Flange with mounting holes (holes are subtracted but solid remains connected)
        difference() {
            translate([0,0,z_flange0])
                rounded_rect_prism(flange_w, flange_h, flange_t, corner_r);

            for (sx = [-1, 1]) {
                translate([sx*hole_spacing/2, 0, z_flange0 - eps])
                    cylinder(d=hole_d, h=flange_t + 2*eps);
            }
        }

        // D-shaped shell behind flange with cavity and front bevel
        translate([0,0,z_shell0])
        difference() {
            // Outer shell
            d_prism(body_w, body_h, body_d);

            // Inner cavity (leave wall thickness)
            translate([0,0,shell_wall])
                d_prism(body_w - 2*shell_wall, body_h - 2*shell_wall, body_d - shell_wall - eps);

            // Front bevel (chamfer-like) cut
            // Cut a slightly shrunken D-profile for the first shell_front_bevel depth
            translate([0,0,-eps])
                linear_extrude(height=shell_front_bevel + 2*eps, convexity=10)
                    offset(delta=-shell_front_bevel*0.55)
                        d_profile(body_w, body_h);
        }

        // Pins (connected by overlapping into flange)
        for (r = [0:pin_rows-1]) {
            for (c = [0:pins_per_row-1]) {
                x = (c*pin_pitch - (pins_per_row-1)*pin_pitch/2) + (r%2)*pin_pitch/2;
                y = (r*row_pitch - pin_block_h/2);
                translate([x, y, z_pin0])
                    cylinder(d=pin_d, h=(z_pin1 - z_pin0));
            }
        }

        // Rear strain relief block (connected by overlap into shell)
        translate([0,0,z_rear0])
            rounded_rect_prism(body_w*0.75, body_h*0.7, rear_d, rear_r);
    }
}

d_connector();
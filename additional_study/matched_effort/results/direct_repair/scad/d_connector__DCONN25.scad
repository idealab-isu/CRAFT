$fn = 96;

// D-sub style connector body (simplified)
module d_connector(
    body_w = 30,
    body_h = 12,
    body_d = 10,
    flange_w = 40,
    flange_h = 16,
    flange_t = 2.5,
    corner_r = 2.0,
    hole_d = 3.2,
    hole_offset_x = 16,
    hole_offset_y = 0,
    pin_rows = 2,
    pins_per_row = 5,
    pin_pitch_x = 2.77,
    pin_pitch_y = 2.84,
    pin_d = 1.2,
    pin_len = 6,
    pin_setback = 1.0
){
    // 2D D-shape: rectangle + semicircle on right
    module d2d(w,h){
        union(){
            translate([-w/2, -h/2]) square([w/2, h], center=false);
            translate([0,0]) circle(d=h);
        }
    }

    // Rounded rectangle 2D
    module rrect2d(w,h,r){
        r = min(r, min(w,h)/2);
        offset(r=r) offset(delta=-r) square([w,h], center=true);
    }

    // Main body
    module body(){
        linear_extrude(height=body_d)
            d2d(body_w, body_h);
    }

    // Flange plate with mounting holes
    module flange(){
        difference(){
            linear_extrude(height=flange_t)
                rrect2d(flange_w, flange_h, corner_r);

            // Mounting holes
            for (sx=[-1,1]){
                translate([sx*hole_offset_x, hole_offset_y, -0.1])
                    cylinder(d=hole_d, h=flange_t+0.2);
            }

            // Clearance for body outline
            translate([0,0,-0.1])
                linear_extrude(height=flange_t+0.2)
                    offset(delta=0.6) d2d(body_w, body_h);
        }
    }

    // Pins
    module pins(){
        // Center pins within D outline
        total_w = (pins_per_row-1)*pin_pitch_x;
        total_h = (pin_rows-1)*pin_pitch_y;

        for (r=[0:pin_rows-1]){
            y = (r - (pin_rows-1)/2)*pin_pitch_y;
            // Stagger second row slightly (typical D-sub)
            x_stagger = (r%2==1) ? pin_pitch_x/2 : 0;

            for (c=[0:pins_per_row-1]){
                x = (c - (pins_per_row-1)/2)*pin_pitch_x + x_stagger;
                translate([x, y, -pin_len + pin_setback])
                    cylinder(d=pin_d, h=pin_len);
            }
        }
    }

    // Assemble
    union(){
        // Flange at front (z=0..flange_t)
        flange();

        // Body behind flange
        translate([0,0,flange_t])
            body();

        // Pins protruding from front
        pins();
    }
}

// Render
d_connector();
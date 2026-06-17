$fn = 96;

// D-sub style connector body (generic "D connector")
module d_connector(
    body_len = 30,
    body_height = 12,
    body_depth = 10,
    flange_thickness = 2.5,
    flange_margin = 4,
    corner_r = 1.2,
    d_flat_ratio = 0.72,          // 1.0 = full oval, smaller = flatter top/bottom
    shell_inset = 1.2,
    shell_thickness = 1.6,
    pin_rows = 2,
    pins_per_row = 5,
    pin_d = 1.2,
    pin_len = 6,
    pin_pitch = 2.77,
    row_pitch = 2.84,
    pin_offset_z = 0.0,
    jack_screw_d = 3.2,
    jack_screw_head_d = 6.2,
    jack_screw_head_h = 2.2,
    jack_screw_offset_x = 12.5,
    jack_screw_offset_z = 0
){
    // Helper: rounded rectangle in 2D
    module rounded_rect_2d(w,h,r){
        r2 = min(r, min(w,h)/2);
        offset(r=r2) offset(delta=-r2) square([w,h], center=true);
    }

    // Helper: D-like profile (rounded rectangle squashed in Y)
    module d_profile_2d(w,h,r,flat_ratio){
        // Create an oval-ish rounded rectangle then scale Y to flatten
        scale([1, flat_ratio])
            rounded_rect_2d(w, h/flat_ratio, r);
    }

    // Main body: D-shaped extrusion
    module body(){
        linear_extrude(height=body_depth, center=false, convexity=10)
            d_profile_2d(body_len, body_height, corner_r, d_flat_ratio);
    }

    // Flange: larger plate behind body
    module flange(){
        w = body_len + 2*flange_margin;
        h = body_height + 2*flange_margin;
        linear_extrude(height=flange_thickness, center=false, convexity=10)
            rounded_rect_2d(w, h, corner_r);
    }

    // Shell recess on front face
    module shell_cut(){
        w = body_len - 2*shell_inset;
        h = body_height - 2*shell_inset;
        linear_extrude(height=body_depth + 0.2, center=false, convexity=10)
            d_profile_2d(w, h, max(0.6, corner_r-0.4), d_flat_ratio);
    }

    // Pins
    module pins(){
        // Center pins in X, rows in Z (height axis), extrude along Y (depth axis)
        // Coordinate system: X left-right, Z up-down, Y depth (front to back)
        // We'll place pins protruding from front (negative Y)
        total_w = (pins_per_row-1)*pin_pitch;
        x0 = -total_w/2;

        for (r = [0:pin_rows-1]){
            // Stagger rows slightly like typical D-sub (optional)
            x_shift = (r%2==1) ? pin_pitch/2 : 0;
            z = ( (pin_rows-1)/2 - r )*row_pitch + pin_offset_z;

            for (i = [0:pins_per_row-1]){
                x = x0 + i*pin_pitch + x_shift;
                translate([x, -pin_len, z])
                    cylinder(d=pin_d, h=pin_len, center=false);
            }
        }
    }

    // Jack screw posts (simple cylinders with head)
    module jack_screws(){
        for (sx = [-1, 1]){
            translate([sx*jack_screw_offset_x, 0, jack_screw_offset_z])
            union(){
                // Through hole (will be subtracted from flange/body)
                // Head boss (added)
                translate([0, -jack_screw_head_h, 0])
                    rotate([90,0,0])
                        cylinder(d=jack_screw_head_d, h=jack_screw_head_h, center=false);
            }
        }
    }

    // Jack screw holes (subtractive)
    module jack_screw_holes(){
        for (sx = [-1, 1]){
            translate([sx*jack_screw_offset_x, 0.01, jack_screw_offset_z])
                rotate([90,0,0])
                    cylinder(d=jack_screw_d, h=flange_thickness + body_depth + 2, center=false);
        }
    }

    // Assemble: flange at back, body in front of flange, pins protrude from front
    // Place flange centered at origin in X/Z, spanning Y from 0..flange_thickness
    // Body spans Y from flange_thickness..flange_thickness+body_depth
    difference(){
        union(){
            // Flange
            translate([0, 0, 0])
                rotate([90,0,0])  // extrude along Y
                    flange();

            // Body
            translate([0, flange_thickness, 0])
                rotate([90,0,0])
                    body();

            // Jack screw head bosses
            translate([0, flange_thickness, 0])
                jack_screws();

            // Pins (front side)
            translate([0, flange_thickness, 0])
                pins();
        }

        // Shell recess from front face into body
        translate([0, flange_thickness + 0.2, 0])
            rotate([90,0,0])
                shell_cut();

        // Jack screw holes through flange/body
        translate([0, 0, 0])
            jack_screw_holes();
    }
}

// Render
d_connector();
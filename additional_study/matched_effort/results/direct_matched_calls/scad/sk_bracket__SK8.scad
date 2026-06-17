$fn=96;

// Parameters
rod_d = 8.0;
height = 20.0;

// Bracket geometry
base_len = 40.0;
base_w   = 20.0;
base_th  = 6.0;

post_w   = 20.0;
post_th  = 10.0;

clamp_od = 18.0;          // outer diameter around rod
clamp_len = post_w;       // along X
slot_w   = 2.0;           // clamp slit width

bolt_d   = 5.0;           // clamp bolt clearance
bolt_head_d = 9.0;        // counterbore for socket head
bolt_head_h = 4.0;

mount_hole_d = 5.0;       // base mounting holes
mount_hole_x = 14.0;      // spacing from center along X
mount_hole_y = 6.0;       // offset from center along Y

module shaft_support_bracket() {
    difference() {
        union() {
            // Base plate
            translate([-base_len/2, -base_w/2, 0])
                cube([base_len, base_w, base_th]);

            // Upright post
            translate([-post_w/2, -post_th/2, base_th])
                cube([post_w, post_th, height - base_th]);

            // Clamp boss (cylinder along X)
            translate([0, 0, height/2])
                rotate([0, 90, 0])
                    cylinder(d=clamp_od, h=clamp_len, center=true);

            // Small gussets
            gus_h = height - base_th;
            gus_t = 6.0;
            for (sx = [-1, 1]) {
                translate([sx*(post_w/2 - gus_t), -post_th/2, base_th])
                    linear_extrude(height=post_th)
                        polygon(points=[
                            [0,0],
                            [gus_t,0],
                            [gus_t,gus_h],
                            [0,0]
                        ]);
            }
        }

        // Rod hole (through clamp boss along X)
        translate([0, 0, height/2])
            rotate([0, 90, 0])
                cylinder(d=rod_d + 0.4, h=clamp_len + 2, center=true);

        // Clamp slit (opens to front, along X)
        translate([-clamp_len/2 - 1, -slot_w/2, height/2])
            cube([clamp_len + 2, slot_w, clamp_od + 2], center=false);

        // Clamp bolt hole (through Y), with counterbore on +Y side
        translate([0, 0, height/2])
            rotate([90, 0, 0])
                cylinder(d=bolt_d, h=base_w + 40, center=true);

        translate([0, post_th/2 + 0.01, height/2])
            rotate([90, 0, 0])
                cylinder(d=bolt_head_d, h=bolt_head_h, center=false);

        // Base mounting holes (2x)
        for (sx = [-1, 1]) {
            translate([sx*mount_hole_x, 0, 0])
                cylinder(d=mount_hole_d, h=base_th + 1, center=false);
        }

        // Slight edge chamfer via subtracting a thin wedge (optional subtle)
        cham = 1.0;
        translate([-base_len/2 - 0.1, -base_w/2 - 0.1, base_th - cham])
            cube([base_len + 0.2, base_w + 0.2, cham + 0.2]);
    }
}

shaft_support_bracket();
$fn=96;

// Parameters
rod_d = 10.0;
height = 20.0;

clearance = 0.3;          // rod clearance
base_th = 6.0;            // base thickness
wall = 4.0;               // clamp wall thickness around bore
outer_d = rod_d + 2*(wall + clearance);

base_len = outer_d + 18.0;
base_w   = outer_d + 10.0;

slot_w = 2.2;             // clamp slit width
ear_extra = 6.0;          // extra width for bolt ears beyond outer diameter
ear_w = outer_d + 2*ear_extra;

bolt_d = 5.2;             // M5 clearance
bolt_head_d = 9.5;        // socket cap head clearance
bolt_head_h = 4.0;

mount_hole_d = 5.2;       // M5 mounting holes
mount_csk_d  = 10.0;      // counterbore diameter
mount_csk_h  = 3.0;       // counterbore depth

module clamp_body() {
    // Base plate
    translate([-base_len/2, -base_w/2, 0])
        cube([base_len, base_w, base_th], center=false);

    // Upright clamp block (with ears)
    translate([0, 0, base_th])
        linear_extrude(height=height)
            hull() {
                circle(d=outer_d);
                // ears for clamp bolt
                translate([0,  ear_w/2 - outer_d/2]) circle(d=outer_d*0.55);
                translate([0, -ear_w/2 + outer_d/2]) circle(d=outer_d*0.55);
            }
}

module bracket() {
    difference() {
        clamp_body();

        // Rod bore
        translate([0, 0, base_th + height/2])
            rotate([90,0,0])
                cylinder(d=rod_d + 2*clearance, h=ear_w + 2, center=true);

        // Clamp slit (front opening)
        translate([outer_d/2 - 0.01, 0, base_th])
            cube([outer_d, slot_w, height + 0.5], center=true);

        // Clamp bolt through ears (along Y)
        translate([0, 0, base_th + height*0.65])
            rotate([90,0,0])
                cylinder(d=bolt_d, h=ear_w + 4, center=true);

        // Counterbore for bolt head on +Y side
        translate([0, ear_w/2 - 0.01, base_th + height*0.65])
            rotate([90,0,0])
                cylinder(d=bolt_head_d, h=bolt_head_h, center=false);

        // Counterbore for nut/washer on -Y side (same as head)
        translate([0, -ear_w/2 - bolt_head_h + 0.01, base_th + height*0.65])
            rotate([90,0,0])
                cylinder(d=bolt_head_d, h=bolt_head_h, center=false);

        // Mounting holes in base (two holes along X)
        for (x = [-base_len*0.25, base_len*0.25]) {
            translate([x, 0, 0])
                cylinder(d=mount_hole_d, h=base_th + 0.5, center=false);

            // Counterbore from bottom
            translate([x, 0, 0])
                cylinder(d=mount_csk_d, h=mount_csk_h, center=false);
        }
    }
}

bracket();
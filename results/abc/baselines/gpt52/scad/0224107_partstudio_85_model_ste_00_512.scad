$fn=96;

outer_d = 28;
body_h = 22;

flange_d1 = 34;
flange_h1 = 3.2;

flange_d2 = 30;
flange_h2 = 2.2;

top_chamfer_h = 1.2;
bottom_chamfer_h = 1.2;

knurl_band_h = 5.2;
knurl_band_gap = 3.0;

knurl_depth = 1.2;
knurl_teeth = 48;

hex_flat = 12;
hex_clear = 0.25;
hex_h = body_h + flange_h1 + flange_h2 + 2;

module hex_prism(flat=12, h=10) {
    r = flat / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module knurl_ring(od=28, h=5, depth=1.0, teeth=48) {
    r0 = od/2;
    r1 = r0 + depth;
    union() {
        cylinder(h=h, r=r0, $fn=96);
        for (i = [0:teeth-1]) {
            rotate([0,0, i*360/teeth])
                translate([r0,0,0])
                    linear_extrude(height=h)
                        polygon(points=[
                            [0, -0.55],
                            [depth, 0],
                            [0, 0.55]
                        ]);
        }
    }
}

module body_outer() {
    total_h = body_h + flange_h1 + flange_h2;
    z0 = -total_h/2;

    union() {
        translate([0,0,z0])
            cylinder(h=flange_h1, d=flange_d1, $fn=128);

        translate([0,0,z0 + flange_h1])
            cylinder(h=flange_h2, d=flange_d2, $fn=128);

        translate([0,0,z0 + flange_h1 + flange_h2])
            cylinder(h=body_h, d=outer_d, $fn=128);

        translate([0,0,z0 + flange_h1 + flange_h2])
            cylinder(h=top_chamfer_h, d1=outer_d-2.0, d2=outer_d, $fn=128);

        translate([0,0,z0 + flange_h1 + flange_h2 + body_h - bottom_chamfer_h])
            cylinder(h=bottom_chamfer_h, d1=outer_d, d2=outer_d-2.0, $fn=128);
    }
}

module grip_bands() {
    total_h = body_h + flange_h1 + flange_h2;
    z0 = -total_h/2 + flange_h1 + flange_h2;

    z_band1 = z0 + 2.0;
    z_band2 = z_band1 + knurl_band_h + knurl_band_gap;

    union() {
        translate([0,0,z_band1])
            knurl_ring(od=outer_d, h=knurl_band_h, depth=knurl_depth, teeth=knurl_teeth);

        translate([0,0,z_band2])
            knurl_ring(od=outer_d, h=knurl_band_h, depth=knurl_depth, teeth=knurl_teeth);
    }
}

module coupling() {
    total_h = body_h + flange_h1 + flange_h2;

    difference() {
        union() {
            body_outer();
            grip_bands();
        }

        translate([0,0,-hex_h/2])
            hex_prism(flat=hex_flat + hex_clear, h=hex_h);
    }
}

coupling();
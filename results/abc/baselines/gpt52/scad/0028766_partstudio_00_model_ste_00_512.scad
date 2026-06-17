$fn=64;

L = 0.1;
W = 0.02;
H = 0.02;

stem_h = 0.06;
stem_w = 0.018;

base_h = 0.012;
base_r = 0.018;
cap_h  = 0.006;
cap_r  = 0.014;

curve_amp = 0.006;

module diamond_recess(len=0.028, depth=0.004, thick=0.02) {
    rotate([0,45,0])
        cube([len, thick, len], center=true);
}

module grip_segment(x0, x1, y0, y1, z0, z1) {
    hull() {
        translate([x0, y0, z0]) cube([0.001, 0.001, 0.001], center=true);
        translate([x1, y1, z1]) cube([0.001, 0.001, 0.001], center=true);
    }
}

module curved_grip() {
    n = 10;
    union() {
        for (i=[0:n-1]) {
            t0 = i/(n);
            t1 = (i+1)/(n);
            x0 = -L/2 + L*t0;
            x1 = -L/2 + L*t1;
            y0 = curve_amp * sin(180*(t0-0.5));
            y1 = curve_amp * sin(180*(t1-0.5));
            hull() {
                translate([x0, y0, 0]) cube([L/n + 0.0005, W, H], center=true);
                translate([x1, y1, 0]) cube([L/n + 0.0005, W, H], center=true);
            }
        }
    }
}

module faceted_gussets() {
    gus_h = 0.02;
    gus_w = W*0.95;
    gus_l = 0.03;
    union() {
        for (sx=[-1,1]) {
            hull() {
                translate([0, sx*(gus_w/2 - 0.002), -H/2]) cube([0.001, 0.001, 0.001], center=true);
                translate([0, sx*(stem_w/2), -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
                translate([gus_l/2, sx*(stem_w/2), -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
            }
            hull() {
                translate([0, sx*(gus_w/2 - 0.002), -H/2]) cube([0.001, 0.001, 0.001], center=true);
                translate([0, sx*(stem_w/2), -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
                translate([-gus_l/2, sx*(stem_w/2), -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
            }
        }
        for (sx=[-1,1]) {
            hull() {
                translate([sx*(gus_l/2), 0, -H/2]) cube([0.001, 0.001, 0.001], center=true);
                translate([sx*(stem_w/2), 0, -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
                translate([sx*(stem_w/2), gus_w/2 - 0.002, -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
            }
            hull() {
                translate([sx*(gus_l/2), 0, -H/2]) cube([0.001, 0.001, 0.001], center=true);
                translate([sx*(stem_w/2), 0, -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
                translate([sx*(stem_w/2), -(gus_w/2 - 0.002), -H/2 - gus_h]) cube([0.001, 0.001, 0.001], center=true);
            }
        }
    }
}

module stem_and_base() {
    union() {
        translate([0,0,-H/2 - stem_h/2])
            cylinder(h=stem_h, r=stem_w/2, center=true, $fn=24);
        translate([0,0,-H/2 - stem_h - base_h/2])
            cylinder(h=base_h, r=base_r, center=true, $fn=24);
        translate([0,0,-H/2 - stem_h - base_h - cap_h/2])
            cylinder(h=cap_h, r=cap_r, center=true, $fn=24);
    }
}

module handle() {
    difference() {
        union() {
            curved_grip();
            faceted_gussets();
            stem_and_base();
        }
        translate([0, W/2 + 0.001, 0])
            rotate([0,0,0])
                diamond_recess(len=0.03, depth=0.004, thick=0.03);
        translate([0, -(W/2 + 0.001), 0])
            rotate([0,0,0])
                diamond_recess(len=0.03, depth=0.004, thick=0.03);
    }
}

handle();
$fn=64;

L = 0.30;
W = 0.10;
H = 0.06;

shaft_L = 0.22;
head_L  = 0.06;
tip_L   = L - shaft_L - head_L;

module faceted_prism(len, w, h, facet=0.012) {
    hull() {
        translate([-len/2, 0, 0]) cube([0.001, w-2*facet, h], center=true);
        translate([ len/2, 0, 0]) cube([0.001, w-2*facet, h], center=true);
        translate([-len/2, 0, 0]) cube([0.001, w, h-2*facet], center=true);
        translate([ len/2, 0, 0]) cube([0.001, w, h-2*facet], center=true);
    }
}

module tapered_tip(len, w, h, tip_scale=0.25) {
    hull() {
        translate([-len/2, 0, 0]) cube([0.001, w, h], center=true);
        translate([ len/2, 0, 0]) scale([1, tip_scale, tip_scale]) cube([0.001, w, h], center=true);
    }
}

module collar_with_socket(len, r, h, socket=0.028, depth=0.035) {
    difference() {
        union() {
            translate([0,0,0]) cylinder(h=len, r=r, center=true, $fn=6);
            translate([0,0,0]) cylinder(h=len*0.55, r=r*0.92, center=true, $fn=64);
        }
        translate([0,0, len/2 - depth/2 + 0.0001])
            rotate([0,0,45])
                cube([socket, socket, depth+0.0002], center=true);
        translate([0,0, len/2 - depth + 0.0001])
            cylinder(h=depth*0.35, r=socket*0.35, center=false, $fn=32);
    }
}

module head_block(len, w, h) {
    faceted_prism(len, w, h, facet=0.010);
}

module tool_body() {
    union() {
        translate([-(L/2) + head_L/2, 0, 0])
            head_block(head_L, W*1.25, H*1.15);

        translate([-(L/2) + head_L + shaft_L/2, 0, 0])
            faceted_prism(shaft_L, W, H, facet=0.010);

        translate([-(L/2) + head_L + shaft_L + tip_L/2, 0, 0])
            tapered_tip(tip_L, W*0.95, H*0.95, tip_scale=0.18);

        translate([-(L/2) + head_L*0.35, 0, 0])
            rotate([0,90,0])
                collar_with_socket(len=0.045, r=0.030, h=H*1.2, socket=0.028, depth=0.030);
    }
}

tool_body();
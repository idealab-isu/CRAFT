$fn = 64;

// Parameters
length = 100;
w = 80;
h = 40;

// Simple 40x80 aluminum extrusion-like profile (outer rectangle with inner void)
wall = 3.0;
inner_w = w - 2*wall;
inner_h = h - 2*wall;

module extrusion_40x80(len=100) {
    linear_extrude(height=len, center=false, convexity=10)
        difference() {
            square([w, h], center=true);
            square([inner_w, inner_h], center=true);
        }
}

extrusion_40x80(length);
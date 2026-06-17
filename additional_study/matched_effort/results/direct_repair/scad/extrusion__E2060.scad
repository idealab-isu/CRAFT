$fn = 64;

length = 100;
w = 60;
h = 20;

module extrusion_2060(len=100, w=60, h=20) {
    linear_extrude(height=len, center=false, convexity=10)
        square([w, h], center=true);
}

extrusion_2060(length, w, h);
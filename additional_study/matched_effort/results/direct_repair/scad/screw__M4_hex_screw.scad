$fn = 96;

// Dimensions (mm)
shaft_d = 4.0;
length = 10.0;

head_flat_to_flat = 8.1;   // hex across flats
head_h = 2.925;

// Derived
shaft_r = shaft_d/2;
head_R = head_flat_to_flat / sqrt(3); // circumradius for hex with given across-flats

module hex_prism(h, R){
    linear_extrude(height=h)
        polygon(points=[for(i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

union() {
    // Shaft
    cylinder(h=length, r=shaft_r);

    // Hex head on top
    translate([0,0,length])
        hex_prism(head_h, head_R);
}
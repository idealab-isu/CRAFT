$fn=96;

shaft_d = 4.0;
length = 10.0;

head_flat_d = 8.1;      // across flats
head_h = 2.925;

module hex_prism(af, h){
    // Regular hex: across flats = sqrt(3)*R  => R = af/sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

union(){
    // Shaft
    cylinder(d=shaft_d, h=length);

    // Hex head on top
    translate([0,0,length])
        hex_prism(head_flat_d, head_h);
}
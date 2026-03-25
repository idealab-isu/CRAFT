$fn=96;

nut_thickness = 6.5;
across_flats = 15.0;
hole_d = 8.0;

module hex_prism(af, h){
    r = af / sqrt(3);
    linear_extrude(height=h, center=true)
        polygon(points=[for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module hex_nut(af, h, d){
    difference(){
        hex_prism(af, h);
        cylinder(d=d, h=h+0.6, center=true, $fn=96);
    }
}

hex_nut(across_flats, nut_thickness, hole_d);
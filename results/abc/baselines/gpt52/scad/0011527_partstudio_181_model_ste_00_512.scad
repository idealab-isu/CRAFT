$fn=128;

plate_od = 120;
thickness = 4;

center_hole_d = 60;

bolt_circle_d = 90;
hex_hole_af = 10;
hex_hole_count = 8;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=true);
}

module bolt_circle_hex_holes(n, bcd, af, h){
    for(i = [0:n-1]){
        a = 360/n * i;
        translate([ (bcd/2)*cos(a), (bcd/2)*sin(a), 0 ])
            hex_prism(af, h);
    }
}

difference(){
    cylinder(h=thickness, d=plate_od, center=true);
    cylinder(h=thickness+2, d=center_hole_d, center=true);
    bolt_circle_hex_holes(hex_hole_count, bolt_circle_d, hex_hole_af, thickness+2);
}
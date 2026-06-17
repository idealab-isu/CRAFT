$fn=96;

body_d = 20;
body_h = 18;

flange_af = 30;          // across flats
flange_h = 6;

module hex_prism(af, h){
    r = af / sqrt(3);    // circumradius for regular hex with given across-flats
    cylinder(h=h, r=r, $fn=6);
}

module flanged_sleeve(){
    union(){
        translate([0,0,body_h/2])
            cylinder(h=body_h, d=body_d);
        translate([0,0,body_h + flange_h/2])
            hex_prism(flange_af, flange_h);
    }
}

translate([0,0,-(body_h + flange_h)/2])
    flanged_sleeve();
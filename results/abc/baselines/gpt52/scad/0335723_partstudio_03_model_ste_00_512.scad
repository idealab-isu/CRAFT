$fn=96;

shaft_d = 20;
shaft_len = 60;

collar_af = 40;          // across flats
collar_thk = 20;

module shaft(d, l){
    cylinder(d=d, h=l, center=true);
}

module hex_collar(af, thk){
    r = af / sqrt(3);    // circumradius for given across-flats
    cylinder(r=r, h=thk, center=true, $fn=6);
}

union(){
    shaft(shaft_d, shaft_len);
    hex_collar(collar_af, collar_thk);
}
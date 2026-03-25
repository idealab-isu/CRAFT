$fn=64;

module hex_prism(flat_d=6.4, h=2.125){
    r = flat_d / sqrt(3); // across flats = sqrt(3)*r
    cylinder(h=h, r=r, $fn=6);
}

module screw_shaft(d=3.0, L=10){
    translate([0,0,-L]) cylinder(h=L, d=d, $fn=64);
}

module hex_head_screw(shaft_d=3.0, head_flat_d=6.4, head_h=2.125, length=10){
    union(){
        hex_prism(flat_d=head_flat_d, h=head_h);
        screw_shaft(d=shaft_d, L=length);
    }
}

hex_head_screw();
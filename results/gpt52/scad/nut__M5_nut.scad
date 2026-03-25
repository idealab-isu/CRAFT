$fn=64;

module hex_prism(af=9.2, h=4.0){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module nut(m_screw=5.0, af=9.2, thickness=4.0, clearance=0.3){
    hole_d = m_screw + clearance;
    difference(){
        hex_prism(af=af, h=thickness);
        cylinder(h=thickness+0.4, d=hole_d, center=true, $fn=64);
    }
}

nut(m_screw=5.0, af=9.2, thickness=4.0, clearance=0.3);
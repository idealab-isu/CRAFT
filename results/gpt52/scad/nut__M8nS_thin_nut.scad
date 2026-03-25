$fn=64;

module hex_prism_af(af=13.0, h=4.0){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module thin_hex_nut(m_screw=8.0, af=13.0, thickness=4.0, clearance=0.4){
    hole_d = m_screw + clearance;
    difference(){
        hex_prism_af(af=af, h=thickness);
        cylinder(h=thickness+0.6, d=hole_d, center=true, $fn=64);
    }
}

thin_hex_nut(m_screw=8.0, af=13.0, thickness=4.0, clearance=0.4);
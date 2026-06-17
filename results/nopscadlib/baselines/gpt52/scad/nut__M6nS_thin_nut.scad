$fn=64;

module hex_prism_across_flats(af=10.0, h=3.2){
    r = af / sqrt(3); // circumradius for given across-flats
    cylinder(h=h, r=r, center=true, $fn=6);
}

module nut(m_thread=6.0, af=10.0, thickness=3.2, hole_clearance=0.4){
    difference(){
        hex_prism_across_flats(af=af, h=thickness);
        cylinder(h=thickness+0.6, d=m_thread+hole_clearance, center=true, $fn=64);
    }
}

nut(m_thread=6.0, af=10.0, thickness=3.2, hole_clearance=0.4);
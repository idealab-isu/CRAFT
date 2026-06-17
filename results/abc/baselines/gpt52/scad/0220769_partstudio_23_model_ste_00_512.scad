$fn=96;

outer_flat = 30;
thickness = 12;
hole_d = 16;
elongation = 1.6;
corner_round = 1.2;
edge_chamfer = 0.8;

module hex2d(flat=30){
    r = flat / sqrt(3);
    polygon(points=[for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module rounded_hex_prism(flat=30, h=10, rr=1.0){
    linear_extrude(height=h, center=true)
        offset(r=rr)
            offset(delta=-rr)
                hex2d(flat);
}

module chamfered_rounded_hex_ring(flat=30, h=10, rr=1.0, ch=0.8, hole=16){
    difference(){
        union(){
            rounded_hex_prism(flat=flat, h=h-2*ch, rr=rr);
            translate([0,0,(h/2)-(ch/2)]) rounded_hex_prism(flat=flat, h=ch, rr=rr);
            translate([0,0,(-h/2)+(ch/2)]) rounded_hex_prism(flat=flat, h=ch, rr=rr);
        }
        cylinder(h=h+2, d=hole, center=true);
    }
}

scale([elongation,1,1])
    chamfered_rounded_hex_ring(flat=outer_flat, h=thickness, rr=corner_round, ch=edge_chamfer, hole=hole_d);
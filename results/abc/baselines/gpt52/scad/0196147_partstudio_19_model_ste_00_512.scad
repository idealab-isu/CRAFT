$fn=96;

module hex_prism_flat_to_flat(flat=20, h=8){
    r = flat / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module chamfered_hex_ring(flat=20, h=8, hole_d=10, chamfer=0.8){
    difference(){
        union(){
            translate([0,0,0]) hex_prism_flat_to_flat(flat=flat, h=h-2*chamfer);
            translate([0,0,(h-2*chamfer)/2]) cylinder(h=chamfer, r1=flat/sqrt(3), r2=(flat-2*chamfer)/sqrt(3), center=false, $fn=6);
            translate([0,0,-(h-2*chamfer)/2 - chamfer]) cylinder(h=chamfer, r1=(flat-2*chamfer)/sqrt(3), r2=flat/sqrt(3), center=false, $fn=6);
        }
        cylinder(h=h+2, d=hole_d, center=true, $fn=96);
    }
}

chamfered_hex_ring(flat=20, h=8, hole_d=10, chamfer=0.8);
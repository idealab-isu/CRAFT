$fn=96;

module octagon_prism(flat_d=100, h=2){
    linear_extrude(height=h, center=true)
        circle(d=flat_d, $fn=8);
}

module square_hole(size=8, h=10){
    linear_extrude(height=h, center=true)
        square([size,size], center=true);
}

module ring_body(flat_d=100, inner_d=60, h=2){
    difference(){
        octagon_prism(flat_d=flat_d, h=h);
        cylinder(d=inner_d, h=h+2, center=true, $fn=96);
    }
}

module chamfered_ring(flat_d=100, inner_d=60, h=2, chamfer=0.6){
    union(){
        ring_body(flat_d=flat_d, inner_d=inner_d, h=h);
        translate([0,0,(h/2)-(chamfer/2)])
            difference(){
                octagon_prism(flat_d=flat_d, h=chamfer);
                octagon_prism(flat_d=flat_d-2*chamfer, h=chamfer+0.02);
                cylinder(d=inner_d, h=chamfer+0.2, center=true, $fn=96);
            }
        translate([0,0,-(h/2)+(chamfer/2)])
            difference(){
                octagon_prism(flat_d=flat_d, h=chamfer);
                octagon_prism(flat_d=flat_d-2*chamfer, h=chamfer+0.02);
                cylinder(d=inner_d, h=chamfer+0.2, center=true, $fn=96);
            }
    }
}

module faceted_washer(
    flat_d=100,
    inner_d=60,
    h=2,
    chamfer=0.6,
    hole_size=8,
    hole_radius=42
){
    difference(){
        chamfered_ring(flat_d=flat_d, inner_d=inner_d, h=h, chamfer=chamfer);
        for(i=[0:7]){
            rotate([0,0,i*45])
                translate([hole_radius,0,0])
                    square_hole(size=hole_size, h=h+4);
        }
    }
}

scale([0.001,0.001,0.001])
    faceted_washer(
        flat_d=100,
        inner_d=60,
        h=2,
        chamfer=0.6,
        hole_size=8,
        hole_radius=42
    );
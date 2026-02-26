EPS = 0.01;

module circle_extrude(r, h) {
    translate([0, 0, -h/2])
    linear_extrude(height=h)
    circle(r=r);
}

module sketch0() {
    union() {
        translate([0.5210526315789474, 0, 0])
        circle_extrude(0.5210526315789474, 0.0859375 + EPS);
        
        translate([0.5101973684210527, 0.36907894736842106, 0])
        circle_extrude(0.0868421052631579, 0.0859375 + EPS);
        
        translate([0.8901315789473685, 0.010855263157894738, 0])
        circle_extrude(0.0868421052631579, 0.0859375 + EPS);
    }
}

translate([-0.75, 0.0, 0.0546875])
rotate([0, 90, 0])
sketch0();
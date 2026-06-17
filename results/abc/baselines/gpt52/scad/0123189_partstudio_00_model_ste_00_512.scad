$fn=64;

L = 0.1;
W = 0.1;
H = 0.0;

module hull_body() {
    translate([0,0,0])
        cube([L*0.70, W*0.55, H], center=true);
}

module end_pod(xpos) {
    translate([xpos,0,0])
        rotate([0,90,0])
            cylinder(h=L*0.18, r=W*0.28, center=true, $fn=18);
}

module turret_faceted() {
    hull() {
        translate([0,0,0])
            cube([L*0.22, W*0.22, H], center=true);
        translate([0,0,0])
            rotate([0,0,45])
                cube([L*0.16, W*0.16, H], center=true);
        translate([0,0,0])
            rotate([0,0,22.5])
                cube([L*0.18, W*0.12, H], center=true);
    }
}

module barrel() {
    translate([L*0.50,0,0])
        rotate([0,90,0])
            cylinder(h=L*0.22, r=W*0.06, center=true, $fn=18);
    translate([L*0.60,0,0])
        rotate([0,90,0])
            cylinder(h=L*0.06, r=W*0.04, center=true, $fn=18);
}

module fin(side=1) {
    s = side;
    translate([0, s*(W*0.33), 0])
        rotate([0,0, s*10])
            linear_extrude(height=H, center=true, convexity=2)
                polygon(points=[
                    [-L*0.08, 0],
                    [ L*0.08, 0],
                    [ L*0.02, W*0.10]
                ]);
}

module vehicle() {
    union() {
        hull_body();
        end_pod(-L*0.35);
        end_pod( L*0.35);
        turret_faceted();
        barrel();
        fin(1);
        fin(-1);
    }
}

vehicle();
$fn=128;

bore_d = 5.0;
outer_d = 8.0;
width = 2.5;

ring_wall = (outer_d - bore_d)/2;
race_depth = min(0.6, ring_wall*0.45);
race_r = min(0.45, width*0.18);
ball_d = min(0.9, width*0.55, ring_wall*0.9);
ball_r = ball_d/2;

module ring_with_races() {
    difference() {
        cylinder(d=outer_d, h=width, center=true);
        cylinder(d=bore_d, h=width+0.2, center=true);

        // Outer race groove
        translate([outer_d/2 - race_depth, 0, 0])
            rotate([0,90,0])
                rotate_extrude(angle=360, convexity=10)
                    translate([width/2 - race_r, 0, 0])
                        circle(r=race_r, $fn=96);

        // Inner race groove
        translate([bore_d/2 + race_depth, 0, 0])
            rotate([0,90,0])
                rotate_extrude(angle=360, convexity=10)
                    translate([width/2 - race_r, 0, 0])
                        circle(r=race_r, $fn=96);
    }
}

module balls(n=8) {
    ball_path_r = (bore_d/2 + outer_d/2)/2;
    for (i = [0:n-1]) {
        rotate([0,0, i*360/n])
            translate([ball_path_r, 0, 0])
                sphere(d=ball_d, $fn=96);
    }
}

union() {
    ring_with_races();
    balls(8);
}
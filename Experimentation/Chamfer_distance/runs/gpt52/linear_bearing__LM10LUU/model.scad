$fn = 96;

module linear_ball_bearing(bore_d=10, od_d=19, len=55) {
    difference() {
        cylinder(h=len, d=od_d, center=true);
        cylinder(h=len+0.6, d=bore_d, center=true);
    }
}

linear_ball_bearing(10, 19, 55);
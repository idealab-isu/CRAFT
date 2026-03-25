$fn=128;

module linear_bearing(bore_d=3.0, od_d=7.0, len=19.0) {
    difference() {
        cylinder(d=od_d, h=len, center=true);
        cylinder(d=bore_d, h=len+0.2, center=true);
    }
}

linear_bearing();
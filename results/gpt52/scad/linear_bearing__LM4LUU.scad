$fn=96;

module linear_bearing(bore_d=4.0, od_d=8.0, len=23.0) {
    difference() {
        cylinder(d=od_d, h=len, center=true);
        cylinder(d=bore_d, h=len+0.4, center=true);
    }
}

linear_bearing();
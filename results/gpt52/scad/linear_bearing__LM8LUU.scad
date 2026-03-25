$fn=128;

module linear_bearing(bore_d=8.0, od_d=15.0, len=45.0) {
    difference() {
        cylinder(d=od_d, h=len, center=true);
        cylinder(d=bore_d, h=len+0.2, center=true);
    }
}

linear_bearing();
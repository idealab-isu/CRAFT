$fn=96;

module linear_bearing(bore_d=5.0, od=10.0, len=28.0) {
    difference() {
        cylinder(d=od, h=len, center=true);
        cylinder(d=bore_d, h=len+0.4, center=true);
    }
}

linear_bearing();
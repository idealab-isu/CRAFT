$fn=64;

module radial(a=[10.5,3.7,3.5]) {
    union() {
        cylinder(h=a[2], r=a[0], center=true);
        cylinder(h=a[2], r=a[1], center=true);
    }
}

radial([10.5,3.7,3.5]);
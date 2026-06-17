$fn=64;

axial = [3.4, 1.75, 0.3];

module axial_shape(a=[3.4,1.75,0.3]) {
    union() {
        translate([0,0,0]) cylinder(h=a[0], r=a[1], center=true);
        translate([0,0,0]) cylinder(h=a[0] + 2*a[2], r=a[1] - a[2], center=true);
    }
}

axial_shape(axial);
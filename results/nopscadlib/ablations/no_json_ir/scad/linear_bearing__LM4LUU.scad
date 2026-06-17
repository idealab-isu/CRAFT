// Long linear bearing: 4.0mm bore, 8.0mm OD, 23.0mm length
$fn = 120;

id = 4.0;
od = 8.0;
len = 23.0;

// Small extra length to guarantee a clean through-bore
eps = 0.2;

module linear_bearing(id=4.0, od=8.0, len=23.0) {
    difference() {
        // Outer body (simple cylinder, no lips/grooves)
        cylinder(h=len, d=od, center=false);

        // Through-bore (extends slightly beyond both ends)
        translate([0, 0, -eps])
            cylinder(h=len + 2*eps, d=id, center=false);
    }
}

linear_bearing(id=id, od=od, len=len);
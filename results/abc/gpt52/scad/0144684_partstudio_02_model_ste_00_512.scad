$fn=64;

size = 0.1;

module chamfer_box(sz=[0.1,0.1,0.1], c=0.006) {
    x=sz[0]; y=sz[1]; z=sz[2];
    intersection() {
        cube([x,y,z], center=true);
        union() {
            cube([x-2*c, y, z], center=true);
            cube([x, y-2*c, z], center=true);
            cube([x, y, z-2*c], center=true);
            rotate([0,0,45]) cube([x*2, y*2, z], center=true);
            rotate([0,0,-45]) cube([x*2, y*2, z], center=true);
            rotate([45,0,0]) cube([x*2, y, z*2], center=true);
            rotate([-45,0,0]) cube([x*2, y, z*2], center=true);
            rotate([0,45,0]) cube([x, y*2, z*2], center=true);
            rotate([0,-45,0]) cube([x, y*2, z*2], center=true);
        }
    }
}

module l_body() {
    union() {
        translate([0,0,0]) cube([size, size, size], center=true);
        translate([0,0,-size*0.25]) cube([size*0.7, size*0.7, size*0.5], center=true);
    }
}

module side_notch() {
    translate([size*0.15, 0, 0])
        cube([size*0.7, size*0.55, size*0.7], center=true);
}

module u_recess_back() {
    translate([0, -size*0.22, -size*0.05]) {
        difference() {
            cube([size*0.75, size*0.55, size*0.7], center=true);
            translate([0, size*0.08, 0])
                cube([size*0.45, size*0.45, size*0.75], center=true);
        }
    }
}

module internal_chamfer_cut() {
    translate([size*0.15, -size*0.05, 0])
        rotate([0,0,45])
            cube([size*0.12, size*0.12, size*0.9], center=true);
}

difference() {
    intersection() {
        l_body();
        chamfer_box([size,size,size], c=size*0.06);
    }
    side_notch();
    u_recess_back();
    internal_chamfer_cut();
}
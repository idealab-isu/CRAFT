$fn=64;

size = 0.1;

t = 0.02;
leg = 0.08;
width = 0.06;

fillet_r = 0.02;
outer_r = 0.01;

lip_t = 0.01;
lip_h = 0.02;

hole_d = 0.02;

bevel = 0.01;

module rounded_box(sz=[1,1,1], r=0.1){
    r2 = min(r, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski(){
        cube([sz[0]-2*r2, sz[1]-2*r2, sz[2]-2*r2], center=true);
        sphere(r=r2);
    }
}

module bracket_body(){
    union(){
        // Base leg (horizontal)
        translate([0, 0, -t/2])
            rounded_box([leg, width, t], r=outer_r);

        // Upright leg (vertical)
        translate([leg/2 - t/2, 0, leg/2])
            rounded_box([t, width, leg], r=outer_r);

        // Internal fillet at inside corner
        translate([leg/2 - t, 0, 0])
            rotate([90,0,0])
                cylinder(r=fillet_r, h=width, center=true);

        // Thickened flange/lip along one long edge of base leg
        translate([0, (width/2 - lip_t/2), -t - lip_h/2])
            rounded_box([leg, lip_t, lip_h], r=min(outer_r, lip_t/2, lip_h/2));
    }
}

module bevel_relief(){
    // Small relieved wedge near the bend on the inside corner
    translate([leg/2 - t, 0, 0])
        rotate([0,45,0])
            cube([bevel, width+0.02, bevel], center=true);
}

module through_hole(){
    // Hole through upright leg (along Y)
    translate([leg/2 - t/2, 0, leg*0.6])
        rotate([90,0,0])
            cylinder(d=hole_d, h=width+0.2, center=true);
}

scale([size/0.1, size/0.1, size/0.1])
difference(){
    bracket_body();
    through_hole();
    bevel_relief();
}
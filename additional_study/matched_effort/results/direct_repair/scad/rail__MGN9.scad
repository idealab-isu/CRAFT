$fn = 64;

rail_w = 9.0;
rail_h = 6.0;
rail_l = 100.0;

edge_r = 0.8;          // outer edge rounding
top_chamfer = 0.6;     // small top bevel
side_groove_depth = 0.9;
side_groove_height = 2.2;
side_groove_z = 2.2;   // from bottom
center_relief_w = 2.2;
center_relief_d = 0.6;

hole_d = 3.2;
csk_d = 5.8;
csk_h = 1.6;
hole_pitch = 25.0;
hole_margin = 12.5;

module rounded_box(size=[10,10,10], r=1.0){
    // Minkowski rounded rectangular prism
    sx = max(0.01, size[0]-2*r);
    sy = max(0.01, size[1]-2*r);
    sz = max(0.01, size[2]-2*r);
    minkowski(){
        cube([sx, sy, sz], center=false);
        sphere(r=r);
    }
}

module countersunk_hole(d=3, csk_d=6, csk_h=2, h=10){
    // Through hole + top countersink
    union(){
        cylinder(d=d, h=h, center=false);
        translate([0,0,h-csk_h])
            cylinder(d1=csk_d, d2=d, h=csk_h, center=false);
    }
}

module rail(){
    difference(){
        // Base body with rounded edges
        rounded_box([rail_w, rail_l, rail_h], r=edge_r);

        // Top bevels (approximate chamfer by subtracting wedges)
        translate([-1, -1, rail_h-top_chamfer])
            rotate([0,45,0])
                cube([rail_w*2, rail_l+2, rail_w*2], center=false);
        translate([rail_w+1, -1, rail_h-top_chamfer])
            rotate([0,-45,0])
                cube([rail_w*2, rail_l+2, rail_w*2], center=false);

        // Side grooves (both sides)
        translate([-0.01, -1, side_groove_z])
            cube([side_groove_depth+0.02, rail_l+2, side_groove_height], center=false);
        translate([rail_w-side_groove_depth-0.01, -1, side_groove_z])
            cube([side_groove_depth+0.02, rail_l+2, side_groove_height], center=false);

        // Center relief channel on top
        translate([(rail_w-center_relief_w)/2, -1, rail_h-center_relief_d])
            cube([center_relief_w, rail_l+2, center_relief_d+0.02], center=false);

        // Mounting holes along length (countersunk from top)
        for (y = [hole_margin : hole_pitch : rail_l-hole_margin+0.001]){
            translate([rail_w/2, y, 0])
                countersunk_hole(d=hole_d, csk_d=csk_d, csk_h=csk_h, h=rail_h+0.5);
        }
    }
}

rail();
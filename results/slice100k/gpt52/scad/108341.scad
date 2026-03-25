$fn=96;

bbox_x = 46.2;
bbox_y = 40.0;
bbox_z = 29.9;

plate_th = 6.0;
dome_r = bbox_z - plate_th;  // 23.9
hole_d = 6.0;

module hex_plate(flat_d, h){
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module hemispherical_dome(r){
    intersection(){
        sphere(r=r, $fn=128);
        translate([0,0,0]) cylinder(h=r, r=r, $fn=128);
    }
}

difference(){
    union(){
        translate([0,0,-bbox_z/2]) hex_plate(bbox_y, plate_th);
        translate([0,0,-bbox_z/2 + plate_th]) hemispherical_dome(dome_r);
    }
    translate([0,0,-bbox_z/2 - 1])
        cylinder(h=bbox_z + 2, d=hole_d, $fn=96);
}
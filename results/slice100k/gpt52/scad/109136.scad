$fn=96;

plate_x = 35.0;
plate_y = 30.3;
plate_z = 4.0;

hole_d = 10.0;

boss_d = 16.0;
boss_h = 1.0;

module hex2d_flat_w(width_x, width_y){
    s = width_x/2;
    r = width_y/sqrt(3);
    polygon(points=[
        [ s, 0],
        [ s/2,  r*sqrt(3)/2],
        [-s/2,  r*sqrt(3)/2],
        [-s, 0],
        [-s/2, -r*sqrt(3)/2],
        [ s/2, -r*sqrt(3)/2]
    ]);
}

module hex_plate(){
    linear_extrude(height=plate_z, center=true)
        hex2d_flat_w(plate_x, plate_y);
}

module boss_pad(){
    translate([0,0,plate_z/2 - boss_h/2])
        cylinder(h=boss_h, d=boss_d, center=true);
}

difference(){
    union(){
        hex_plate();
        boss_pad();
    }
    cylinder(h=plate_z + boss_h + 2, d=hole_d, center=true);
}
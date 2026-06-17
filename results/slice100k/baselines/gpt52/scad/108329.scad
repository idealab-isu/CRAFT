$fn=96;

bbox_x = 46.2;
bbox_y = 40.0;
bbox_z = 19.0;

th = bbox_z;

hole_d = 6.2;

hex_flat = bbox_y;                 // across flats
hex_R = hex_flat / sqrt(3);        // circumradius for pointy-top hex

module hex_prism(h=th, r=hex_R){
    cylinder(h=h, r=r, center=true, $fn=6);
}

module notch_rect(w, d, h, zc=0){
    translate([0,0,zc]) cube([w,d,h], center=true);
}

module perimeter_notches(){
    // Notches are subtracted; placed around perimeter with slight asymmetry
    // Depth is radial (local +Y after rotation)
    notch_h = th + 2;

    // Top/bottom edge notches
    rotate([0,0,0])   translate([0, hex_flat/2 - 2.2, 0]) notch_rect(12.0, 4.4, notch_h);
    rotate([0,0,180]) translate([2.0, hex_flat/2 - 2.0, 0]) notch_rect(10.0, 4.0, notch_h);

    // Upper-right / lower-left
    rotate([0,0,60])  translate([1.0, hex_flat/2 - 2.4, 0]) notch_rect(9.0, 4.8, notch_h);
    rotate([0,0,240]) translate([-1.5, hex_flat/2 - 2.1, 0]) notch_rect(11.0, 4.2, notch_h);

    // Upper-left / lower-right
    rotate([0,0,120]) translate([-0.5, hex_flat/2 - 2.3, 0]) notch_rect(8.0, 4.6, notch_h);
    rotate([0,0,300]) translate([1.8, hex_flat/2 - 2.0, 0]) notch_rect(10.5, 4.0, notch_h);
}

module top_reliefs(){
    // Shallow asymmetric pockets on top face
    zt = th/2 - 2.2/2;
    translate([6.5, 3.0, zt]) cube([22.0, 14.0, 2.2], center=true);
    translate([-10.0, -6.0, th/2 - 1.6/2]) cube([18.0, 10.0, 1.6], center=true);
    rotate([0,0,25]) translate([0.0, 14.0, th/2 - 1.2/2]) cube([16.0, 8.0, 1.2], center=true);
}

module bottom_reliefs(){
    // Shallow asymmetric pockets on bottom face (different from top)
    zb = -th/2 + 2.6/2;
    translate([-7.0, 4.0, zb]) cube([24.0, 12.0, 2.6], center=true);
    translate([11.0, -7.5, -th/2 + 1.8/2]) cube([16.0, 12.0, 1.8], center=true);
    rotate([0,0,-18]) translate([0.0, -14.0, -th/2 + 1.3/2]) cube([18.0, 7.0, 1.3], center=true);
}

difference(){
    union(){
        hex_prism(th, hex_R);
    }

    // Central through-hole
    cylinder(h=th+2, d=hole_d, center=true, $fn=96);

    // Perimeter steps/notches
    perimeter_notches();

    // Asymmetric top/bottom reliefs
    top_reliefs();
    bottom_reliefs();

    // Small side key cut to emphasize asymmetry
    rotate([0,0,15]) translate([hex_R*0.92, 0, 0]) cube([6.0, 10.0, th+2], center=true);
}
$fn=64;

L = 36.0;   // length (elongated axis) X
W = 19.0;   // width Y
H = 21.0;   // height Z

fillet_r = 2.5;

web_t = 7.0;        // central web thickness along Y
cut_depth = (W - web_t)/2;  // depth of each side cutout
cut_len = 24.0;     // length of cutout along X
cut_h = 13.0;       // height of cutout along Z
cut_z0 = (H - cut_h)/2;

module rounded_block(x, y, z, r){
    minkowski(){
        cube([x-2*r, y-2*r, z-2*r], center=true);
        sphere(r=r);
    }
}

module side_cutout(){
    translate([0, (web_t/2 + cut_depth/2), -H/2 + cut_z0 + cut_h/2])
        cube([cut_len, cut_depth, cut_h], center=true);
}

difference(){
    rounded_block(L, W, H, fillet_r);
    side_cutout();
    mirror([0,1,0]) side_cutout();
}
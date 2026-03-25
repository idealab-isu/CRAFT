$fn=64;

L = 31.8;
W = 31.8;
H = 15.8;

module end_block(xc, len, wid, hgt){
    translate([xc,0,0]) cube([len,wid,hgt], center=true);
}

module bridge(len, wid, hgt){
    cube([len,wid,hgt], center=true);
}

module pad(xc, yc, zc, len, wid, hgt){
    translate([xc,yc,zc]) cube([len,wid,hgt], center=true);
}

module base_shape(){
    union(){
        end_block(-10.2, 11.2, 31.8, 15.8);
        end_block( 10.2, 11.2, 31.8, 15.8);
        bridge(10.4, 12.0, 15.8);
    }
}

module stepped_profile(){
    union(){
        base_shape();

        // Top rebates/steps (add material to create shoulders)
        pad(-10.2,  0.0,  5.0, 11.2, 20.0, 5.8);
        pad( 10.2,  0.0,  4.2, 11.2, 16.0, 7.4);
        pad(  0.0,  0.0,  4.6, 10.4, 10.0, 6.6);

        // Bottom rebates/steps (add material to create shoulders)
        pad(-10.2,  0.0, -5.2, 11.2, 14.0, 5.4);
        pad( 10.2,  0.0, -4.6, 11.2, 22.0, 6.6);
        pad(  0.0,  0.0, -4.8, 10.4,  8.0, 6.2);

        // Asymmetric offset pads to create non-mirrored profile
        pad(-10.2,  9.2,  0.0, 11.2,  6.0, 15.8);
        pad( 10.2, -8.6,  0.0, 11.2,  7.2, 15.8);
        pad(  0.0,  6.8,  0.0, 10.4,  5.0, 15.8);
    }
}

module final_part(){
    intersection(){
        stepped_profile();
        cube([L,W,H], center=true);
    }
}

final_part();
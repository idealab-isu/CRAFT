$fn = 64;

block_x = 16.0;
block_y = 28.0;
block_z = 42.5;

module leadscrew_nut_housing() {
    cube([block_x, block_y, block_z], center=false);
}

leadscrew_nut_housing();
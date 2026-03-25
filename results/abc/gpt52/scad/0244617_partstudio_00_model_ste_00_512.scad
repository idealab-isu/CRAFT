$fn=64;

block_x = 60;
block_y = 40;
block_z = 20;

boss_d = 20;
boss_h = 8;

module block() {
    cube([block_x, block_y, block_z], center=true);
}

module boss() {
    cylinder(d=boss_d, h=boss_h, center=false);
}

union() {
    block();
    translate([0, 0, block_z/2])
        boss();
}
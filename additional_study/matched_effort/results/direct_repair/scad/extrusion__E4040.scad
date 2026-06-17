$fn = 64;

length = 100;
size = 40;

difference() {
  cube([size, size, length], center=false);
  translate([2, 2, -0.1]) cube([size-4, size-4, length+0.2], center=false);
}
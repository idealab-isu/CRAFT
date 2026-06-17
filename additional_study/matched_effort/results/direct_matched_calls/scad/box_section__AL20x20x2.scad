$fn = 64;

outer_w = 20;
outer_h = 20;
wall = 2;
length = 100;

inner_w = outer_w - 2*wall;
inner_h = outer_h - 2*wall;

difference() {
  cube([outer_w, outer_h, length], center=false);
  translate([wall, wall, -0.1])
    cube([inner_w, inner_h, length + 0.2], center=false);
}
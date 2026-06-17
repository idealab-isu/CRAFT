$fn = 64;

size = [26, 25, 4.7];

difference() {
  cube(size, center=false);
  // Optional light edge relief (kept minimal to preserve bracket size)
  // Comment out if you want a pure rectangular plate.
  translate([0.6, 0.6, -0.01])
    cube([size[0]-1.2, size[1]-1.2, size[2]+0.02], center=false);
}
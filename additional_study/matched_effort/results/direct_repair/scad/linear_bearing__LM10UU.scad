$fn = 128;

bore_d = 10.0;
od_d   = 19.0;
len    = 29.0;

difference() {
  cylinder(d = od_d, h = len, center = false);
  translate([0,0,-0.1])
    cylinder(d = bore_d, h = len + 0.2, center = false);
}
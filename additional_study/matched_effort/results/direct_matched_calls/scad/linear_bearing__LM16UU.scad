$fn = 180;

bore_d = 16.0;
od_d   = 28.0;
len    = 37.0;

difference() {
  cylinder(d = od_d, h = len, center = false);
  translate([0,0,-0.1]) cylinder(d = bore_d, h = len + 0.2, center = false);
}
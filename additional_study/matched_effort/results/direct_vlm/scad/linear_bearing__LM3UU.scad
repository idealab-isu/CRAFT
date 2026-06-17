$fn = 128;

bore_d = 3.0;
od_d   = 7.0;
len    = 10.0;

difference() {
  cylinder(d = od_d, h = len, center = false);
  translate([0,0,-0.01]) cylinder(d = bore_d, h = len + 0.02, center = false);
}
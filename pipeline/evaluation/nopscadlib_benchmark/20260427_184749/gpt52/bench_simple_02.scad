$fn=64;

od = 16;
id = 8.4;
th = 1.6;

difference() {
  cylinder(h=th, d=od, center=true);
  cylinder(h=th+0.2, d=id, center=true);
}
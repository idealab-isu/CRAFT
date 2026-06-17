$fn = 96;

shaft_d = 3.5;
head_d  = 7.0;
length  = 10.0;

head_h = 3.0;                 // simple pan head height
shaft_h = max(0.01, length - head_h);

union() {
  // Shaft
  cylinder(d = shaft_d, h = shaft_h);

  // Head
  translate([0, 0, shaft_h])
    cylinder(d = head_d, h = head_h);
}
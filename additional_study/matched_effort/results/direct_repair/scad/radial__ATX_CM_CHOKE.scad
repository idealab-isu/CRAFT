$fn = 128;

radii = [17.4, 11.4, 9, 0.5];

difference() {
  circle(r = radii[0]);
  circle(r = radii[1]);
}

difference() {
  circle(r = radii[2]);
  circle(r = radii[3]);
}
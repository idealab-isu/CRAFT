// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

$fn = 64;

// Small overlap to guarantee watertight union
overlap = 0.5;

// Main Body Module
module main_body() {
  cube([body_length, body_width, body_height], center=true);
}

// Final Component (single connected solid)
color([0.85, 0.85, 0.8])
union() {
  main_body();

  // Connected top rib (adds visible 3D detail while staying one solid)
  rib_h = max(2, body_height * 0.35);
  rib_w = body_width * 0.35;
  rib_l = body_length * 0.70;

  translate([0, 0, body_height/2 + rib_h/2 - overlap])
    cube([rib_l, rib_w, rib_h], center=true);

  // Connected side tab (ensures non-blank renders from multiple views)
  tab_l = body_length * 0.25;
  tab_w = body_width * 0.30;
  tab_h = body_height * 0.60;

  translate([body_length/2 + tab_l/2 - overlap, 0, 0])
    cube([tab_l, tab_w, tab_h], center=true);
}
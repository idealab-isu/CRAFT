// Dimension-calibrated (target: 96.60 x 19.00 x 123.00 mm)
scale([1.073298, 1.380043, 0.138182])
{
$fn = 96;

// -------------------- Parameters (target bbox: 96.6 x 19.0 x 123.0) --------------------
bbox_X = 96.6;
bbox_Y = 19.0;
bbox_Z = 123.0;

thk = bbox_Y;                 // plate thickness (Y)
spine_W = 12.0;               // spine width (X)
spine_L = bbox_Z;             // spine length (Z)

boss_D = 16.0;                // boss diameter (axis along Y)
boss_Z = 8.0;                 // boss extent along Z (cap length)

diamond_W = bbox_X;           // diamond overall width (X)
diamond_H = 70.0;             // diamond overall height (Z)
brace_W = 8.0;                // diamond ring wall thickness (in 2D)

corner_eyelet_OD = 18.0;
corner_eyelet_ID = 10.0;

spine_eyelet_count = 4;       // multiple eyelets along spine
spine_eyelet_OD = 16.0;
spine_eyelet_ID = 8.0;
spine_eyelet_spacing = 22.0;
spine_eyelet_offset_from_end = 18.0;

junction_web_W = 10.0;        // web from spine to diamond (X)
overlap = 1.0;

rib_w = 4.0;                  // internal brace width (2D)
lighten_slot_W = 6.0;
lighten_slot_L = 18.0;

// Place diamond so its TOP is at +spine_L/2 (spine end), making an elongated spine + loop
diamond_center_z = spine_L/2 - diamond_H/2;

// -------------------- Helpers --------------------
module ring_y(od, id, y=thk, center=true) {
  difference() {
    cylinder(r=od/2, h=y, center=center);
    cylinder(r=id/2, h=y + 2*overlap, center=center);
  }
}

module diamond_2d(w, h) {
  polygon(points=[
    [0,  h/2],
    [w/2, 0],
    [0, -h/2],
    [-w/2, 0]
  ]);
}

module spine_box() {
  cube([spine_W, thk, spine_L], center=true);
}

// Boss/cap at bottom end of spine (connected with overlap)
module boss_cap() {
  // short cylindrical boss whose axis is along Y, located at bottom end of spine
  translate([0, 0, -spine_L/2 + boss_Z/2 - overlap])
    rotate([90, 0, 0])
      cylinder(r=boss_D/2, h=thk, center=true);
}

// Diamond ring (loop) in XZ plane, extruded along Y
module diamond_loop() {
  translate([0, 0, diamond_center_z])
    linear_extrude(height=thk, center=true)
      difference() {
        diamond_2d(diamond_W, diamond_H);
        offset(delta=-brace_W) diamond_2d(diamond_W, diamond_H);
      }
}

// Corner eyelets at all four diamond corners (connected to ring)
module corner_eyelets() {
  translate([0, 0, diamond_center_z + diamond_H/2]) ring_y(corner_eyelet_OD, corner_eyelet_ID, thk, true); // top
  translate([0, 0, diamond_center_z - diamond_H/2]) ring_y(corner_eyelet_OD, corner_eyelet_ID, thk, true); // bottom
  translate([ diamond_W/2, 0, diamond_center_z])    ring_y(corner_eyelet_OD, corner_eyelet_ID, thk, true); // right
  translate([-diamond_W/2, 0, diamond_center_z])    ring_y(corner_eyelet_OD, corner_eyelet_ID, thk, true); // left
}

// Webs to ensure spine-to-diamond connectivity (connect at diamond bottom vertex region)
module junction_webs() {
  // connect spine to diamond at its bottom vertex (where spine meets loop)
  z_bot = diamond_center_z - diamond_H/2;
  // small Z extent to overlap both spine and ring
  web_Z = brace_W;

  translate([ spine_W/2 + junction_web_W/2 - overlap, 0, z_bot + web_Z/2])
    cube([junction_web_W, thk, web_Z], center=true);
  translate([-spine_W/2 - junction_web_W/2 + overlap, 0, z_bot + web_Z/2])
    cube([junction_web_W, thk, web_Z], center=true);

  // secondary web slightly above for robustness (still within diamond)
  z_mid = z_bot + diamond_H*0.25;
  translate([ spine_W/2 + junction_web_W/2 - overlap, 0, z_mid])
    cube([junction_web_W, thk, web_Z], center=true);
  translate([-spine_W/2 - junction_web_W/2 + overlap, 0, z_mid])
    cube([junction_web_W, thk, web_Z], center=true);
}

// Internal diamond braces (flat, symmetric) using 2D offset then extrude
module diamond_braces() {
  translate([0, 0, diamond_center_z])
    linear_extrude(height=thk, center=true)
      union() {
        // vertical brace
        offset(delta=rib_w/2)
          polygon(points=[[0, diamond_H/2 - brace_W], [0, -diamond_H/2 + brace_W]]);
        // horizontal brace
        offset(delta=rib_w/2)
          polygon(points=[[ diamond_W/2 - brace_W, 0], [-diamond_W/2 + brace_W, 0]]);
      }
}

// Spine eyelets (rings) along spine (connected to spine)
module spine_eyelets() {
  for (i = [0:spine_eyelet_count-1]) {
    zpos = -spine_L/2 + spine_eyelet_offset_from_end + i*spine_eyelet_spacing;
    translate([0, 0, zpos]) ring_y(spine_eyelet_OD, spine_eyelet_ID, thk, true);
  }
}

// Lightening slots in spine (do not break connectivity)
module spine_lightening_slots() {
  for (i = [0:spine_eyelet_count-2]) {
    zmid = -spine_L/2 + spine_eyelet_offset_from_end + (i+0.5)*spine_eyelet_spacing;
    translate([0, 0, zmid])
      cube([lighten_slot_W, thk + 2*overlap, lighten_slot_L], center=true);
  }
}

// -------------------- Final Model (ONE connected solid) --------------------
difference() {
  union() {
    // central vertical spine
    spine_box();

    // boss/cap at one end of spine
    boss_cap();

    // diamond loop at top end of spine
    diamond_loop();
    corner_eyelets();
    junction_webs();
    diamond_braces();

    // multiple eyelets along spine
    spine_eyelets();
  }

  // lightening cutouts
  spine_lightening_slots();
}
}

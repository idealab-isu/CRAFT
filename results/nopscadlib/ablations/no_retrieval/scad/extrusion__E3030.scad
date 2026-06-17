// Parameters
profile_W = 30; //[15:60:0.5]
profile_H = 30; //[15:60:0.5]
length_L = 100; //[50:200:1]
center_bore_d = 5; //[2:12:0.5]
slot_count = 4; //[1:8:1]
slot_opening_w = 6; //[3:12:0.5]
slot_depth = 8; //[4:16:0.5]
slot_neck_w = 3; //[1.5:8:0.5]
wall_t = 2; //[1:5:0.25]
chamfer_c = 1; //[0:3:0.25]
corner_r = 1.5; //[0:4:0.25]
lip_t = 0.8; //[0.2:2:0.1]
lip_inset = 1.2; //[0.2:4:0.1]
texture_depth = 0.2; //[0:0.8:0.05]
overlap_eps = 1; //[0.5:2:0.1]

// Base Shapes
module extrusion_body() {
  translate([0, 0, 0])
    cube([profile_W, profile_H, length_L], center=true);
}

module center_bore() {
  translate([0, 0, 0])
    cylinder(h=length_L + 2*overlap_eps, r=center_bore_d/2, center=true);
}

module t_slot_cut_posX() {
  linear_extrude(height=length_L + 2*overlap_eps, center=true)
    polygon(points=[
      [profile_W/2 - slot_depth - overlap_eps, -slot_opening_w/2],
      [profile_W/2 + overlap_eps, -slot_opening_w/2],
      [profile_W/2 + overlap_eps, slot_opening_w/2],
      [profile_W/2 - slot_depth - overlap_eps, slot_opening_w/2],
      [profile_W/2 - slot_depth - overlap_eps, slot_neck_w/2],
      [profile_W/2 - slot_depth/2, slot_neck_w/2],
      [profile_W/2 - slot_depth/2, -slot_neck_w/2],
      [profile_W/2 - slot_depth - overlap_eps, -slot_neck_w/2]
    ]);
}

module t_slot_cut_negX() {
  linear_extrude(height=length_L + 2*overlap_eps, center=true)
    polygon(points=[
      [-profile_W/2 + slot_depth + overlap_eps, -slot_opening_w/2],
      [-profile_W/2 - overlap_eps, -slot_opening_w/2],
      [-profile_W/2 - overlap_eps, slot_opening_w/2],
      [-profile_W/2 + slot_depth + overlap_eps, slot_opening_w/2],
      [-profile_W/2 + slot_depth + overlap_eps, slot_neck_w/2],
      [-profile_W/2 + slot_depth/2, slot_neck_w/2],
      [-profile_W/2 + slot_depth/2, -slot_neck_w/2],
      [-profile_W/2 + slot_depth + overlap_eps, -slot_neck_w/2]
    ]);
}

module t_slot_cut_posY() {
  linear_extrude(height=length_L + 2*overlap_eps, center=true)
    polygon(points=[
      [-slot_opening_w/2, profile_H/2 - slot_depth - overlap_eps],
      [-slot_opening_w/2, profile_H/2 + overlap_eps],
      [slot_opening_w/2, profile_H/2 + overlap_eps],
      [slot_opening_w/2, profile_H/2 - slot_depth - overlap_eps],
      [slot_neck_w/2, profile_H/2 - slot_depth - overlap_eps],
      [slot_neck_w/2, profile_H/2 - slot_depth/2],
      [-slot_neck_w/2, profile_H/2 - slot_depth/2],
      [-slot_neck_w/2, profile_H/2 - slot_depth - overlap_eps]
    ]);
}

module t_slot_cut_negY() {
  linear_extrude(height=length_L + 2*overlap_eps, center=true)
    polygon(points=[
      [-slot_opening_w/2, -profile_H/2 + slot_depth + overlap_eps],
      [-slot_opening_w/2, -profile_H/2 - overlap_eps],
      [slot_opening_w/2, -profile_H/2 - overlap_eps],
      [slot_opening_w/2, -profile_H/2 + slot_depth + overlap_eps],
      [slot_neck_w/2, -profile_H/2 + slot_depth + overlap_eps],
      [slot_neck_w/2, -profile_H/2 + slot_depth/2],
      [-slot_neck_w/2, -profile_H/2 + slot_depth/2],
      [-slot_neck_w/2, -profile_H/2 + slot_depth + overlap_eps]
    ]);
}

module edge_chamfers() {
  linear_extrude(height=length_L + 2*overlap_eps, center=true)
    polygon(points=[
      [-profile_W/2 - overlap_eps, -profile_H/2 - overlap_eps],
      [-profile_W/2 - overlap_eps, -profile_H/2 + chamfer_c],
      [-profile_W/2 + chamfer_c, -profile_H/2 - overlap_eps],
      [profile_W/2 - chamfer_c, -profile_H/2 - overlap_eps],
      [profile_W/2 + overlap_eps, -profile_H/2 + chamfer_c],
      [profile_W/2 + overlap_eps, -profile_H/2 - overlap_eps],
      [profile_W/2 + overlap_eps, profile_H/2 + overlap_eps],
      [profile_W/2 + overlap_eps, profile_H/2 - chamfer_c],
      [profile_W/2 - chamfer_c, profile_H/2 + overlap_eps],
      [-profile_W/2 + chamfer_c, profile_H/2 + overlap_eps],
      [-profile_W/2 - overlap_eps, profile_H/2 - chamfer_c],
      [-profile_W/2 - overlap_eps, profile_H/2 + overlap_eps]
    ]);
}

module manufacturer_specific_slot_lips_posX() {
  translate([profile_W/2 - (lip_inset + overlap_eps)/2, slot_opening_w/2 - lip_t/2, 0])
    cube([lip_inset + overlap_eps, lip_t, length_L], center=true);
}

module manufacturer_specific_slot_lips_posX_mirror() {
  translate([profile_W/2 - (lip_inset + overlap_eps)/2, -slot_opening_w/2 + lip_t/2, 0])
    cube([lip_inset + overlap_eps, lip_t, length_L], center=true);
}

module manufacturer_specific_slot_lips_negX() {
  translate([-profile_W/2 + (lip_inset + overlap_eps)/2, slot_opening_w/2 - lip_t/2, 0])
    cube([lip_inset + overlap_eps, lip_t, length_L], center=true);
}

module manufacturer_specific_slot_lips_negX_mirror() {
  translate([-profile_W/2 + (lip_inset + overlap_eps)/2, -slot_opening_w/2 + lip_t/2, 0])
    cube([lip_inset + overlap_eps, lip_t, length_L], center=true);
}

module manufacturer_specific_slot_lips_posY() {
  translate([slot_opening_w/2 - lip_t/2, profile_H/2 - (lip_inset + overlap_eps)/2, 0])
    cube([lip_t, lip_inset + overlap_eps, length_L], center=true);
}

module manufacturer_specific_slot_lips_posY_mirror() {
  translate([-slot_opening_w/2 + lip_t/2, profile_H/2 - (lip_inset + overlap_eps)/2, 0])
    cube([lip_t, lip_inset + overlap_eps, length_L], center=true);
}

module manufacturer_specific_slot_lips_negY() {
  translate([slot_opening_w/2 - lip_t/2, -profile_H/2 + (lip_inset + overlap_eps)/2, 0])
    cube([lip_t, lip_inset + overlap_eps, length_L], center=true);
}

module manufacturer_specific_slot_lips_negY_mirror() {
  translate([-slot_opening_w/2 + lip_t/2, -profile_H/2 + (lip_inset + overlap_eps)/2, 0])
    cube([lip_t, lip_inset + overlap_eps, length_L], center=true);
}

module corner_radii_kernel() {
  sphere(r=corner_r);
}

module surface_finish_texture() {
  translate([0, 0, length_L/2 - texture_depth/2])
    cylinder(h=texture_depth, r=max(profile_W, profile_H), center=true);
}

// Operations
module t_slot_channels() {
  union() {
    t_slot_cut_posX();
    t_slot_cut_negX();
    t_slot_cut_posY();
    t_slot_cut_negY();
  }
}

module extrusion_minus_bore() {
  difference() {
    extrusion_body();
    center_bore();
  }
}

module extrusion_minus_slots() {
  difference() {
    extrusion_minus_bore();
    t_slot_channels();
  }
}

module extrusion_minus_chamfers() {
  difference() {
    extrusion_minus_slots();
    edge_chamfers();
  }
}

module extrusion_with_lips() {
  union() {
    extrusion_minus_chamfers();
    manufacturer_specific_slot_lips_posX();
    manufacturer_specific_slot_lips_posX_mirror();
    manufacturer_specific_slot_lips_negX();
    manufacturer_specific_slot_lips_negX_mirror();
    manufacturer_specific_slot_lips_posY();
    manufacturer_specific_slot_lips_posY_mirror();
    manufacturer_specific_slot_lips_negY();
    manufacturer_specific_slot_lips_negY_mirror();
  }
}

module corner_radii() {
  minkowski() {
    extrusion_with_lips();
    corner_radii_kernel();
  }
}

module final_model() {
  union() {
    corner_radii();
    surface_finish_texture();
  }
}

// Render the final model
final_model();
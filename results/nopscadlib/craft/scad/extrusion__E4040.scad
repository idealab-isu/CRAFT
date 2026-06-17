// 40x40 T-slot aluminium extrusion profile, 100mm long
// One connected solid, standard-ish 40-series look (4 outer T-slots + center bore)

$fn = 96;

// Parameters
profile_width_mm  = 40.0;
profile_height_mm = 40.0;
length_mm         = 100.0;
center            = 1;

// Geometry controls (kept conservative so it always remains one connected solid)
corner_radius_mm        = 2.0;   // outer corner rounding
t_slot_opening_mm       = 8.2;   // opening at the face
t_slot_neck_mm          = 6.2;   // narrower neck inside
t_slot_depth_mm         = 10.0;  // depth from face toward center
t_slot_head_extra_mm    = 3.0;   // extra widening behind the neck (T-head)
center_bore_diameter_mm = 8.0;

overlap_mm = 0.25;

// Derived
W = profile_width_mm;
H = profile_height_mm;
L = length_mm;

slot_open = t_slot_opening_mm;
slot_neck = min(t_slot_neck_mm, slot_open - 0.2);
slot_d    = min(t_slot_depth_mm, min(W, H)/2 - 3.0);
head_extra = max(0, t_slot_head_extra_mm);

module rounded_rect_2d(w, h, r){
  r2 = min(r, min(w, h)/2);
  offset(r=r2) offset(delta=-r2) square([w, h], center=true);
}

module tslot_cut_2d(W, H, slot_open, slot_neck, slot_d, head_extra){
  // Builds 4 T-slot cutouts in 2D (to be linear_extruded along Z)
  union() {
    // +X face slot
    translate([ W/2 - slot_d/2, 0 ])
      square([slot_d + overlap_mm, slot_open], center=true);

    // -X face slot
    translate([-W/2 + slot_d/2, 0 ])
      square([slot_d + overlap_mm, slot_open], center=true);

    // +Y face slot
    translate([0,  H/2 - slot_d/2 ])
      square([slot_open, slot_d + overlap_mm], center=true);

    // -Y face slot
    translate([0, -H/2 + slot_d/2 ])
      square([slot_open, slot_d + overlap_mm], center=true);

    // T-head widening behind the neck (keeps a more typical T-slot look)
    // +X
    translate([ W/2 - (slot_d - head_extra)/2, 0 ])
      square([max(0.01, slot_d - head_extra) + overlap_mm, slot_neck], center=true);

    // -X
    translate([-W/2 + (slot_d - head_extra)/2, 0 ])
      square([max(0.01, slot_d - head_extra) + overlap_mm, slot_neck], center=true);

    // +Y
    translate([0,  H/2 - (slot_d - head_extra)/2 ])
      square([slot_neck, max(0.01, slot_d - head_extra) + overlap_mm], center=true);

    // -Y
    translate([0, -H/2 + (slot_d - head_extra)/2 ])
      square([slot_neck, max(0.01, slot_d - head_extra) + overlap_mm], center=true);
  }
}

module extrusion_40x40(){
  translate(center ? [0,0,0] : [W/2, H/2, L/2])
  color("Silver")
  difference() {
    // Outer body (rounded corners)
    linear_extrude(height=L, center=true, convexity=10)
      rounded_rect_2d(W, H, corner_radius_mm);

    // 4 T-slots (cut through full length)
    linear_extrude(height=L + 2*overlap_mm, center=true, convexity=10)
      tslot_cut_2d(W, H, slot_open, slot_neck, slot_d, head_extra);

    // Center bore along Z
    cylinder(d=center_bore_diameter_mm, h=L + 2*overlap_mm, center=true);
  }
}

extrusion_40x40();
// Pillow block bearing (KP001-like) for 12mm shaft, 71x56 base
// One connected solid; all placements are formula-based.

// ---------- Parameters ----------
shaft_diameter = 12;                 //[6:24:0.5]
base_length = 71;                    //[35.5:142:0.5]
base_width  = 56;                    //[28:112:0.5]
base_thickness = 10;                 //[5:20:0.5]

mount_hole_spacing = 54;             //[35:110:0.5]  // center-to-center along length (X)
mount_hole_diameter = 8;             //[4:14:0.5]
mount_slot_length = 14;              //[8:24:0.5]    // elongated slots typical of pillow blocks

shaft_center_height_above_base = 25; //[12:50:0.5]

housing_length = 50;                 //[30:90:0.5]
housing_width  = 34;                 //[20:70:0.5]
housing_height_above_base_top = 22;  //[10:50:0.5]

fillet_radius = 2;                   //[0.5:6:0.5]
bore_clearance = 0.3;                //[0:1:0.05]
overlap = 1;                         //[0.5:2:0.1]

trapezoid_top_scale = 0.65;          //[0.4:0.9:0.05]
trapezoid_height = 16;               //[8:35:0.5]

// ---------- Derived ----------
bore_r = (shaft_diameter + bore_clearance)/2;

// Boss around bore (along Y)
outer_boss_r = max(shaft_diameter*1.6, housing_height_above_base_top*0.55);
outer_boss_len = housing_width + 2*overlap;

// Ensure slots stay inside base footprint
slot_len_eff = min(mount_slot_length, base_length - mount_hole_diameter - 2);
slot_spacing_eff = min(mount_hole_spacing, base_length - slot_len_eff - 2);

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1) {
  minkowski() {
    cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=true);
    sphere(r=r, $fn=32);
  }
}

module slot_hole_2d(len, dia) {
  hull() {
    translate([-len/2, 0]) circle(d=dia, $fn=64);
    translate([ len/2, 0]) circle(d=dia, $fn=64);
  }
}

module mounting_slots_cut() {
  // Two elongated slots through base, centered on width (Y=0), along X
  for (sx = [-1, 1]) {
    translate([sx*slot_spacing_eff/2, 0, base_thickness/2])
      linear_extrude(height=base_thickness + 6*overlap, center=true)
        slot_hole_2d(slot_len_eff, mount_hole_diameter);
  }
}

module bore_cut() {
  // Through bore along Y (typical pillow block)
  translate([0, 0, shaft_center_height_above_base])
    rotate([90, 0, 0])
      cylinder(r=bore_r, h=base_width + housing_width + 12*overlap, center=true, $fn=128);
}

module grease_nipple_boss() {
  boss_d = 10;
  boss_h = 6;
  // Place on top of housing, slightly forward in Y; overlap into housing
  translate([0,
             (housing_width/2 - boss_d/2 - overlap),
             (base_thickness + housing_height_above_base_top) + boss_h/2 - overlap])
    cylinder(d=boss_d, h=boss_h, center=true, $fn=64);
}

module gussets() {
  // Two side gussets connecting base to housing (along Y)
  gusset_th = (base_width - housing_width)/2;
  gusset_th_eff = max(2, gusset_th);

  for (sy = [-1, 1]) {
    translate([0,
               sy*(housing_width/2 + gusset_th_eff/2 - overlap),
               base_thickness - overlap])
      rotate([90, 0, 0])
        linear_extrude(height=gusset_th_eff, center=true)
          polygon(points=[
            [-housing_length/2, 0],
            [ housing_length/2, 0],
            [ housing_length/2*trapezoid_top_scale, trapezoid_height],
            [-housing_length/2*trapezoid_top_scale, trapezoid_height]
          ]);
  }
}

module body_solid() {
  union() {
    // Base (exact footprint 71 x 56)
    translate([0, 0, base_thickness/2])
      cube([base_length, base_width, base_thickness], center=true);

    // Main housing block (rounded) - sits on base with overlap
    translate([0, 0, base_thickness + housing_height_above_base_top/2 - overlap])
      rounded_box([housing_length, housing_width, housing_height_above_base_top], r=fillet_radius);

    // Outer bearing boss (cylindrical bulge around bore) - intersects housing
    translate([0, 0, shaft_center_height_above_base])
      rotate([90, 0, 0])
        cylinder(r=outer_boss_r, h=outer_boss_len, center=true, $fn=160);

    // Gussets for KP-style look and strong connection
    gussets();

    // Small top boss (grease nipple base)
    grease_nipple_boss();
  }
}

// ---------- Final ----------
difference() {
  body_solid();
  mounting_slots_cut();
  bore_cut();
}
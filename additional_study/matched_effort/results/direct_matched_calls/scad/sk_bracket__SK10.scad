$fn=96;

// Parameters
rod_d = 10.0;
height = 20.0;

clearance = 0.3;          // rod clearance
base_len = 40.0;
base_w   = 20.0;
base_th  = 6.0;

wall = 4.0;               // side wall thickness around bore
cap_th = 4.0;             // top cap thickness
slot_w = 2.5;             // clamp slit width

bolt_d = 5.2;             // M5 clearance
bolt_head_d = 9.5;        // socket head counterbore
bolt_head_h = 4.0;

mount_hole_d = 5.2;       // base mounting holes (M5)
mount_csk_d  = 10.0;      // counterbore diameter
mount_csk_h  = 3.0;

bore_d = rod_d + clearance;
outer_d = bore_d + 2*wall;

center_x = base_len/2;
center_y = base_w/2;
bore_z0 = base_th;
bore_z1 = base_th + height;

module bracket() {
  difference() {
    union() {
      // Base
      translate([0,0,0]) cube([base_len, base_w, base_th], center=false);

      // Upright body (cylindrical support)
      translate([center_x, center_y, bore_z0])
        cylinder(h=height, d=outer_d);

      // Top cap (adds material above bore for clamp)
      translate([center_x, center_y, bore_z1])
        cylinder(h=cap_th, d=outer_d);
    }

    // Rod bore through upright + cap
    translate([center_x, center_y, bore_z0 - 0.5])
      cylinder(h=height + cap_th + 1.0, d=bore_d);

    // Clamp slit (front-to-back)
    translate([center_x - outer_d/2 - 1, center_y - slot_w/2, bore_z0 - 0.5])
      cube([outer_d + 2, slot_w, height + cap_th + 1.0], center=false);

    // Clamp bolt hole (left-to-right) through cap region
    bolt_z = bore_z1 + cap_th/2;
    translate([center_x, center_y, bolt_z])
      rotate([0,90,0])
        cylinder(h=base_len + 2, d=bolt_d, center=true);

    // Counterbore for bolt head on right side
    translate([center_x + outer_d/2 - 0.2, center_y, bolt_z])
      rotate([0,90,0])
        cylinder(h=bolt_head_h + 1.0, d=bolt_head_d, center=false);

    // Base mounting holes (2x), with shallow counterbores
    hole_offset_x = 12.0;
    for (sx = [-1, 1]) {
      hx = center_x + sx*hole_offset_x;
      hy = center_y;
      // Through hole
      translate([hx, hy, -0.5])
        cylinder(h=base_th + 1.0, d=mount_hole_d);
      // Counterbore
      translate([hx, hy, base_th - mount_csk_h])
        cylinder(h=mount_csk_h + 0.6, d=mount_csk_d);
    }

    // Flat on bottom of upright to blend into base (optional relief)
    // (keeps base top mostly flat around cylinder)
    translate([0,0,base_th])
      cube([base_len, base_w, 0.01], center=false);
  }
}

bracket();
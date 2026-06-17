// Parameters
L = 85.07; //[42.535:170.14:0.01]
W = 22.45; //[11.225:44.9:0.01]
H = 10.44; //[5.22:20.88:0.01]
plate_t = 3.2; //[1.6:6.4:0.01]
end_chamfer_len = 4; //[2:8:0.01]
prong_w = 8; //[4:16:0.01]
prong_l = 10; //[5:20:0.01]
prong_h = 7.24; //[3.62:14.48:0.01]
prong_offset_from_end = 18; //[9:36:0.01]
prong_spacing = 34; //[17:68:0.01]
step_len = 2; //[1:4:0.01]
step_drop = 1.2; //[0.6:2.4:0.01]
step_setback_from_tip = 1; //[0.5:2:0.01]
overlap = 0.8; //[0.5:2:0.01]
relief_chamfer = 0.8; //[0.4:1.6:0.01]
fillet_r = 0.6; //[0.3:1.2:0.01]

// Base Shapes
module main_bar_plate() {
  translate([0, 0, 0])
    cube([L, W, plate_t], center=true);
}

module end_chamfer_left() {
  translate([-L/2 + end_chamfer_len/2, 0, 0])
    rotate([0, 0, 45])
      cube([end_chamfer_len, W, plate_t + 2*overlap], center=true);
}

module end_chamfer_right() {
  translate([L/2 - end_chamfer_len/2, 0, 0])
    rotate([0, 0, 45])
      cube([end_chamfer_len, W, plate_t + 2*overlap], center=true);
}

module prong_1() {
  translate([-L/2 + prong_offset_from_end, 0, plate_t/2 + prong_h/2 - overlap])
    cube([prong_l, prong_w, prong_h], center=true);
}

module prong_2() {
  translate([-L/2 + prong_offset_from_end + prong_spacing, 0, plate_t/2 + prong_h/2 - overlap])
    cube([prong_l, prong_w, prong_h], center=true);
}

module prong_1_end_step() {
  translate([(-L/2 + prong_offset_from_end) + (prong_l/2 - step_setback_from_tip - step_len/2), 0, plate_t/2 + (prong_h - step_drop)/2 - overlap])
    cube([step_len, prong_w + 2*overlap, prong_h - step_drop + 2*overlap], center=true);
}

module prong_2_end_step() {
  translate([(-L/2 + prong_offset_from_end + prong_spacing) + (prong_l/2 - step_setback_from_tip - step_len/2), 0, plate_t/2 + (prong_h - step_drop)/2 - overlap])
    cube([step_len, prong_w + 2*overlap, prong_h - step_drop + 2*overlap], center=true);
}

module small_relief_chamfers_on_prongs() {
  translate([(-L/2 + prong_offset_from_end) + (prong_l/2 - relief_chamfer/2), 0, plate_t/2 + prong_h/2 - overlap])
    rotate([0, 0, 45])
      cube([relief_chamfer, prong_w + 2*overlap, prong_h + 2*overlap], center=true);
}

module surface_markings() {
  translate([0, 0, plate_t/2 - (plate_t/10)/2])
    cube([L/3, W/3, plate_t/10], center=true);
}

module edge_fillets() {
  sphere(r=fillet_r, center=true);
}

// Operations
module plate_chamfered() {
  difference() {
    main_bar_plate();
    end_chamfer_left();
    end_chamfer_right();
  }
}

module prongs_union() {
  union() {
    prong_1();
    prong_2();
  }
}

module prongs_with_steps() {
  difference() {
    prongs_union();
    prong_1_end_step();
    prong_2_end_step();
  }
}

module relief_chamfer_prong2_pos() {
  translate([prong_spacing, 0, 0])
    small_relief_chamfers_on_prongs();
}

module prongs_with_steps_and_reliefs() {
  difference() {
    prongs_with_steps();
    small_relief_chamfers_on_prongs();
    relief_chamfer_prong2_pos();
  }
}

module plate_and_prongs() {
  union() {
    plate_chamfered();
    prongs_with_steps_and_reliefs();
  }
}

module edge_fillets_applied() {
  minkowski() {
    plate_and_prongs();
    edge_fillets();
  }
}

module final_model() {
  difference() {
    edge_fillets_applied();
    surface_markings();
  }
}

// Final Output
final_model();
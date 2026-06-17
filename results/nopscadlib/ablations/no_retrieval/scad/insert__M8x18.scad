// Parameters
OD = 18.0; //[9.0:36.0:0.1]
L = 16.0; //[8.0:32.0:0.1]
screw_d = 8.0; //[4.0:16.0:0.1]
thread_pitch = 1.25; //[0.5:2.5:0.05]
thread_class_clearance = 0.2; //[0.0:0.6:0.05]
bore_d_minor = 6.8; //[3.4:13.6:0.05]
knurl_depth = 0.6; //[0.2:1.2:0.05]
knurl_pitch = 1.2; //[0.6:2.4:0.05]
chamfer = 0.5; //[0.2:1.5:0.05]
overlap = 0.8; //[0.2:2.0:0.1]
knurl_ring_h = 0.6; //[0.3:1.5:0.05]
knurl_count = 10; //[4:30:1]
lead_in_len = 2.5; //[1.0:6.0:0.1]
relief_w = 1.2; //[0.6:3.0:0.1]
relief_depth = 0.4; //[0.2:1.0:0.05]
mark_w = 2.0; //[1.0:5.0:0.1]
mark_d = 0.3; //[0.1:1.0:0.05]

// Base Shapes
module insert_body() {
  cylinder(h=L, r=OD/2, center=true);
}

module internal_thread_bore() {
  cylinder(h=L + 2*overlap, r=bore_d_minor/2, center=true);
}

module chamfer_top_cone() {
  translate([0, 0, L/2 - (chamfer + overlap)/2])
    cylinder(h=chamfer + overlap, r1=OD/2, r2=OD/2 - chamfer, center=true);
}

module chamfer_bottom_cone() {
  translate([0, 0, -L/2 + (chamfer + overlap)/2])
    cylinder(h=chamfer + overlap, r1=OD/2 - chamfer, r2=OD/2, center=true);
}

module thread_lead_in_taper_top() {
  translate([0, 0, L/2 - (lead_in_len + overlap)/2])
    cylinder(h=lead_in_len + overlap, r1=(screw_d + thread_class_clearance)/2, r2=bore_d_minor/2, center=true);
}

module thread_lead_in_taper_bottom() {
  translate([0, 0, -L/2 + (lead_in_len + overlap)/2])
    cylinder(h=lead_in_len + overlap, r1=bore_d_minor/2, r2=(screw_d + thread_class_clearance)/2, center=true);
}

module internal_thread_relief_groove() {
  cylinder(h=relief_w + 2*overlap, r=(bore_d_minor/2) + relief_depth, center=true);
}

module end_face_marking() {
  translate([0, 0, L/2 - (mark_d + overlap)/2])
    cube([mark_w, OD, mark_d + overlap], center=true);
}

module knurl_ring(pos) {
  translate([0, 0, pos])
    cylinder(h=knurl_ring_h, r=OD/2 + knurl_depth, center=true);
}

// Operations
module external_heatset_knurl() {
  union() {
    for (i = [0:knurl_count-1]) {
      knurl_ring(-L/2 + chamfer + knurl_ring_h/2 + i*knurl_pitch);
    }
  }
}

module body_with_knurl() {
  union() {
    insert_body();
    external_heatset_knurl();
  }
}

module end_chamfers() {
  union() {
    chamfer_top_cone();
    chamfer_bottom_cone();
  }
}

module body_with_knurl_and_chamfers() {
  difference() {
    body_with_knurl();
    end_chamfers();
  }
}

module thread_lead_in_taper() {
  union() {
    thread_lead_in_taper_top();
    thread_lead_in_taper_bottom();
  }
}

module internal_voids() {
  union() {
    internal_thread_bore();
    thread_lead_in_taper();
    internal_thread_relief_groove();
  }
}

module body_after_bore() {
  difference() {
    body_with_knurl_and_chamfers();
    internal_voids();
  }
}

module final_model() {
  difference() {
    body_after_bore();
    end_face_marking();
  }
}

// Final Output
final_model();
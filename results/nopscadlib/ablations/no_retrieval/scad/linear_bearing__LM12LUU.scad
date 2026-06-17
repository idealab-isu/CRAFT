// Parameters
bore_d = 12.0; //[6.0:24.0:0.1]
outer_d = 21.0; //[10.5:42.0:0.1]
length = 57.0; //[28.5:114.0:0.5]
chamfer = 0.5; //[0.2:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
seal_groove_width = 2.0; //[1.0:5.0:0.1]
seal_groove_depth = 0.6; //[0.2:1.5:0.1]
seal_groove_offset = 3.0; //[1.0:10.0:0.1]
track_count = 6; //[3:10:1]
track_width = 2.0; //[1.0:4.0:0.1]
track_depth = 0.4; //[0.1:1.2:0.1]
track_length_margin = 6.0; //[2.0:15.0:0.5]
marking_depth = 0.2; //[0.1:0.8:0.05]
marking_width = 6.0; //[2.0:15.0:0.5]

// Base Shapes
module outer_cylinder_body() {
  cylinder(h=length, r=outer_d/2, center=true);
}

module through_bore() {
  cylinder(h=length + 2*overlap, r=bore_d/2, center=true);
}

module end_face_chamfer_top() {
  translate([0, 0, length/2 - (chamfer + overlap)/2])
    cylinder(h=chamfer + overlap, r1=outer_d/2, r2=outer_d/2 - chamfer, center=true);
}

module end_face_chamfer_bottom() {
  translate([0, 0, -length/2 + (chamfer + overlap)/2])
    cylinder(h=chamfer + overlap, r1=outer_d/2, r2=outer_d/2 - chamfer, center=true);
}

module seal_groove_top() {
  translate([0, 0, length/2 - seal_groove_offset])
    cylinder(h=seal_groove_width, r=outer_d/2, center=true);
}

module seal_groove_bottom() {
  translate([0, 0, -length/2 + seal_groove_offset])
    cylinder(h=seal_groove_width, r=outer_d/2, center=true);
}

module ball_track_cut(i) {
  rotate([0, 0, i*360/track_count])
    translate([bore_d/2 - track_depth/2, 0, 0])
      cube([bore_d + 2*track_depth + 2*overlap, track_width, length - 2*track_length_margin], center=true);
}

module manufacturer_markings_band() {
  cylinder(h=marking_width, r=outer_d/2, center=true);
}

// Operations
module seal_grooves() {
  difference() {
    union() {
      seal_groove_top();
      seal_groove_bottom();
    }
    through_bore();
  }
}

module seal_grooves_scaled() {
  scale([(outer_d - 2*seal_groove_depth)/outer_d, (outer_d - 2*seal_groove_depth)/outer_d, 1])
    seal_grooves();
}

module end_face_chamfers() {
  union() {
    end_face_chamfer_top();
    end_face_chamfer_bottom();
  }
}

module ball_track_detail() {
  union() {
    for (i = [0:track_count-1])
      ball_track_cut(i);
  }
}

module manufacturer_markings() {
  scale([(outer_d - 2*marking_depth)/outer_d, (outer_d - 2*marking_depth)/outer_d, 1])
    manufacturer_markings_band();
}

// Final Output
difference() {
  outer_cylinder_body();
  through_bore();
  end_face_chamfers();
  seal_grooves_scaled();
  ball_track_detail();
  manufacturer_markings();
}
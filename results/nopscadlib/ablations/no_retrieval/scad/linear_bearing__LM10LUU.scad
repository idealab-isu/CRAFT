// Parameters
bearing_L = 55.0; //[27.5:110.0:0.5]
bearing_OD = 19.0; //[9.5:38.0:0.1]
bearing_ID = 10.0; //[5.0:20.0:0.1]
chamfer = 0.5; //[0.25:2.0:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
track_count = 6; //[4:10:1]
track_radius = 0.8; //[0.4:1.6:0.05]
track_depth_offset = 1.2; //[0.6:2.4:0.1]
cage_thickness = 0.8; //[0.4:1.6:0.05]
cage_length = 45.0; //[20.0:100.0:0.5]
seal_lip_length = 2.0; //[1.0:5.0:0.1]
seal_lip_radial = 0.6; //[0.3:1.5:0.05]
lube_groove_width = 1.2; //[0.6:3.0:0.1]
lube_groove_depth = 0.6; //[0.3:1.5:0.05]

// Base Shapes
module outer_cylinder_body() {
  cylinder(h=bearing_L, r=bearing_OD/2, center=true);
}

module through_bore() {
  cylinder(h=bearing_L + 2*overlap, r=bearing_ID/2, center=true);
}

module end_face_chamfer_pos() {
  translate([0, 0, bearing_L/2 - (chamfer + overlap)/2])
    cylinder(h=chamfer + overlap, r1=bearing_OD/2, r2=0, center=true);
}

module end_face_chamfer_neg() {
  translate([0, 0, -bearing_L/2 + (chamfer + overlap)/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer + overlap, r1=bearing_OD/2, r2=0, center=true);
}

module ball_track(i) {
  angle = 360/track_count * i;
  x = (bearing_OD/2 - track_depth_offset) * cos(angle);
  y = (bearing_OD/2 - track_depth_offset) * sin(angle);
  translate([x, y, 0])
    rotate([0, 90, angle])
    cylinder(h=bearing_L + 2*overlap, r=track_radius, center=true);
}

module retainer_cage_outer() {
  cylinder(h=cage_length, r=bearing_ID/2 + cage_thickness, center=true);
}

module retainer_cage_inner() {
  cylinder(h=cage_length + 2*overlap, r=bearing_ID/2 + overlap*0.2, center=true);
}

module seal_lip_pos_outer() {
  translate([0, 0, bearing_L/2 - seal_lip_length/2 + overlap*0.5])
    cylinder(h=seal_lip_length, r=bearing_ID/2 + seal_lip_radial, center=true);
}

module seal_lip_pos_inner() {
  translate([0, 0, bearing_L/2 - seal_lip_length/2 + overlap*0.5])
    cylinder(h=seal_lip_length + 2*overlap, r=bearing_ID/2, center=true);
}

module seal_lip_neg_outer() {
  translate([0, 0, -bearing_L/2 + seal_lip_length/2 - overlap*0.5])
    cylinder(h=seal_lip_length, r=bearing_ID/2 + seal_lip_radial, center=true);
}

module seal_lip_neg_inner() {
  translate([0, 0, -bearing_L/2 + seal_lip_length/2 - overlap*0.5])
    cylinder(h=seal_lip_length + 2*overlap, r=bearing_ID/2, center=true);
}

module lubrication_groove_cutter() {
  cylinder(h=lube_groove_width + 2*overlap, r=bearing_OD/2 - lube_groove_depth, center=true);
}

// Operations
module retainer_cage_detail() {
  difference() {
    retainer_cage_outer();
    retainer_cage_inner();
  }
}

module seal_lip_pos() {
  difference() {
    seal_lip_pos_outer();
    seal_lip_pos_inner();
  }
}

module seal_lip_neg() {
  difference() {
    seal_lip_neg_outer();
    seal_lip_neg_inner();
  }
}

module seal_lips() {
  union() {
    seal_lip_pos();
    seal_lip_neg();
  }
}

module bearing_outer_with_lube_groove() {
  difference() {
    outer_cylinder_body();
    lubrication_groove_cutter();
  }
}

module bearing_outer_with_chamfers() {
  difference() {
    bearing_outer_with_lube_groove();
    end_face_chamfer_pos();
    end_face_chamfer_neg();
  }
}

module bearing_outer_with_tracks() {
  difference() {
    bearing_outer_with_chamfers();
    for (i = [0:track_count-1]) {
      ball_track(i);
    }
  }
}

module bearing_sleeve_hollow() {
  difference() {
    bearing_outer_with_tracks();
    through_bore();
  }
}

module bearing_complete_union() {
  union() {
    bearing_sleeve_hollow();
    retainer_cage_detail();
    seal_lips();
  }
}

// Final Output
color("Silver") bearing_complete_union();
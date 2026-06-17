// Parameters
bore_d = 16; //[8:32:0.1]
od_d = 28; //[14:56:0.1]
length = 37; //[18.5:74:0.1]
chamfer_len = 0.8; //[0.4:1.6:0.05]
overlap = 1; //[0.5:2:0.1]
seal_groove_width = 2.2; //[1.1:4.4:0.1]
seal_groove_depth = 0.6; //[0.3:1.2:0.05]
seal_groove_offset = 3; //[1.5:6:0.1]
mark_band_width = 6; //[3:12:0.1]
mark_band_depth = 0.15; //[0.05:0.4:0.01]
track_count = 6; //[4:8:1]
track_radius = 1.2; //[0.6:2.4:0.05]
track_length = 30; //[15:60:0.1]
track_inset = 0.6; //[0.2:1.5:0.05]

// Base Shapes
module outer_cylinder_body() {
  cylinder(h=length, r=od_d/2, center=true);
}

module through_bore() {
  cylinder(h=length + 2*overlap, r=bore_d/2, center=true);
}

module end_chamfer_cutter_pos() {
  translate([0, 0, length/2 - chamfer_len/2 + overlap/2])
    cylinder(h=chamfer_len, r1=od_d/2, r2=od_d/2 - chamfer_len, center=true);
}

module end_chamfer_cutter_neg() {
  translate([0, 0, -length/2 + chamfer_len/2 - overlap/2])
    cylinder(h=chamfer_len, r1=od_d/2 - chamfer_len, r2=od_d/2, center=true);
}

module seal_groove_cutter_pos() {
  translate([0, 0, length/2 - seal_groove_offset])
    cylinder(h=seal_groove_width, r=od_d/2, center=true);
}

module seal_groove_cutter_neg() {
  translate([0, 0, -length/2 + seal_groove_offset])
    cylinder(h=seal_groove_width, r=od_d/2, center=true);
}

module marking_band_cutter() {
  cylinder(h=mark_band_width, r=od_d/2, center=true);
}

module track_cutter_base() {
  translate([bore_d/2 + track_radius - track_inset, 0, 0])
    rotate([90, 0, 0])
    cylinder(h=track_length + 2*overlap, r=track_radius, center=true);
}

module seal_groove_depth_inner() {
  cylinder(h=length + 2*overlap, r=od_d/2 - seal_groove_depth, center=true);
}

module mark_band_depth_inner() {
  cylinder(h=length + 2*overlap, r=od_d/2 - mark_band_depth, center=true);
}

// Operations
module end_chamfers() {
  union() {
    end_chamfer_cutter_pos();
    end_chamfer_cutter_neg();
  }
}

module seal_grooves() {
  union() {
    seal_groove_cutter_pos();
    seal_groove_cutter_neg();
  }
}

module internal_ball_tracks_detail() {
  union() {
    for (i = [0:track_count-1]) {
      rotate([0, 0, i*360/track_count])
        track_cutter_base();
    }
  }
}

module seal_groove_depth_shell() {
  difference() {
    outer_cylinder_body();
    seal_groove_depth_inner();
  }
}

module mark_band_depth_shell() {
  difference() {
    outer_cylinder_body();
    mark_band_depth_inner();
  }
}

module seal_groove_depth_region() {
  intersection() {
    seal_groove_depth_shell();
    seal_grooves();
  }
}

module mark_band_depth_region() {
  intersection() {
    mark_band_depth_shell();
    marking_band_cutter();
  }
}

// Final Model
module complete_model() {
  difference() {
    outer_cylinder_body();
    through_bore();
    end_chamfers();
    internal_ball_tracks_detail();
    seal_groove_depth_region();
    mark_band_depth_region();
  }
}

// Render the complete model
color("Silver") complete_model();
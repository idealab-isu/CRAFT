// Parameters
bore_d = 8.0; //[4.0:16.0:0.1]
outer_d = 15.0; //[8.0:30.0:0.1]
length = 24.0; //[12.0:48.0:0.1]
chamfer_len = 0.5; //[0.2:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
seal_groove_width = 1.2; //[0.6:3.0:0.1]
seal_groove_depth = 0.4; //[0.2:1.2:0.1]
seal_groove_offset = 2.0; //[1.0:6.0:0.1]
mark_band_width = 4.0; //[2.0:10.0:0.1]
mark_band_depth = 0.15; //[0.05:0.5:0.01]
track_count = 6; //[4:10:1]
track_width = 1.2; //[0.6:2.5:0.1]
track_depth = 0.35; //[0.15:1.0:0.05]

// Base Shapes
module outer_cylinder_body() {
  cylinder(h=length, r=outer_d/2, center=true);
}

module through_bore() {
  cylinder(h=length + 2*overlap, r=bore_d/2, center=true);
}

module end_chamfer_cone_pos() {
  translate([0, 0, length/2 - (chamfer_len + overlap)/2])
    cylinder(h=chamfer_len + overlap, r1=outer_d/2, r2=0, center=true);
}

module end_chamfer_cone_neg() {
  translate([0, 0, -length/2 + (chamfer_len + overlap)/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_len + overlap, r1=outer_d/2, r2=0, center=true);
}

module seal_groove_cyl_pos() {
  translate([0, 0, length/2 - seal_groove_offset])
    cylinder(h=seal_groove_width + 2*overlap, r=outer_d/2, center=true);
}

module seal_groove_cyl_neg() {
  translate([0, 0, -length/2 + seal_groove_offset])
    cylinder(h=seal_groove_width + 2*overlap, r=outer_d/2, center=true);
}

module mark_band_cyl() {
  cylinder(h=mark_band_width + 2*overlap, r=outer_d/2, center=true);
}

module internal_track_box_base() {
  translate([bore_d/2 - overlap + (track_depth + overlap)/2, 0, 0])
    cube([track_depth + overlap, track_width, length + 2*overlap], center=true);
}

// Operations
module end_chamfers_union() {
  union() {
    end_chamfer_cone_pos();
    end_chamfer_cone_neg();
  }
}

module seal_grooves_union() {
  union() {
    seal_groove_cyl_pos();
    seal_groove_cyl_neg();
  }
}

module seal_grooves_shell() {
  difference() {
    seal_grooves_union();
    through_bore();
    outer_cylinder_body();
  }
}

module mark_band_shell() {
  difference() {
    mark_band_cyl();
    through_bore();
    outer_cylinder_body();
  }
}

module internal_ball_tracks_representation() {
  union() {
    for (i = [0:track_count-1]) {
      rotate([0, 0, i*360/track_count])
        internal_track_box_base();
    }
  }
}

module bearing_final() {
  difference() {
    difference() {
      difference() {
        difference() {
          difference() {
            outer_cylinder_body();
            mark_band_shell();
          }
          end_chamfers_union();
        }
        seal_grooves_shell();
      }
      through_bore();
    }
    internal_ball_tracks_representation();
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
bearing_final();
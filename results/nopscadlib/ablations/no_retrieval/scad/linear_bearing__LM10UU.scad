// Parameters
bore_d = 10; //[5:20:0.1]
outer_d = 19; //[10:38:0.1]
length = 29; //[15:58:0.1]
chamfer = 0.5; //[0.2:2:0.1]
eps = 0.8; //[0.5:2:0.1]
seal_groove_width = 1.2; //[0.6:2.4:0.1]
seal_groove_depth = 0.6; //[0.3:1.5:0.1]
seal_groove_offset = 2; //[1:5:0.1]
channel_count = 6; //[4:8:1]
channel_d = 3; //[2:5:0.1]
channel_radial_pos = 6.5; //[5.5:8:0.1]

// Base Shapes
module outer_cylindrical_body() {
  cylinder(h=length, r=outer_d/2, center=true);
}

module through_bore() {
  cylinder(h=length + 2*eps, r=bore_d/2, center=true);
}

module end_face_chamfer_cone_pos() {
  translate([0, 0, length/2 - chamfer/2 + eps/2])
    cylinder(h=chamfer, r1=outer_d/2, r2=0, center=true);
}

module end_face_chamfer_cone_neg() {
  translate([0, 0, -length/2 + chamfer/2 - eps/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer, r1=outer_d/2, r2=0, center=true);
}

module seal_groove_cyl_pos() {
  translate([0, 0, length/2 - seal_groove_offset])
    cylinder(h=seal_groove_width + 2*eps, r=outer_d/2, center=true);
}

module seal_groove_cyl_neg() {
  translate([0, 0, -length/2 + seal_groove_offset])
    cylinder(h=seal_groove_width + 2*eps, r=outer_d/2, center=true);
}

module seal_groove_inner_cyl_pos() {
  translate([0, 0, length/2 - seal_groove_offset])
    cylinder(h=seal_groove_width + 2*eps, r=outer_d/2 - seal_groove_depth, center=true);
}

module seal_groove_inner_cyl_neg() {
  translate([0, 0, -length/2 + seal_groove_offset])
    cylinder(h=seal_groove_width + 2*eps, r=outer_d/2 - seal_groove_depth, center=true);
}

module channel_cyl(angle) {
  translate([channel_radial_pos*cos(angle), channel_radial_pos*sin(angle), 0])
    cylinder(h=length + 2*eps, r=channel_d/2, center=true);
}

// Operations
module ball_return_channels() {
  union() {
    for (i = [0:channel_count-1]) {
      channel_cyl(360/channel_count*i);
    }
  }
}

module end_face_chamfers() {
  union() {
    end_face_chamfer_cone_pos();
    end_face_chamfer_cone_neg();
  }
}

module seal_groove_ring_pos() {
  difference() {
    seal_groove_cyl_pos();
    seal_groove_inner_cyl_pos();
  }
}

module seal_groove_ring_neg() {
  difference() {
    seal_groove_cyl_neg();
    seal_groove_inner_cyl_neg();
  }
}

module seal_grooves() {
  union() {
    seal_groove_ring_pos();
    seal_groove_ring_neg();
  }
}

module bearing_sleeve_raw() {
  difference() {
    outer_cylindrical_body();
    through_bore();
  }
}

module bearing_with_chamfers() {
  difference() {
    bearing_sleeve_raw();
    end_face_chamfers();
  }
}

module bearing_with_seal_grooves() {
  difference() {
    bearing_with_chamfers();
    seal_grooves();
  }
}

module bearing_complete() {
  difference() {
    bearing_with_seal_grooves();
    ball_return_channels();
  }
}

// Final Output
bearing_complete();
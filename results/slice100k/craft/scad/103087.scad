// Parameters
L = 54.99; //[27.5:110.0:0.01]
W = 16.58; //[8.29:33.16:0.01]
H = 20.11; //[10.06:40.22:0.01]
end_relief_len = 4.0; //[2.0:8.0:0.1]
end_chamfer = 2.0; //[0.5:4.0:0.1]
hex_AF = 8.0; //[4.0:16.0:0.1]
hex_axis_offset_L = 0.0; //[-10.0:10.0:0.1]
csk_depth = 1.2; //[0.4:3.0:0.1]
csk_extra_AF = 2.0; //[0.5:6.0:0.1]
csk_angle_deg = 90; //[60:120:1]
overlap = 1.0; //[0.5:2.0:0.1]
fillet_r = 0.6; //[0.0:2.0:0.1]
small_chamfer = 0.4; //[0.0:1.5:0.1]

// Base Shapes
module main_bar_body() {
  cube([L, W, H], center=true);
}

module end_relief_wedge(size, pos) {
  translate(pos)
    cube(size, center=true);
}

module hex_through_hole() {
  translate([hex_axis_offset_L, 0, 0])
    linear_extrude(height=H + 2*overlap, center=true)
      polygon(points=[
        [(hex_AF/2)/cos(30), 0],
        [(hex_AF/2)/cos(30)*cos(60), (hex_AF/2)/cos(30)*sin(60)],
        [-(hex_AF/2)/cos(30)*cos(60), (hex_AF/2)/cos(30)*sin(60)],
        [-(hex_AF/2)/cos(30), 0],
        [-(hex_AF/2)/cos(30)*cos(60), -(hex_AF/2)/cos(30)*sin(60)],
        [(hex_AF/2)/cos(30)*cos(60), -(hex_AF/2)/cos(30)*sin(60)]
      ]);
}

module csk_cone(pos, rot) {
  translate(pos)
    rotate(rot)
      cylinder(h=csk_depth + overlap, r1=(hex_AF + csk_extra_AF)/2/cos(30), r2=0, center=true);
}

module small_face_chamfer_cut(pos) {
  translate(pos)
    cube([L + overlap, small_chamfer*2, small_chamfer*2], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module end_corner_reliefs_both_ends() {
  difference() {
    main_bar_body();
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [-L/2 + (end_relief_len + overlap)/2 - overlap/2, W/2 - end_chamfer, H/2 - end_chamfer]);
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [-L/2 + (end_relief_len + overlap)/2 - overlap/2, W/2 - end_chamfer, -H/2 + end_chamfer]);
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [-L/2 + (end_relief_len + overlap)/2 - overlap/2, -W/2 + end_chamfer, H/2 - end_chamfer]);
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [-L/2 + (end_relief_len + overlap)/2 - overlap/2, -W/2 + end_chamfer, -H/2 + end_chamfer]);
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [L/2 - (end_relief_len + overlap)/2 + overlap/2, W/2 - end_chamfer, H/2 - end_chamfer]);
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [L/2 - (end_relief_len + overlap)/2 + overlap/2, W/2 - end_chamfer, -H/2 + end_chamfer]);
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [L/2 - (end_relief_len + overlap)/2 + overlap/2, -W/2 + end_chamfer, H/2 - end_chamfer]);
    end_relief_wedge([end_relief_len + overlap, end_chamfer*2, end_chamfer*2], [L/2 - (end_relief_len + overlap)/2 + overlap/2, -W/2 + end_chamfer, -H/2 + end_chamfer]);
  }
}

module small_face_chamfers() {
  difference() {
    end_corner_reliefs_both_ends();
    small_face_chamfer_cut([0, W/2 - small_chamfer, H/2 - small_chamfer]);
    small_face_chamfer_cut([0, -W/2 + small_chamfer, H/2 - small_chamfer]);
    small_face_chamfer_cut([0, W/2 - small_chamfer, -H/2 + small_chamfer]);
    small_face_chamfer_cut([0, -W/2 + small_chamfer, -H/2 + small_chamfer]);
  }
}

module transverse_hex_through_hole() {
  difference() {
    small_face_chamfers();
    hex_through_hole();
  }
}

module double_sided_v_countersink_around_hex_hole() {
  difference() {
    transverse_hex_through_hole();
    csk_cone([hex_axis_offset_L, 0, H/2 - (csk_depth + overlap)/2], [0, 0, 0]);
    csk_cone([hex_axis_offset_L, 0, -H/2 + (csk_depth + overlap)/2], [180, 0, 0]);
  }
}

module edge_fillets() {
  minkowski() {
    double_sided_v_countersink_around_hex_hole();
    fillet_sphere();
  }
}

// Final Output
edge_fillets();
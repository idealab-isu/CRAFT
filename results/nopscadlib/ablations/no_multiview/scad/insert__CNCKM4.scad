// Parameters
outer_diameter = 4; //[2:8:0.1]
length = 6.3; //[3.15:12.6:0.1]
screw_nominal_diameter = 4; //[2:8:0.1]
internal_thread_pitch = 0.7; //[0.35:1.4:0.05]
bore_minor_diameter = 3.3; //[2:6:0.05]
lead_in_chamfer_length = 0.5; //[0.25:1:0.05]
lead_in_chamfer_angle_deg = 45; //[20:70:1]
installation_socket_af = 3; //[1.5:6:0.1]
installation_socket_depth = 2; //[1:4:0.1]
knurl_depth = 0.2; //[0.1:0.5:0.05]
knurl_count = 24; //[12:48:1]
overlap = 1.2; //[0.5:2:0.1]  // ensure 1-2mm overlap for robust connectivity

// Threaded Insert - complete geometry (single visible solid)
module insert() {
  // Derived values
  body_r = outer_diameter/2;
  bore_r = bore_minor_diameter/2;

  // OpenSCAD trig uses degrees; keep explicit for clarity
  chamfer_drop = lead_in_chamfer_length * tan(lead_in_chamfer_angle_deg);
  chamfer_r2 = max(0.01, body_r - chamfer_drop);

  // Socket hex "circumradius" from across-flats
  socket_r = installation_socket_af/(2*cos(30));

  // Z placement for chamfer so it intersects the main body by 'overlap'
  chamfer_h = lead_in_chamfer_length + overlap;
  chamfer_z = (length/2) - (chamfer_h/2); // top-aligned, overlaps into body by 'overlap'

  color([0.8, 0.6, 0.2])  // Brass color
  difference() {
    // Outer solid (body + chamfer) as a single connected solid
    union() {
      // Main body
      cylinder(r=body_r, h=length, center=true, $fn=96);

      // Lead-in chamfer (guaranteed intersection with body)
      translate([0, 0, chamfer_z])
        cylinder(r1=body_r, r2=chamfer_r2, h=chamfer_h, center=true, $fn=96);
    }

    // Internal bore (thread minor diameter) - extend beyond to ensure clean subtraction
    cylinder(r=bore_r, h=length + 2*overlap, center=true, $fn=96);

    // Installation socket (hex) cut from the top; extend slightly to ensure clean subtraction
    // Top face at z=+length/2, so center the cut at: +length/2 - depth/2
    translate([0, 0, (length/2 - installation_socket_depth/2)])
      cylinder(r=socket_r, h=installation_socket_depth + 2*overlap, center=true, $fn=6);

    // Knurling cuts around the outside (subtractive)
    for (i = [0:knurl_count-1]) {
      rotate([0, 0, i*360/knurl_count])
        translate([body_r - knurl_depth, 0, 0])
          cube([knurl_depth*2, outer_diameter + 2*overlap, length + 2*overlap], center=true);
    }
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    insert();
  }
}

assembly();
// HT 110 pipe cap (socket + closed end + outer collar + ribs)
// One connected solid, all translations derived from dimensions.

$fn = 180;

// Parameters
dn = 110;                 //[55:220:1]
pipe_od = 110;            //[90:160:0.1]
socket_id = 110.6;        //[105:125:0.1]
wall_t = 3.2;             //[1.6:6.4:0.1]
socket_depth = 55;        //[30:110:0.5]
end_thickness = 4;        //[2:10:0.1]
chamfer_len = 2;          //[0.5:6:0.1]
rib_count = 12;           //[6:24:1]
rib_h = 0.8;              //[0.3:2:0.1]
rib_w = 3;                //[1.5:6:0.1]
rib_axial_len = 25;       //[10:60:0.5]
rib_band_from_open = 10;  //[2:30:0.5]
seal_groove_w = 5;        //[2:10:0.1]
seal_groove_d = 2.2;      //[1:4:0.1]
seal_groove_pos = 12;     //[5:30:0.5]
seal_enabled = 1;         //[0:1:1]
overlap = 1;              //[0.5:2:0.1]
cap_od = 117;             //[112:140:0.1]

// Added (to make recognizable HT cap geometry)
collar_od = 125;          //[118:150:0.1]  // outer collar diameter
collar_len = 18;          //[8:35:0.5]     // collar axial length from open end
closed_end_dome = 2.0;    //[0:6:0.1]      // slight dome on closed end

// Derived
outer_r = cap_od/2;
inner_r = socket_id/2;
total_h = socket_depth + end_thickness;

// Ensure collar is not smaller than main OD
collar_r = max(collar_od/2, outer_r);

// Make the cap read clearly in orthographic views by adding a stepped outer profile
// and a visible internal shoulder (socket stop) while keeping one connected solid.
shoulder_h = max(2, wall_t);                 // axial height of internal stop ring
shoulder_z0 = socket_depth - shoulder_h;     // start of stop ring (from open end)
stop_r = max(0, inner_r - wall_t);           // reduced radius at the stop (creates internal shoulder)

// Coordinate convention: open end at z=0, closed end at z=total_h
module cap_solid() {
  difference() {
    union() {
      // Main outer body (socket + end thickness)
      translate([0,0,total_h/2])
        cylinder(r=outer_r, h=total_h, center=true);

      // Outer collar / socket profile near open end (recognizable cap geometry)
      translate([0,0,collar_len/2])
        cylinder(r=collar_r, h=collar_len + overlap, center=true);

      // Slight dome on closed end (subtle feature)
      if (closed_end_dome > 0)
        translate([0,0,total_h - closed_end_dome/2])
          scale([1,1,closed_end_dome/(outer_r*0.35)])
            sphere(r=outer_r*0.35);

      // Outer grip ribs on collar band (connected by overlap into collar)
      for (i = [0:rib_count-1]) {
        rotate([0,0,i*360/rib_count])
          translate([
            collar_r - rib_h/2 + overlap/2,                 // overlaps into collar
            0,
            rib_band_from_open + rib_axial_len/2            // within collar region
          ])
            cube([rib_h, rib_w, rib_axial_len], center=true);
      }
    }

    // Inner bore (socket) from open end up to socket_depth
    translate([0,0,socket_depth/2])
      cylinder(r=inner_r, h=socket_depth + overlap, center=true);

    // Internal socket stop / shoulder: reduce radius near the bottom of socket
    // This creates a visible internal step (cap profile) without disconnecting solids.
    translate([0,0,shoulder_z0 + shoulder_h/2])
      cylinder(r=stop_r, h=shoulder_h + overlap, center=true);

    // Lead-in chamfer at open end (removes material)
    translate([0,0,chamfer_len/2])
      cylinder(r1=inner_r + chamfer_len, r2=inner_r, h=chamfer_len + overlap, center=true);

    // Optional seal groove (annular recess) inside socket
    if (seal_enabled == 1)
      translate([0,0,seal_groove_pos + seal_groove_w/2])
        cylinder(r=inner_r + seal_groove_d, h=seal_groove_w, center=true);
  }
}

cap_solid();
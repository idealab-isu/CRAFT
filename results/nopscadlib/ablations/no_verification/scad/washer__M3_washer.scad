// Flat washer parameters (mm)
inner_diameter_mm = 3.0;  //[1.5:6.0:0.1]
outer_diameter_mm = 7.0;  //[3.5:14.0:0.1]
thickness_mm      = 0.5;  //[0.25:1.0:0.05]

// Small extra height to guarantee a clean through-hole cut
cut_extra_mm = 0.2;

module flat_washer(id_mm, od_mm, t_mm) {
    difference() {
        cylinder(d=od_mm, h=t_mm, center=true, $fn=96);
        cylinder(d=id_mm, h=t_mm + 2*cut_extra_mm, center=true, $fn=96);
    }
}

flat_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);
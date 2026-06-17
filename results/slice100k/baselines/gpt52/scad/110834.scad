$fn=96;

od_body = 16.0;
od_flange = 21.2;
h_total = 10.0;
t_flange = 2.0;
h_body = h_total - t_flange;

id_bore = 8.0;
ecc = 2.6;

module bushing_body() {
    union() {
        translate([0,0,0]) cylinder(h=h_body, d=od_body, center=false);
        translate([0,0,h_body]) cylinder(h=t_flange, d=od_flange, center=false);
    }
}

module eccentric_bore() {
    translate([ecc,0,h_total/2]) cylinder(h=h_total+0.4, d=id_bore, center=true);
}

difference() {
    translate([0,0,-h_total/2]) bushing_body();
    eccentric_bore();
}
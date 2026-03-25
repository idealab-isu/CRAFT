$fn=64;

thread_d = 3.0;
pillar_d = 8.0;
len = 20.0;

module standoff_pillar(thread_d, pillar_d, len){
    difference(){
        cylinder(d=pillar_d, h=len, center=true);
        cylinder(d=thread_d, h=len+0.4, center=true);
    }
}

standoff_pillar(thread_d, pillar_d, len);
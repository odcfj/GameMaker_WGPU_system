Create:

var str = @"
@group(0) @binding(0) var<storage, read_write> output_array : array<u32>;
@group(0) @binding(1) var<storage, read_write> seed : array<u32>;


fn rand(x: u32, y: u32, seed: u32) -> u32 {
    const PRIME2: u32 = 2246822519u;
    const PRIME3: u32 = 3266489917u;
    const PRIME4: u32 = 668265263u;
    const PRIME5: u32 = 374761393u;

    var h: u32 = PRIME5 + seed;
    h = h + (x & 0xFFFFFFFFu) * PRIME3;
    h = ((h << 17u) | (h >> 15u)) * PRIME4;
    h = h + (y & 0xFFFFFFFFu) * PRIME3;
    h = ((h << 17u) | (h >> 15u)) * PRIME4;

    // avalanche
    h = h ^ (h >> 15u);
    h = h * PRIME2;
    h = h ^ (h >> 13u);
    h = h * PRIME3;
    h = h ^ (h >> 16u);
    return h;
}

@compute
@workgroup_size(256, 1, 1)
fn main(@builtin(local_invocation_id) local_id : vec3<u32>,
    @builtin(workgroup_id) workgroup_id : vec3<u32>) {
    output_array[workgroup_id.x*256u+local_id.x] = rand(local_id.x, workgroup_id.x, seed[0]);
}
"
shader = wg_shader_create(str);
vbuffer = wg_buffer_create(256*256*4,1,1);
vbuffer2 = wg_buffer_create(4,1,0);
wg_shader_set_buffer(shader,0,0,vbuffer);
wg_shader_set_buffer(shader,0,1,vbuffer2);
buffer = buffer_create(256*256*4,buffer_fixed,4);
buffer2 = buffer_create(4,buffer_fixed,4);
buffer_address = string(buffer_get_address(buffer));
buffer_address2 = string(buffer_get_address(buffer2));
surface = surface_create(256,256);

Step:

buffer_poke(buffer2,0,buffer_u32,irandom(65536*65536));
wg_buffer_upload(vbuffer2,buffer_address2,4);
var sr = wg_shader_run(shader);
wg_shader_set_workgroup(sr,256,1,1);
wg_shader_end_download_buffer(sr,vbuffer,buffer_address,256*256*4);
wg_run();

Draw_GUI

draw_surface(surface,0,0);

Social_async

if async_load[?"event_type"] == "wgpu_run_done" {
    buffer_set_surface(buffer,surface,0);
}

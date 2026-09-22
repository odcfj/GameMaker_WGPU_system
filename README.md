# Overview

* This is an external high-performance WGPU shader runtime system designed for GameMaker.
* It provides more powerful performance and capabilities than the built-in WGPU system currently provided by GMRT.

# Basic Operation

* Uses asynchronous data transfer between memory buffers and GPU buffers.
* Uses an instruction collector to batch and execute instructions together.
* Runs WGPU entirely asynchronously in the background without blocking the GML process.
* Automatically downloads data back to CPU memory after shader execution is completed.

# Usage

### Creation

##### The following functions must be used to configure a shader:

---

#### `wg_buffer_create(bytes, readable, writable) -> vbuffer id`

* Creates a GPU buffer and returns its GPU buffer ID.

#### `wg_shader_create(wgsl shader text) -> shader id`

* Creates a shader from WGSL source code and returns its shader ID.

#### `wg_shader_set_buffer(shader id, group, binding, vbuffer)`

* Binds a GPU buffer to the specified group and binding of a shader.

#### `wg_shader_set_workgroup(shader id, x, y, z)`

* Sets the workgroup size of a shader.

---

### Data Transfer

##### Data transfer commands are asynchronous and are only executed sequentially after `wg_run()` is called.

---

#### `wg_buffer_upload(vbuffer, memory address (string), bytes)`

* Uploads the specified number of bytes from a memory address to a GPU buffer.
* Use `string(buffer_get_address(buffer))` to obtain the memory address string.

#### `wg_buffer_download(vbuffer, memory address (string), bytes)`

* Downloads data from a GPU buffer to the specified memory address.

---

### Shader Management

##### Shader management commands are asynchronous and are only executed sequentially after `wg_run()` is called.

---

#### `wg_shader_run(shader id) -> shader run id`

* Queues one execution of the specified shader and returns the shader execution ID.

#### `wg_shader_delete(shader id)`

* Deletes a shader.

#### `wg_shader_end_download_buffer(shader run id, vbuffer, memory address, bytes)`

* Schedules a GPU buffer download to the specified memory address immediately after the specified shader execution is completed.

---

### Instruction Group Management

##### All asynchronous functions above add instructions to the current instruction group and are managed using the following functions.

---

#### `wg_run() -> run id`

* Packages all instructions currently in the instruction stack and submits them for asynchronous execution.
* Returns the instruction group ID.
* All submitted instructions are executed strictly in order.
* Once all instructions in the group have completed, an asynchronous callback event is generated immediately.

#### `wg_clean()`

* Clears all instructions and remaining data.

---

# Asynchronous Callback

After `wg_run()` is executed, an asynchronous callback event is generated when the instruction group has finished running in the background.

The `async_load` map contains the following keys:

* `"event_type"` : `"wgpu_run_done"`
* `"id"` : Run ID of the completed instruction group.

---

# Notes

Unlike GameMaker's built-in shader execution workflow, this extension's `wg_shader_run()` function, like all other asynchronous functions, **only adds an execution instruction to the instruction stack and does not execute the shader immediately**.

All asynchronous functions are collected into the instruction stack and are only packaged and executed sequentially after `wg_run()` is called.

This design allows the runtime to maximize asynchronous execution and minimize the performance overhead imposed on the GML process.

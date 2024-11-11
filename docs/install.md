Install
=====

Install from Releases
--------------------

1. Go to the [G-Mind GitHub repository releases](https://github.com/Jersonrn/G-Mind/releases) page and download the latest release package.

2. Extract the downloaded package and copy the contents to the root of your Godot project `res://`


Install from source (Linux)
-------------------

1. Ensure you have Cargo installed on your system. 

    ```bash
    cargo --version
    ```

2. Clone the G-Mind repository: 

    ```bash
    git clone https://github.com/Jersonrn/G-Mind

    ```


3. Navigate to the Rust G-Mind project directory: 

    ```bash
    cd G-Mind/rust/
    ```


4. Build the Rust project in release mode:

    ```bash
    cargo build --release
    ```


5. Copy the compiled `libg_mind.so` library to your Godot project's `lib/g_mind` directory: 

    ```bash
    cp target/release/libg_mind.so /path/to/your/godot/project/lib/g_mind
    ```

6. Copy the `scripts` directory to your Godot project's `lib/g_mind` directory:

    ```bash
    cd ../..
    cp -r godot/scripts /path/to/your/godot/project/lib/g_mind
    ```


7. Create a `g_mind.gdextension` file in the root of your Godot project:

    ```bash
    cd /path/to/your/godot/project
    touch g_mind.gdextension
    ```
    Then, add the following content to the `g_mind.gdextension` file:
    ```bash
    [configuration]
    entry_symbol = "gdext_rust_init"
    compatibility_minimum = 4.2

    [libraries]
    linux.debug.x86_64 = "res://lib/g_mind/libg_mind.so"
    linux.release.x86_64 = "res://lib/g_mind/libg_mind.so"
    ```


<!-- https://github.com/godot-rust/gdext/blob/master/examples/dodge-the-creeps/godot/rust.gdextension -->

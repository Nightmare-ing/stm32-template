# Usage of this Template

## Structure of This STM32 Project Template

The structure of this STM32 project template is shown as following:

```
├── bsp
│   ├── boards
│   │   └── atk_warship_f103
│   │       ├── adapters
│   │       │   └── led.c
│   │       ├── board.cmake
│   │       ├── CMakeLists.txt
│   │       └── include
│   │           └── board
│   │               └── led.h
│   ├── chips
│   │   └── stm32f1.cmake
│   ├── CMakeLists.txt
│   ├── dependencies.cmake
│   ├── hal_config
│   │   └── stm32f1xx_hal_conf.h
│   ├── ldscripts
│   │   └── STM32F103XE_FLASH.ld
│   ├── startup
│   │   ├── startup_stm32f103xe.s
│   │   └── system_stm32f1xx.c
│   └── svd
│       └── STM32F103.svd
├── cmake
│   ├── arm-none-eabi-toolchain.cmake
│   └── stm32-utils.cmake
├── CMakeLists.txt
├── CMakePresets.json
├── components
│   └── led
│       ├── CMakeLists.txt
│       ├── include
│       │   └── led
│       │       └── led.h
│       └── src
│           └── led.c
├── README.md
├── src
│   ├── CMakeLists.txt
│   └── labs
│       ├── lab1_led
│       │   ├── CMakeLists.txt
│       │   └── main.c
│       └── lab2_key2led
│           ├── CMakeLists.txt
│           └── main.c
└── tests
    ├── CMakeLists.txt
    └── unit
        ├── CMakeLists.txt
        └── test_led.c
```

This project is managed by modern CMake, built with the `arm-none-eabi` toolchain and supports PC host testing for component logic.
Later may add supports for other toolchains and other chips(only need to add a new toolchain file in the `cmake` folder and add more presets in the `CMakePresets.json` file).

It's split into several folders:

- The `components` folder contains the reusable components for the project, like the `led` component in this template. Those components are independent of the driver, and only contain logic to control the peripherals. They are compiled into static libraries.
  .
- The `src` folder contains the application logic for the project. Multiple applications can be placed in the `src/labs` folder, and each application has its own `CMakeLists.txt` file to build the application into a runnable ELF file.
- The `bsp` folder contains the board support package (BSP) files, including the startup file, linker script, HAL configuration file, and system initialization file. The `bsp` folder also contains the `dependencies.cmake` file to manage the dependencies, as well as `boards` and `chips` folders to manage the board devices and chip configurations.
- The `tests` folder contains the unit tests for the components, which can be run on PC host. Each component has its own test file, currently we only use basic `assert` to check the correctness of the component logic, later we may add more advanced testing framework like `cmocka` or `googletest`.

This project doesn't use the STM32CubeMX tool to generate code, instead it manages the dependencies from ST official repos like `cmsis-core`, `cmsis-device-f1` and `stm32f1xx-hal` with CMake. Thus we can avoid STM32CubeMX to mess up git history and have more control over the project.
However, the project is also compatible with STM32CubeMX generated code. If you want to use STM32CubeMX, it's recommended to use STM32CubeMX to generate code for a new project, then copy the generated files to this template and modify them if necessary.

Dependencies like ARM CMSIS, STM32 CMSIS and STM32 HAL are managed by CMake `FetchContent` with fixed version (version is specified in `bsp/chips/*.cmake` as cached cmake variables), and they are downloaded to `build/<preset>/_deps` automatically when you configure the project.
Those dependencies are listed in `dependencies.cmake` file under the `build` directory, then two most basic interface library, i.e. `arm::cmsis` and `stm32::cmsis`, are created for static libraries like HAL and LL to link with.
HAL or LL library target is created in the `bsp/CMakeLists.txt` file with name `bsp::driver`, which provides a common interface for the ELF target to link with. The actual driver library is chosen based on the cached variable `STM32_DRIVE_TYPE`, set by the preset in `CMakePresets.json` file.

The `bsp` folder contains the board support package (BSP) files, including the startup file, linker script, HAL configuration file, and system initialization file. Those files are copied from the official STM32 repos like `cmsis-device-f1`. They may be modified to fit the project, so they're not referenced from the library directly.
The `bsp/chips/stm32f1.cmake` file contains the chip-specific compilation flags, and offered as a library called `bsp::mcu_config` for any compiled target running on STM32 to link with. If you want to use another chip, you just need to create a new CMake file and offer the same interface library `bsp::mcu_config`.
This file also set variables for specifying git tags of the dependencies, so that `bsp/dependencies.cmake` can fetch the correct version of the dependencies from ST and ARM official repos.

`bsp/boards` folder contains the board-specific devices, like the `led` device in this template. Those devices offer hardware adapters for applications to use, and they depends on specific driver. For example, in `src/labs/lab1_led/main.c`, first we use `board_led_bind` to bind the `led` struct (from `components/led/include/led/led.h`) to the specific hardware adapter (from `bsp/boards/atk_warship_f103/adapters/led.c`) on board, and then manipulate the `led` struct to control the LED on board with methods from `components/led/include/led/led.h`.

The `bsp/boards/<board_name>/board.cmake` file contains the board-specific information, like `BOARD_MCU_FAMILY` and `BOARD_MCU_MODEL`, those are used by `bsp/CMakeLists.txt` to find the correct chip configuration file in `bsp/chips` folder, and also used by `bsp/dependencies.cmake` to find the correct repo from ST and ARM official repos according to the chip family and model.

`bsp/CMakeLists.txt` manages everything related to the BSP, including the following tasks:

- Reads the `bsp/boards/<board_name>/board.cmake` file to get the board-specific information, like `BOARD_MCU_FAMILY` and `BOARD_MCU_MODEL`.
- Fetch the dependencies from ST and ARM official repos according to the chip family and model, and create two interface libraries `arm::cmsis` and `stm32::cmsis`.
- Reads in chip configuration file in `bsp/chips` folder according to the board-specific information, and create target `bsp::mcu_config`.
- Create several basic targets for the project to boot up, like `bsp::startup` (contains the vector table), `bsp::baremetal_linker` (contains the linker script), and `bsp::driver` (contains the HAL or LL or bare-metal driver). `bsp::driver` choose the HAL library or the LL library based on the cached variable `STM32_DRIVE_TYPE`, which is set by the preset in `CMakePresets.json` file.
- Aggregates necessary runtime targets, i.e. `bsp::startup`, `bsp::baremetal_linker`, `bsp::driver` and `target_abi`, into a single target `bsp::runtime`, thus applications only need to link one target.
- Add board-specific device targets, like `board::led`, with `add_subdirectory` command.

`cmake/stm32-utils.cmake` file contains some helper functions, like generating .bin and .hex files from the ELF file.

The `compile_commands.json` file in the `build` folder is a symbolic link to the `compile_commands.json` file in specific preset `build` folder, which is generated by CMake during building process. Because we may have multiple build folders for different configurations.

This project abstract away devices operation logic into reusable components in `components` folder. We only need to offer a hardware adapter for the device in the `bsp/boards/<board_name>/adapters` folder, and then bind the device struct to the hardware adapter in the application code. By doing this, we can easily switch to another board with the same device, or swith between different adapters implementations for different performance or power consumption requirements.
For example, the `led` device in this template needs two hardware interfaces, one is the setter to set LED state, and the other is the context for setter to operate. In this case we use GPIO to control LED, so the context is the GPIO port, pin number and whether it's active high or low.
Then adapters only need to specify `context` and `setter` for the device, then we can apply methods in `components/led/include/led/led.h` to control the LED on board.

`tests` folder contains the unit tests for the components, which can be run on PC host independently to validate the correctness of the component logic. If the components pass all the unit tests and there's still some bug in the application running on the MCU, then the bug is likely caused by the hardware adapter or the driver, and we can debug it with a debugger like J-Link.
With this approach, we can quickly find and fix the bug, thus speed up the development process.

## Usage

### Build ELF Files

To build the project, first you need to install the `arm-none-eabi` toolchain, and then configure the project with CMake with

```bash
cmake --preset <configure_preset_name>
```

This command generates the build files in the `build/<preset_name>` folder, and then you can build the ELF files with

```bash
cmake --build --preset <build_preset_name>
```

The generated ELF files are located in the `build/<preset_name>/src/labs/<lab_name>` folder, and the generated .bin and .hex files are located in the same folder.

### Build and Run Unit Tests on PC Host

To build and run the unit tests on PC host, first you need to configure the project with

```bash
cmake --preset <configure_preset_name_host_test>
```

Then you can build the unit tests with

```bash
cmake --build --preset <build_preset_name_host_test>
```

Finally you can run the unit tests with

```bash
ctest --preset <test_preset_name_host_test>
```

### Switch to Different MCU Chip or Board

To switch to a different MCU chip or board, you need to do the following steps:

- Add a new CMake file similar to `bsp/chip/stm32f1.cmake` for the new chip, specify required CPU flags, linker options and compile options, and offer an interface target `bsp::mcu_config`
- Create a new board folder under `bsp/boards`, and add a `board.cmake` file to specify the board-specific information, like `BOARD_MCU_FAMILY` and `BOARD_MCU_MODEL`
- Check the offical ARM CMSIS, STM32 CMSIS and STM32 HAL repos to see if the name of the repo matches the config in `dependencies.cmake` file, also check the git tag for those repos.
- Add a new preset in the `CMakePresets.json` file for the new chip, reference to the default preset.
- Copy necessary BSP files from the official STM32 repos like `cmsis-device-*` to the `bsp` folder, and modify them if necessary.

Then hopefully this CMake configuration will find related dependencies automatically and build the project successfully.

## Some Notes

### Macro Passed to `stm32:ll` Library

Actually there's no conditional checks like `#ifdef USE_FULL_LL_DRIVER` inside ST's official Low-Layer (LL) driver sources.
However, STM32CubeMX with LL driver enabled generates code with this macro defined, so we also define it in the `CMakeLists.txt` file to be compatible with the generated code.
If you don't use STM32CubeMX to generate code, you can remove this macro definition in the `CMakeLists.txt` file.

Besides, `USE_HAL_DRIVER` is strictly required by the HAL driver sources, so `USE_FULL_LL_DRIVER` is widely adopted by the community as a matching architectural flag for conditional compilation like

```c
#if defined(USE_HAL_DRIVER)
    HAL_Delay(1000);
#elif defined(USE_FULL_LL_DRIVER)
    LL_mDelay(1000);
#endif
```

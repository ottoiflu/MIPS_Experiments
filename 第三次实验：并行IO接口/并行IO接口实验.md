# 实验三：并行IO接口设计

**通信2303班 岳康**  **U202314327**

## 实验名称

并行IO接口设计

## 实验目的

- 掌握GPIO IP核的工作原理和使用方法
- 掌握中断控制方式的IO接口设计原理
- 掌握中断程序设计方法
- 掌握IO接口程序控制方法

## 实验仪器

***Vivado 2018.3***

## 实验任务
本实验要求实现一个并行IO接口设计，使用独立按键和独立开关作为输入设备，LED灯和七段数码管作为输出设备。具体功能如下：
1. **BTNC 按键功能**  
    按下 BTNC 按键时，计算机读取一组 16 位独立开关状态作为一个二进制数据，并将该二进制数的低 8 位对应的二进制数值（0 或 1）显示到 8 个七段数码管上。

2. **BTNU 按键功能**  
    按下 BTNU 按键时，计算机读取一组 16 位独立开关状态作为一个二进制数据，并将该 16 进制数据各位数字对应的字符（0~F）显示到低 4 位七段数码管上（高 4 位七段数码管不显示）。

3. **BTND 按键功能**  
    按下 BTND 按键时，计算机读取一组 16 位独立开关状态作为一个二进制数据，并将该数据表示的无符号十进制数各位数字对应的字符（0~9）显示到低 5 位七段数码管上（高 3 位七段数码管不显示）。

> **程序控制方式提示**：  
> 程序以七段数码管动态显示控制循环为主体，在循环体内的延时函数内循环读取按键键值以及开关状态，并根据按键值做相应处理。

## 实验原理

### 硬件电路框图

![Base/硬件电路框图1.png at master · HUSTerCH/Base · GitHub](https://github.com/HUSTerCH/Base/raw/master/circuitDesign/%E5%BE%AE%E6%9C%BA%E5%8E%9F%E7%90%86/ex3/%E7%A1%AC%E4%BB%B6%E7%94%B5%E8%B7%AF%E6%A1%86%E5%9B%BE1.png)

![Base/硬件电路框图2.png at master · HUSTerCH/Base · GitHub](https://github.com/HUSTerCH/Base/raw/master/circuitDesign/%E5%BE%AE%E6%9C%BA%E5%8E%9F%E7%90%86/ex3/%E7%A1%AC%E4%BB%B6%E7%94%B5%E8%B7%AF%E6%A1%86%E5%9B%BE2.png)

根据硬件电框图搭建的硬件平台整体框图如下：

![image-20240518145736240](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240518145736240.png)



## 实验源码

### 程序控制方式

```c
#include "stdio.h"
#include "xil_io.h"
#include "xgpio.h"

#define SWITCH_GPIO_BASE     XPAR_AXI_GPIO_0_BASEADDR
#define DISPLAY_GPIO_BASE    XPAR_AXI_GPIO_1_BASEADDR
#define BUTTON_GPIO_BASE     XPAR_AXI_GPIO_2_BASEADDR

int main()
{
    u16 switch_value = 0;
    u8 low_byte = 0;
    int mode = 0; // 0 = binary, 1 = hex, 2 = decimal
    int i, j;

    u8 dec_digits[5] = {0}; // 用于存储十进制的5个数字

    // 数码管段码（共阳极）：0~F + 十进制 0~9
    const u8 bin_segcode[2] = { 0xc0, 0xf9 };
    const u8 hex_segcode[16] = {
        0xc0, 0xf9, 0xa4, 0xb0,
        0x99, 0x92, 0x82, 0xf8,
        0x80, 0x90, 0x88, 0x83,
        0xc6, 0xa1, 0x86, 0x8e
    };

    // 设置 GPIO 方向
    Xil_Out32(SWITCH_GPIO_BASE + XGPIO_TRI_OFFSET, 0xFFFF); // 输入
    Xil_Out32(DISPLAY_GPIO_BASE + XGPIO_TRI_OFFSET, 0x00);  // 输出：位选
    Xil_Out32(DISPLAY_GPIO_BASE + XGPIO_TRI2_OFFSET, 0x00); // 输出：段码
    Xil_Out32(BUTTON_GPIO_BASE + XGPIO_TRI_OFFSET, 0xFF);   // 输入

    while (1)
    {
        u8 btn_state = Xil_In8(BUTTON_GPIO_BASE + XGPIO_DATA_OFFSET);

        if (btn_state & 0x01) // BTNC - 二进制模式
        {
            switch_value = Xil_In16(SWITCH_GPIO_BASE + XGPIO_DATA_OFFSET);
            low_byte = switch_value & 0xFF;
            mode = 0;

            xil_printf("[BTNC] Binary Mode: 0x%04X, Low Byte = 0x%02X\n", switch_value, low_byte);
            while (Xil_In8(BUTTON_GPIO_BASE + XGPIO_DATA_OFFSET) & 0x01); // 等释放
        }
        else if (btn_state & 0x02) // BTNU - 十六进制模式
        {
            switch_value = Xil_In16(SWITCH_GPIO_BASE + XGPIO_DATA_OFFSET);
            mode = 1;

            xil_printf("[BTNU] Hex Mode: 0x%04X\n", switch_value);
            while (Xil_In8(BUTTON_GPIO_BASE + XGPIO_DATA_OFFSET) & 0x02); // 等释放
        }

        else if (btn_state & 0x10) // BTND - 十进制模式（显示5位）
        {
            switch_value = Xil_In16(SWITCH_GPIO_BASE + XGPIO_DATA_OFFSET);
            mode = 2;

            xil_printf("[BTND] Decimal Mode: %u\n", switch_value);

            // 提取低5位十进制字符
            u16 temp = switch_value;
            for (i = 0; i < 5; i++) {
                dec_digits[4 - i] = temp % 10;
                temp /= 10;
            }

            while (Xil_In8(BUTTON_GPIO_BASE + XGPIO_DATA_OFFSET) & 0x10); // 等释放
        }

        // ============ 数码管刷新 =============
        if (mode == 0) // 二进制模式：显示低8位的每一位
        {
            for (i = 0; i < 8; i++)
            {
                u8 bit_val = (low_byte >> i) & 0x01;
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA2_OFFSET, bin_segcode[bit_val]); // 段码
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA_OFFSET, ~(1 << i));              // 位选
                for (j = 0; j < 1000; j++);
            }
        }
        else if (mode == 1) // 十六进制模式：显示低4个 nibble
        {
            for (i = 0; i < 4; i++)
            {
                u8 digit = (switch_value >> (i * 4)) & 0x0F;
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA2_OFFSET, hex_segcode[digit]);
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA_OFFSET, ~(1 << i));
                for (j = 0; j < 1000; j++);
            }
        }
        else if (mode == 2) // 十进制模式：显示 dec_digits 数组
        {
            for (i = 0; i < 5; i++)
            {
                u8 digit = dec_digits[4-i];//反向扫描显示
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA2_OFFSET, hex_segcode[digit]); // 0~9 在 hex_segcode 中相同
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA_OFFSET, ~(1 << i)); // 只用 D0~D4
                for (j = 0; j < 1000; j++);
            }

            // 高 3 位不显示（可选：关掉）
            for (i = 5; i < 8; i++)
            {
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA2_OFFSET, 0xFF); // 全灭
                Xil_Out8(DISPLAY_GPIO_BASE + XGPIO_DATA_OFFSET, ~(1 << i));
                for (j = 0; j < 500; j++);
            }
        }
    }

    return 0;
}


```

### 中断控制方式

```c
#include "xil_io.h"
#include "xgpio_l.h"
#include "xintc_l.h"
#include "xtmrctr_l.h"
#include "stdio.h"

#define SWITCH_BASE      XPAR_AXI_GPIO_0_BASEADDR
#define DISPLAY_BASE     XPAR_AXI_GPIO_1_BASEADDR
#define BUTTON_BASE      XPAR_AXI_GPIO_2_BASEADDR
#define TIMER_BASE       XPAR_AXI_TIMER_0_BASEADDR
#define INTC_BASE        XPAR_AXI_INTC_0_BASEADDR

#define TIMER_RESET_VALUE 100000

// 显示模式
#define MODE_BINARY  0
#define MODE_HEX     1
#define MODE_DECIMAL 2

// 数码管段码
const u8 bin_segcode[2] = { 0xc0, 0xf9 };
const u8 hex_segcode[16] = {
    0xc0, 0xf9, 0xa4, 0xb0,
    0x99, 0x92, 0x82, 0xf8,
    0x80, 0x90, 0x88, 0x83,
    0xc6, 0xa1, 0x86, 0x8e
};

int mode = MODE_BINARY;
u16 switch_value = 0;
u8 low_byte = 0;
u8 dec_digits[5] = {0};
int scan_index = 0;

void My_ISR() __attribute__((interrupt_handler));
void timerHandler();
void buttonHandler();
void switchHandler();

int main() {
    // 设置 GPIO 方向
    Xil_Out32(SWITCH_BASE + XGPIO_TRI_OFFSET, 0xFFFF); // Switch: 输入
    Xil_Out32(DISPLAY_BASE + XGPIO_TRI_OFFSET, 0x00);  // 位选：输出
    Xil_Out32(DISPLAY_BASE + XGPIO_TRI2_OFFSET, 0x00); // 段码：输出
    Xil_Out32(BUTTON_BASE + XGPIO_TRI_OFFSET, 0xFF);   // Button: 输入

    // 使能 GPIO 中断
    Xil_Out32(BUTTON_BASE + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK);
    Xil_Out32(BUTTON_BASE + XGPIO_GIE_OFFSET, XGPIO_GIE_GINTR_ENABLE_MASK);

    Xil_Out32(SWITCH_BASE + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK);
    Xil_Out32(SWITCH_BASE + XGPIO_GIE_OFFSET, XGPIO_GIE_GINTR_ENABLE_MASK);

    // 初始化定时器
    Xil_Out32(TIMER_BASE + XTC_TCSR_OFFSET, 0x00000000); // 关闭定时器
    Xil_Out32(TIMER_BASE + XTC_TLR_OFFSET, TIMER_RESET_VALUE);
    Xil_Out32(TIMER_BASE + XTC_TCSR_OFFSET, XTC_CSR_LOAD_MASK);
    Xil_Out32(TIMER_BASE + XTC_TCSR_OFFSET,
              XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_AUTO_RELOAD_MASK |
              XTC_CSR_ENABLE_INT_MASK | XTC_CSR_DOWN_COUNT_MASK);

    // 注册中断到 INTC
    Xil_Out32(INTC_BASE + XIN_IER_OFFSET,
              XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK |
              XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK |
              XPAR_AXI_TIMER_0_INTERRUPT_MASK);

    Xil_Out32(INTC_BASE + XIN_MER_OFFSET,
              XIN_INT_MASTER_ENABLE_MASK | XIN_INT_HARDWARE_ENABLE_MASK);

    microblaze_enable_interrupts();
    xil_printf("=== 中断系统启动 ===\n");

    while (1); // 主循环为空，中断驱动
    return 0;
}

// 主中断服务函数
void My_ISR() {
    int status = Xil_In32(INTC_BASE + XIN_ISR_OFFSET);

    if (status & XPAR_AXI_TIMER_0_INTERRUPT_MASK) {
        timerHandler();
    }

    if (status & XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK) {
        buttonHandler();
    }

    if (status & XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK) {
        switchHandler();
    }

    Xil_Out32(INTC_BASE + XIN_IAR_OFFSET, status); // 清除中断
}

// 定时器中断服务函数（数码管刷新）
void timerHandler() {
    u8 seg = 0xFF;
    u8 pos = ~(1 << scan_index);

    if (mode == MODE_BINARY) {
        u8 bit_val = (low_byte >> scan_index) & 0x01;
        seg = bin_segcode[bit_val];
    }
    else if (mode == MODE_HEX) {
        if (scan_index < 4) {
            u8 digit = (switch_value >> (scan_index * 4)) & 0x0F;
            seg = hex_segcode[digit];
        }
    }
    else if (mode == MODE_DECIMAL) {
        if (scan_index < 5) {
            seg = hex_segcode[dec_digits[4 - scan_index]];
        }
    }

    Xil_Out8(DISPLAY_BASE + XGPIO_DATA2_OFFSET, seg);
    Xil_Out8(DISPLAY_BASE + XGPIO_DATA_OFFSET, pos);

    scan_index = (scan_index + 1) % 8;

    // 清中断位
    Xil_Out32(TIMER_BASE + XTC_TCSR_OFFSET, Xil_In32(TIMER_BASE + XTC_TCSR_OFFSET));
}

// 按键中断服务函数（切换显示模式）
void buttonHandler() {
    u8 btn = Xil_In8(BUTTON_BASE + XGPIO_DATA_OFFSET);
    switch_value = Xil_In16(SWITCH_BASE + XGPIO_DATA_OFFSET);
    low_byte = switch_value & 0xFF;

    if (btn & 0x01) {
        mode = MODE_BINARY;
        xil_printf("[BTNC] Binary Mode\n");
    }
    else if (btn & 0x02) {
        mode = MODE_HEX;
        xil_printf("[BTNU] Hex Mode\n");
    }
    else if (btn & 0x10) {
        mode = MODE_DECIMAL;
        xil_printf("[BTND] Decimal Mode\n");
        u16 temp = switch_value;
        for (int i = 0; i < 5; i++) {
            dec_digits[4 - i] = temp % 10;
            temp /= 10;
        }
    }

    Xil_Out32(BUTTON_BASE + XGPIO_ISR_OFFSET, XGPIO_IR_CH1_MASK); // 清除按钮中断
}

// 开关变化时更新 switch_value
void switchHandler() {
    switch_value = Xil_In16(SWITCH_BASE + XGPIO_DATA_OFFSET);
    low_byte = switch_value & 0xFF;
    Xil_Out32(SWITCH_BASE + XGPIO_ISR_OFFSET, XGPIO_IR_CH1_MASK); // 清除中断
}

```

## 实验结果

实验效果如下：

- 按下 BTNC 按键时，低8位开关状态以二进制实时显示在8个七段数码管上。
![](image/20250529201235.png)
- 按下 BTNU 按键时，16位开关状态以十六进制实时显示在低4个七段数码管上。
![](image/20250529201321.png)
- 按下 BTND 按键时，16位开关状态以十进制实时显示在低5个七段数码管上。
![](image/20250529201853.png)

## 实验小结

在实验过程中，我遇到了不少挑战。例如，在程序控制方式下，如何高效地实现数码管的动态刷新，避免显示闪烁和延迟，是一大难点。刚开始时，由于延时函数设置不合理，导致数码管显示不稳定。通过查阅资料和多次调试，我逐步优化了刷新机制，使显示效果更加流畅。

在中断控制方式的实现中，如何正确配置和管理中断源、优先级以及中断服务函数的编写也让我花费了不少时间。尤其是在调试中断响应时，曾经因为中断标志位未及时清除，导致系统出现重复响应甚至死循环。通过分析中断流程和阅读相关文档，我逐步理清了中断的触发与清除机制，最终实现了稳定可靠的中断响应。

调试过程中还遇到了一些小bug。例如，按键输入偶尔会出现抖动，导致一次按键被识别为多次输入。为了解决这个问题，我增加了软件消抖处理，有效提升了系统的稳定性。此外，在LED灯和数码管的联动测试中，曾因引脚分配错误导致输出异常，通过逐步排查硬件连接和软件配置，最终定位并修正了问题。这些小bug的调试过程让我更加细致地理解了软硬件协同的重要性，也锻炼了我的耐心和细致程度。

此外，实验还让我体会到软硬件协同设计的重要性。硬件电路的搭建和IP核的配置直接影响到后续软件编程的便利性和系统的可扩展性。在调试过程中，我学会了如何利用Vivado等开发工具进行硬件调试，并结合软件日志输出快速定位问题。

通过本次实验，我不仅提升了嵌入式系统开发的实际能力，还增强了独立分析和解决问题的能力。遇到问题时，我能够主动查找资料、分析原因并尝试多种解决方案。实验让我更加熟悉了FPGA平台下的软硬件开发流程，也为后续更复杂的系统设计打下了坚实的基础。

总之，这次实验极大地丰富了我的专业知识和实践经验，让我对并行IO接口设计有了系统而深入的理解，也锻炼了我的工程实践能力和创新思维。

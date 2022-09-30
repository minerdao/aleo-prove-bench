# Aleo Prove benchmark

## Aleo出块证明性能测试工具

<img src="./aleo_prove_screenshot.png" alt="Running aleo prove on terminal">

## 功能

- 显示系统设备CPU、GPU信息；
- 显示证明时系统CPU、GPU占用率；
- 配置证明时的多项式系数阶degree及最大阶max_degree；

## 支持系统

- Linux
- MacOS
- Windows

## 前置条件

- Rust version > 1.58
- cuda version > 11.2

## 编译

```
cargo build --release
```

## 用法

```
alepprovebench [degree] [max_degreee]
```

## 结果

```sh
Device: CPU 名字(核数), GPU 名字(核数)[V驱动版本]
Proving: 100%, CPU 0%, Mem 79%, GPU 90%, GpuMem 3% 
Time: 7431ms/每个prove, n个prove/s
```

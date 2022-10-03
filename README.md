# Aleo Prove bench

## Aleo Prove显卡测试工具

<img src="./aleo_prove_screenshot.png" alt="Running aleo prove on terminal">

## 功能

- 显示系统设备CPU、GPU信息；
- 显示证明时系统CPU、GPU占用率；
- 支持配置证明时的多项式系数阶degree及最大阶max_degree；

## 支持系统

- Linux
- MacOS
- Windows

## 依赖

- Rust version > 1.58
- cuda version > 11.2
- [snarkVM - feat/new-posw-prover分支](https://github.com/AleoHQ/snarkVM/tree/feat/new-posw-prover)

## 编译

```bash
cd aleo-prove-bench

git submodule update

cargo build --release
```

## 用法

```bash
cd aleo-prove-bench/target/release/

aleoprove [degree] [max_degreee]
```

## 结果

```sh
Device: CPU 名字(核数), GPU 名字(核数)[V驱动版本]
Proving: CPU 0%, GPU 90%, Elapsed 290s  Device with 11554848768 bytes of memory
Result: 43ms/每个prove, n个prove/s
```

## 加入社群
MinerDAO社区聚集了Aleo项目的矿工、开发者、投资人。
我们为矿工和开发者提供技术交流、算法优化、资源合作、新项目研究等，欢迎大家加入讨论。

- 微信号: maxmillion-eth (备注: MinerDAO)
  <img src="https://raw.githubusercontent.com/minerdao/posts/master/images/wechat-max.png" width="200">
- [Telegram交流群](https://t.me/joinchat/TOGYnsZ2itA0NGZl)
- [Discord交流群](https://discord.gg/4f3DjmDk7j)

# Aleo Prove bench

## Aleo Prove显卡测试工具

<img src="./aleo_prove_screenshot.png" alt="Running aleo prove on terminal">

## 功能

- [x] 显示系统设备CPU、GPU信息；
- [x] 显示证明时系统CPU、GPU占用率；
- [x] 支持配置证明时的多项式系数阶degree及最大阶max_degree；
- [ ] 支持多显卡并行处理；
- [ ] 针对不同的显卡调优，如GeForce 2660s；

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
git clone https://github.com/minerdao/aleo-prove-bench.git && cd aleo-prove-bench

cargo build --release
```

## 用法

```bash
cd aleo-prove-bench

# 下载universal文件
wget -c https://cs-sz-aleo.oss-cn-shenzhen.aliyuncs.com/resource/universal.srs

./target/release/aleoprove [degree] 2>/dev/null

# 例如
./target/release/aleoprove 18 2>/dev/null
# 默认degree为15，degree最大不能超过20
```

## 结果

```sh
Device: CPU 名字(核数), GPU 名字(核数)[V驱动版本]
Proving: CPU 0%, GPU 90%, Elapsed 290s
Result: CoinBase on prove: 43 ms(平均每个prove的执行时间), 23个prove/s
```

## 加入社群
MinerDAO社区聚集了Aleo项目的矿工、开发者、投资人。  
我们为矿工和开发者提供技术交流、算法优化、资源合作、新项目研究等，欢迎大家加入讨论。

- 微信号: maxmillion-eth (备注: MinerDAO)

  <img src="https://raw.githubusercontent.com/minerdao/posts/master/images/wechat-max.png" width="200">

- [Telegram交流群](https://t.me/joinchat/TOGYnsZ2itA0NGZl)
- [Discord交流群](https://discord.gg/4f3DjmDk7j)

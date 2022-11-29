# Aleo Prove bench

## Aleo Prove显卡测试工具

<img src="./aleo_prove_screenshot.png" alt="Running aleo prove on terminal">

## 功能

- [x] 显示系统设备CPU、GPU信息；
- [x] 显示证明时系统CPU、GPU占用率；
- [x] 支持配置证明时的多项式系数阶degree及最大阶max_degree；
- [ ] 支持多显卡并行处理；
- [ ] 针对不同的显卡进行优化，如GeForce RTX 2660s；

## 支持系统

- Linux
- MacOS
- Windows

## 依赖

- Rust version > 1.58
- cuda version > 11.2
- [snarkVM - feat/new-posw-prover分支](https://github.com/AleoHQ/snarkVM/tree/feat/new-posw-prover)

**注意：显卡驱动版本需要大于500，在515.76上测试通过**

## 环境准备
```bash
sudo apt update -y

sudo apt install libssl-dev pkg-config nvidia-cuda-toolkit
```

## 编译

```bash
git clone https://github.com/minerdao/aleo-prove-bench.git && cd aleo-prove-bench

cargo build --release
```

**⚠️ 注意：**
由于aleo-std的版本冲突，请不要执行`cargo update`更新，会造成编译失败。

## 如何使用

```bash
cd aleo-prove-bench

# 下载universal文件，和aleoprove可执行文件放在同一目录
wget -c https://cs-sz-aleo.oss-cn-shenzhen.aliyuncs.com/resource/universal.srs

./target/release/aleoprove [degree] 2>/dev/null

# 例如
./target/release/aleoprove 2>/dev/null
# 默认degree为12，degree最大不能超过20

./target/release/aleoprove 18 2>/dev/null
```

## 结果

```sh
Device: CPU 名字(核数), GPU 名字(核数)[V驱动版本]
Proving: CPU 0%, GPU 90%, Elapsed 290s
Result: CoinBase on prove: 43prove/ms(平均每个prove的执行时间), 23proves/s(每秒完成的prove数量)
```
**⚠️ 注意：**
首次运行时，生成`~/.aleo/resources/cuda/msm.fatbin`文件需要一些时间，会影响测试结果，请勿以首次运行的数据为准。



## 加入社群
MinerDAO社区聚集了Aleo项目的矿工、开发者、投资人。  
我们为矿工和开发者提供技术交流、算法优化、资源合作、新项目研究等，欢迎大家加入讨论。

- 微信号: maxmillion-eth (备注: MinerDAO)

  <img src="https://raw.githubusercontent.com/minerdao/posts/master/images/wechat-max.png" width="200">

- [Telegram交流群](https://t.me/joinchat/TOGYnsZ2itA0NGZl)
- [Discord交流群](https://discord.gg/4f3DjmDk7j)

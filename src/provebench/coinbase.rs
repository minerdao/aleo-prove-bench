use snarkvm::prelude::{Address, CoinbasePuzzle, EpochChallenge, PrivateKey, PuzzleConfig, Testnet3};
use benchmarking;
use rand::{thread_rng, RngCore};
use std::time::Duration;
use crate::metrics;

type CoinbasePuzzleInst = CoinbasePuzzle<Testnet3>;

// pub struct ProveBench {}

// impl ProveBench {
pub fn prove(duration: Duration, degree: u32, max_degree: u32) {
    metrics::print_title_info("Wating", "Prove Setup");
    
    let max_config = PuzzleConfig { degree: 2_u32.pow(max_degree) };
    let config = PuzzleConfig { degree: 2_u32.pow(degree) };
    let universal_srs = CoinbasePuzzleInst::setup(max_config, &mut thread_rng()).unwrap();
    let provekey = CoinbasePuzzleInst::trim(&universal_srs, config).unwrap().0;
    metrics::print_backgroud_metrics();

    let result = benchmarking::bench_function_with_duration(duration, move |b| {  
        b.measure(|| {
            let rng = &mut thread_rng();
            let challenge = EpochChallenge::new(rng.next_u64(), Default::default(), config.degree).unwrap();
            let address = Address::try_from(PrivateKey::new(rng).unwrap()).unwrap();
            let nonce = rng.next_u64();
            CoinbasePuzzleInst::prove(&provekey, &challenge, &address, nonce).unwrap();
        });
    })
    .unwrap();

    metrics::print_result("CoinBase on prove: ", result);
}

// fn accumulate_prove(c: &mut Criterion) {
// CoinbasePuzzle<Testnet3>::prove(&pk, &epoch_info, &epoch_challenge, &address, nonce);
// CoinbasePuzzle<Testnet3>::accumulate(&pk, &epoch_info, &epoch_challenge, &solutions);
// }
pub fn bench(duration: Duration, degree: u32, max_degree: u32) {
    prove(duration, degree, max_degree);
}
// }

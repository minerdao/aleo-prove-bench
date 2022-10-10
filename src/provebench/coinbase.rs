use snarkvm::{
    algorithms::polycommit::kzg10::UniversalParams,
    curves::bls12_377::{Bls12_377},
    prelude::{Address, CanonicalDeserialize, CoinbasePuzzle, EpochChallenge, PrivateKey, PuzzleConfig, Testnet3},
    utilities::serialize::*,
};
use benchmarking;
use rand::{thread_rng, RngCore};
use std::{time::Duration, fs::File, io::Read};
use crate::metrics::*;

type CoinbasePuzzleInst = CoinbasePuzzle<Testnet3>;


fn load_universal_srs() -> UniversalParams<Bls12_377> {
    let mut file = File::open("./universal.srs").expect("need universal20.srs file");
    let mut srs = Vec::new();
    file.read_to_end(&mut srs).expect("need to read the whole file");

    let universal_srs: UniversalParams<Bls12_377> =
        CanonicalDeserialize::deserialize_with_mode(&*srs, Compress::No, Validate::No).expect("Failed to init universal SRS");

    // println!("universal srs max degree: {}", universal_srs.supported_degree_bounds().len());

    universal_srs

    // let max_config = PuzzleConfig { degree: 2_u32.pow(max_degree) };
    // let config = PuzzleConfig { degree: 2_u32.pow(degree) };
    // let universal_srs = CoinbasePuzzleInst::setup(max_config, &mut thread_rng()).unwrap();
}

// pub struct ProveBench {}

// impl ProveBench {
pub fn prove(duration: Duration, degree: u32) {
    print_title_info("Waiting", "Prove Setup, read file universal.srs");
    let universal_srs = load_universal_srs();
    print_title_info("Waiting", "Prove Setup, trim srs to prove key");

    let config = PuzzleConfig {  degree: 2_u32.pow(degree), };
    let provekey = CoinbasePuzzleInst::trim(&universal_srs, config).unwrap().0;

    print_backgroud_metrics(duration.as_secs() as usize);

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

    print_result("CoinBase on prove:", result);
}

// fn accumulate_prove(c: &mut Criterion) {
// CoinbasePuzzle<Testnet3>::prove(&pk, &epoch_info, &epoch_challenge, &address, nonce);
// CoinbasePuzzle<Testnet3>::accumulate(&pk, &epoch_info, &epoch_challenge, &solutions);
// }
pub fn bench(duration: Duration, degree: u32) {
    prove(duration, degree);
}
// }

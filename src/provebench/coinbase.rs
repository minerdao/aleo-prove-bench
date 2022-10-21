use crate::metrics::*;
use benchmarking;
use rand::{thread_rng, RngCore};
use snarkvm::{
    algorithms::polycommit::kzg10::UniversalParams,
    curves::bls12_377::Bls12_377,
    prelude::{Address, CanonicalDeserialize, CoinbasePuzzle, EpochChallenge, PrivateKey, PuzzleConfig, Testnet3},
    utilities::serialize::*,
};
use std::{fs::File, io::Read, time::Duration};

type CoinbasePuzzleInst = CoinbasePuzzle<Testnet3>;
// type ProvingKeyInst = CoinbaseProvingKey<Testnet3>;

fn setup_prover(degree: u32) -> (CoinbasePuzzleInst, u32) {
    let mut file = File::open("./universal.srs").expect("need universal20.srs file");
    let mut srs = Vec::new();
    file.read_to_end(&mut srs).expect("need to read the whole file");

    let universal_srs: UniversalParams<Bls12_377> =
        CanonicalDeserialize::deserialize_with_mode(&*srs, Compress::No, Validate::No).expect("Failed to init universal SRS");
    // let universal_srs = CoinbasePuzzleInst::setup(max_config, &mut thread_rng()).unwrap();

    print_title_info("Waiting", "Prove Setup, trim srs to prove key");

    let config = PuzzleConfig { degree: 2_u32.pow(degree) };
    let prover = CoinbasePuzzleInst::trim(&universal_srs, config).unwrap();

    (prover, config.degree)
}

pub fn prove_by_degree(prover: Box<CoinbasePuzzleInst>, degree: u32, min_elapse: u64) {
    let duration = Duration::from_secs(min_elapse * 60);
    let result = benchmarking::bench_function_with_duration(duration, move |b| {
        b.measure(|| {
            let rng = &mut thread_rng();
            let challenge: EpochChallenge<Testnet3> = EpochChallenge::new(rng.next_u32(), Default::default(), degree).unwrap();
            let address = Address::try_from(PrivateKey::new(rng).unwrap()).unwrap();
            let nonce = rng.next_u64();
            prover.prove(&challenge, address, nonce).unwrap();
        });
    })
    .unwrap();

    print_result(&format!("{min_elapse}min:"), result);
}

// fn accumulate_prove(c: &mut Criterion) {
// CoinbasePuzzle<Testnet3>::prove(&pk, &epoch_info, &epoch_challenge, &address, nonce);
// CoinbasePuzzle<Testnet3>::accumulate(&pk, &epoch_info, &epoch_challenge, &solutions);
// }

pub fn bench(degree: u32) {
    let (prover, degree) = setup_prover(degree);

    print_backgroud_metrics(6 * 60);

    let p: Box<CoinbasePuzzleInst> = Box::new(prover);
    prove_by_degree(p.clone(), degree, 1);
    prove_by_degree(p.clone(), degree, 5);
}

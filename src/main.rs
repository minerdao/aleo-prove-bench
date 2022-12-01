// #![allow(dead_code)]
// #![allow(unused_imports)]
// #![allow(unused_variables)]

mod metrics;

use core::panic;
use rand::RngCore;
use snarkvm::{
    algorithms::{fft::DensePolynomial, polycommit::kzg10::KZG10},
    prelude::{Address, CoinbaseProvingKey, CoinbasePuzzle, EpochChallenge, Network, PairingEngine, PartialSolution, PrivateKey, Testnet3, ToBytes},
    synthesizer::coinbase_puzzle::{hash_commitment, hash_to_polynomial},
};
use std::{sync::Arc, thread, time};

fn prove<N: Network>(degree: u32) {
    metrics::print_title_info("Waiting", "Prove Setup, load & trim srs to puzzle");
    let puzzle = CoinbasePuzzle::<N>::load().unwrap();
    let pk = match puzzle {
        CoinbasePuzzle::Prover(proving_key) => proving_key,
        _ => panic!("Prover"),
    };

    println!(
        "pk lagrange_basis_at_beta_g={}, product_domain_elements={}",
        pk.lagrange_basis_at_beta_g.len(),
        pk.product_domain_elements.len()
    );

    for i in 0..100 {
        let p = pk.clone();
        let d = degree.clone();
        // thread::spawn(move || {
            prove_solution(i, &p, d);
        // })
        // .join()
        // .unwrap();
    }
}

fn prove_solution<N: Network>(idx: u32, pk: &Arc<CoinbaseProvingKey<N>>, degree: u32) {
    let mut now = time::Instant::now();
    print!("\nprove count {idx}: ");
    // 0. prepare
    let rng = &mut ::rand::thread_rng();
    let private_key = PrivateKey::<N>::new(rng).unwrap();
    let address = Address::try_from(&private_key).unwrap();
    let challenge = EpochChallenge::<N>::new(rng.next_u32(), Default::default(), degree).unwrap();
    let nonce = rng.next_u64();

    let domain = pk.product_domain;
    print!("prepare {}ms, ", now.elapsed().as_millis());
    now = time::Instant::now();

    // 1. polynomial, NTT
    let mut bytes = [0u8; 76];
    bytes[..4].copy_from_slice(&challenge.epoch_number().to_bytes_le().unwrap());
    bytes[4..36].copy_from_slice(&challenge.epoch_block_hash().to_bytes_le().unwrap());
    bytes[36..68].copy_from_slice(&address.to_bytes_le().unwrap());
    bytes[68..].copy_from_slice(&nonce.to_le_bytes());
    let polynomial: DensePolynomial<<N::PairingCurve as PairingEngine>::Fr> = hash_to_polynomial(&bytes, degree);
    let polynomial_evaluations = domain.in_order_fft_with_pc(&polynomial, &pk.fft_precomputation);
    // println!("polynomial coeffs={}, evaluations={}", polynomial.coeffs.len(), polynomial_evaluations.len());
    print!("polynomial {}ms, ", now.elapsed().as_millis());
    now = time::Instant::now();

    // 2. commitment, MSM
    let challenge_evaluations = &challenge.epoch_polynomial_evaluations().evaluations;
    let product_evaluations = domain.mul_polynomials_in_evaluation_domain(&polynomial_evaluations, challenge_evaluations);
    let (commitment, _rand) = KZG10::commit_lagrange(&pk.lagrange_basis(), &product_evaluations, None, &Default::default(), None).unwrap();
    print!("commitment {}ms, ", now.elapsed().as_millis());
    now = time::Instant::now();

    // 3. solution, MSM
    let point = hash_commitment(&commitment).unwrap();
    let product_eval_at_point = polynomial.evaluate(point) * challenge.epoch_polynomial().evaluate(point);

    let _proof = KZG10::open_lagrange(
        &pk.lagrange_basis(),
        pk.product_domain_elements(),
        &product_evaluations,
        point,
        product_eval_at_point,
    )
    .unwrap();
    let _partial_solution = PartialSolution::new(address, nonce, commitment);
    print!("solution {}ms", now.elapsed().as_millis());
}

fn main() {
    let degree = 12;
    // if env::args().len() > 1 {
    //     let arg = env::args().next_back().unwrap();
    //     degree = arg.parse::<u32>().unwrap_or(13);
    // }

    metrics::print_title_info("Author", "The MinerDao Team <minerdaoinfo@gmail.com>");
    metrics::print_title_info("Description", &format!("Aleo prove benchmark degree={}, elapse=5min", degree));
    metrics::print_title_info(
        "Submit",
        "Please submit your result here: https://github.com/minerdao/aleo-prove-bench/issues/new/choose",
    );
    metrics::print_device_info();

    prove::<Testnet3>(2_u32.pow(degree));
}

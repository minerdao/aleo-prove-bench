// #![allow(dead_code)]
// #![allow(unused_imports)]
// #![allow(unused_variables)]

mod metrics;

use anyhow::Result;
use core::panic;
use rand::RngCore;
use snarkvm::{
    algorithms::{fft::DensePolynomial, polycommit::kzg10::KZG10},
    prelude::{Address, CoinbaseProvingKey, CoinbasePuzzle, EpochChallenge, Network, PairingEngine, PartialSolution, PrivateKey, Testnet3, ToBytes},
    synthesizer::coinbase_puzzle::{hash_commitment, hash_to_polynomial},
};
use std::{
    sync::Arc,
    thread,
    time::{self, Duration},
};
// use tokio::prelude::future::join_all;
use futures::future::*;
use std::thread::sleep;
async fn prove<N: Network>(degree: u32) -> Result<()> {
    metrics::print_title_info("Waiting", "Prove Setup, load & trim srs to puzzle");
    let puzzle = CoinbasePuzzle::<N>::load()?;
    let proving_key = match puzzle {
        CoinbasePuzzle::Prover(proving_key) => proving_key,
        _ => panic!("Prover"),
    };

    println!(
        "proving_key lagrange_basis_at_beta_g={}, product_domain_elements={}",
        proving_key.lagrange_basis_at_beta_g.len(),
        proving_key.product_domain_elements.len()
    );

    // 0. prepare
    let rng = &mut ::rand::thread_rng();
    let private_key = PrivateKey::<N>::new(rng)?;
    let address = Address::try_from(&private_key)?;
    let challenge = EpochChallenge::<N>::new(rng.next_u32(), Default::default(), degree)?;
    let nonce_width = 2_u64.pow(64) / 10;
    // let nonce = rng.next_u64();

    let mut handles = Vec::new();
    for i in 0..100 {
        // let i = 1;
        let nonce = i * nonce_width;
        let pk = proving_key.clone();
        let ch = challenge.clone();
        let t = tokio::spawn(async move {
            let _ = prove_solution(i as u32, &pk, &ch, address, nonce).await;
        });
        handles.push(t);
    }
    // let _ = tokio::try_join!(handles);
    let _= join_all(handles);

    // for i in 0..100 {
    //     let nonce = i * nonce_width;
    //     let pk = proving_key.clone();
    //     let ch = challenge.clone();
    //     thread::spawn(move || {
    //         let _ = prove_solution(i as u32, &pk, &ch, address, nonce);
    //     })
    //     .join()
    //     .unwrap();
    // }

    Ok(())
}

async fn prove_solution<N: Network>(idx: u32, pk: &Arc<CoinbaseProvingKey<N>>, challenge: &EpochChallenge<N>, address: Address<N>, nonce: u64) -> Result<()> {
    let mut elapsed = vec![0_u32; 4];
    let now = time::Instant::now();
    // sleep(Duration::from_secs(1));
    let domain = pk.product_domain;

    // 1. polynomial, NTT
    let mut bytes = [0u8; 76];
    bytes[..4].copy_from_slice(&challenge.epoch_number().to_bytes_le()?);
    bytes[4..36].copy_from_slice(&challenge.epoch_block_hash().to_bytes_le()?);
    bytes[36..68].copy_from_slice(&address.to_bytes_le()?);
    bytes[68..].copy_from_slice(&nonce.to_le_bytes());
    let polynomial: DensePolynomial<<N::PairingCurve as PairingEngine>::Fr> = hash_to_polynomial(&bytes, challenge.degree());
    let polynomial_evaluations = domain.in_order_fft_with_pc(&polynomial, &pk.fft_precomputation);
    // println!("polynomial coeffs={}, evaluations={}", polynomial.coeffs.len(), polynomial_evaluations.len());
    elapsed[1] = now.elapsed().as_millis() as u32;

    // 2. commitment, MSM
    let challenge_evaluations = &challenge.epoch_polynomial_evaluations().evaluations;
    let product_evaluations = domain.mul_polynomials_in_evaluation_domain(&polynomial_evaluations, challenge_evaluations);
    let (commitment, _rand) = KZG10::commit_lagrange(&pk.lagrange_basis(), &product_evaluations, None, &Default::default(), None)?;
    elapsed[2] = now.elapsed().as_millis() as u32;

    // 3. solution, MSM
    let partial_solution = PartialSolution::new(address, nonce, commitment);
    let target = partial_solution.to_target()?;
    if target > 32 * 1024 {
        println!("target:{target}>32k");
    }
    let point = hash_commitment(&commitment)?;
    let product_point = polynomial.evaluate(point) * challenge.epoch_polynomial().evaluate(point);
    KZG10::open_lagrange(&pk.lagrange_basis(), pk.product_domain_elements(), &product_evaluations, point, product_point)?;
    elapsed[3] = now.elapsed().as_millis() as u32;
    elapsed[0] = elapsed[1] + elapsed[2] + elapsed[3];
    println!("prove{idx} {}ms: {}ms, {}ms, {}ms", elapsed[0], elapsed[1], elapsed[2], elapsed[3]);

    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    let degree = 12;
    // if env::args().len() > 1 {
    //     let arg = env::args().next_back()?;
    //     degree = arg.parse::<u32>().unwrap_or(13);
    // }

    metrics::print_title_info("Author", "The MinerDao Team <minerdaoinfo@gmail.com>");
    metrics::print_title_info("Description", &format!("Aleo prove benchmark degree={}, elapse=5min", degree));
    metrics::print_title_info(
        "Submit",
        "Please submit your result here: https://github.com/minerdao/aleo-prove-bench/issues/new/choose",
    );
    metrics::print_device_info();

    let _ = prove::<Testnet3>(2_u32.pow(degree)).await;

    Ok(())
}

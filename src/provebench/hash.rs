use snarkvm::{
    algorithms::{crypto_hash::PoseidonSponge, AlgebraicSponge},
    curves::bls12_377::Fq,
    utilities::Uniform,
};
use benchmarking;
use rand::thread_rng;
use crate::metrics::print_result;

fn poseidon_sponge_2_1_absorb_4() {
    let rng = &mut thread_rng();
    let mut sponge = PoseidonSponge::<Fq, 2, 1>::new();

    let input = vec![Fq::rand(rng), Fq::rand(rng), Fq::rand(rng), Fq::rand(rng)];
    let result = benchmarking::measure_function(move |b| b.measure(|| sponge.absorb_native_field_elements(&input))).unwrap();

    print_result("Hash on poseidon 4", result);
}

fn poseidon_sponge_2_1_absorb_10() {
    let rng = &mut thread_rng();
    let mut sponge = PoseidonSponge::<Fq, 2, 1>::new();

    let input = vec![Fq::rand(rng); 10];
    let result = benchmarking::measure_function(move |b| b.measure(|| sponge.absorb_native_field_elements(&input))).unwrap();

    print_result("Hash on poseidon 10", result);
}

pub fn bench() {
    poseidon_sponge_2_1_absorb_4();
    poseidon_sponge_2_1_absorb_10();
}

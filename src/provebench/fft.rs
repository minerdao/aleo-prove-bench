use benchmarking;
use rand::thread_rng;
use snarkvm::{
    algorithms::fft::{DensePolynomial, EvaluationDomain},
    fields::PrimeField,
    curves::bls12_377::Fr,
};
use crate::metrics::print_result;

// /// Degree bounds to benchmark on
// /// e.g. degree bound of 2^{15}, means we do an FFT for a degree (2^{15} - 1) polynomial
// const BENCHMARK_MIN_DEGREE: usize = 1 << 15;
// const BENCHMARK_MAX_DEGREE: usize = 1 << 22;
// const BENCHMARK_LOG_INTERVAL_DEGREE: usize = 1;

fn fft_in_place<F: PrimeField>(domain: EvaluationDomain<F>, degree: usize) {
    let mut a = DensePolynomial::<F>::rand(degree, &mut thread_rng()).coeffs().to_vec();
    let result = benchmarking::measure_function(move |b| b.measure(|| domain.fft_in_place(&mut a))).unwrap();

    print_result("FFT on fft_in_place", result);
}

fn ifft_in_place<F: PrimeField>(domain: EvaluationDomain<F>, degree: usize) {
    let mut a = DensePolynomial::<F>::rand(degree, &mut thread_rng()).coeffs().to_vec();
    let result = benchmarking::measure_function(move |b| b.measure(|| domain.ifft_in_place(&mut a))).unwrap();

    print_result("FFT on ifft_in_place", result);
}

fn coset_fft_in_place<F: PrimeField>(domain: EvaluationDomain<F>, degree: usize) {
    let mut a = DensePolynomial::<F>::rand(degree, &mut thread_rng()).coeffs().to_vec();
    let result = benchmarking::measure_function(move |b| b.measure(|| domain.coset_fft_in_place(&mut a))).unwrap();

    print_result("FFT on coset_fft_in_place", result);
}

fn coset_ifft_in_place<F: PrimeField>(domain: EvaluationDomain<F>, degree: usize) {
    let mut a = DensePolynomial::<F>::rand(degree, &mut thread_rng()).coeffs().to_vec();
    let result = benchmarking::measure_function(move |b| b.measure(|| domain.coset_ifft_in_place(&mut a))).unwrap();

    print_result("FFT on coset_ifft_in_place", result);
}

pub fn bench(degree: usize) {
    println!("BLS12-377 - radix-2");
    let domain: EvaluationDomain<Fr> = EvaluationDomain::new(degree).unwrap();
    fft_in_place(domain, degree - 1);
    ifft_in_place(domain, degree - 1);
    coset_fft_in_place(domain, degree - 1);
    coset_ifft_in_place(domain, degree - 1);
}

use crate::metrics::print_result;
use benchmarking;
use rand::thread_rng;
use snarkvm::{
    algorithms::{
        crypto_hash::PoseidonSponge,
        snark::marlin::{ahp::AHPForR1CS, MarlinHidingMode, MarlinSNARK},
        AlgebraicSponge,
        SNARK,
    },
    curves::bls12_377::{Bls12_377, Fq, Fr},
    fields::Field,
    r1cs::{errors::SynthesisError, ConstraintSynthesizer, ConstraintSystem},
    utilities::{ops::MulAssign, Uniform},
};
// marlin

type MarlinInst = MarlinSNARK<Bls12_377, FS, MarlinHidingMode, [Fr]>;
type FS = PoseidonSponge<Fq, 2, 1>;

#[derive(Copy, Clone)]
pub struct Benchmark<F: Field> {
    pub a: Option<F>,
    pub b: Option<F>,
    pub num_constraints: usize,
    pub num_variables: usize,
}

impl<ConstraintF: Field> ConstraintSynthesizer<ConstraintF> for Benchmark<ConstraintF> {
    fn generate_constraints<CS: ConstraintSystem<ConstraintF>>(&self, cs: &mut CS) -> Result<(), SynthesisError> {
        let a = cs.alloc(|| "a", || self.a.ok_or(SynthesisError::AssignmentMissing))?;
        let b = cs.alloc(|| "b", || self.b.ok_or(SynthesisError::AssignmentMissing))?;
        let c = cs.alloc_input(
            || "c",
            || {
                let mut a = self.a.ok_or(SynthesisError::AssignmentMissing)?;
                let b = self.b.ok_or(SynthesisError::AssignmentMissing)?;

                a.mul_assign(&b);
                Ok(a)
            },
        )?;

        for i in 0..(self.num_variables - 3) {
            let _ = cs.alloc(|| format!("var {}", i), || self.a.ok_or(SynthesisError::AssignmentMissing))?;
        }

        for i in 0..(self.num_constraints - 1) {
            cs.enforce(|| format!("constraint {}", i), |lc| lc + a, |lc| lc + b, |lc| lc + c);
        }

        Ok(())
    }
}

fn universal_setup() {
    let max_degree = AHPForR1CS::<Fr, MarlinHidingMode>::max_degree(1000000, 1000000, 1000000).unwrap();

    let result =
        benchmarking::measure_function(move |b| b.measure(|| MarlinInst::universal_setup(&max_degree, &mut thread_rng()).unwrap()))
            .unwrap();
    print_result("SNARK on circuit_setup", result);
}

fn circuit_setup(size: usize) {
    let rng = &mut thread_rng();

    let x = Fr::rand(rng);
    let y = Fr::rand(rng);

    let max_degree = AHPForR1CS::<Fr, MarlinHidingMode>::max_degree(100000, 100000, 100000).unwrap();
    let universal_srs = MarlinInst::universal_setup(&max_degree, rng).unwrap();

    let num_constraints = size;
    let num_variables = size;
    let circuit = Benchmark::<Fr> {
        a: Some(x),
        b: Some(y),
        num_constraints,
        num_variables,
    };

    let result =
        benchmarking::measure_function(move |b| b.measure(|| MarlinInst::circuit_setup(&universal_srs, &circuit).unwrap())).unwrap();
    print_result("SNARK on circuit_setup", result);
}

fn prove() {
    let num_constraints = 100;
    let num_variables = 100;

    let x = Fr::rand(&mut thread_rng());
    let y = Fr::rand(&mut thread_rng());

    let max_degree = AHPForR1CS::<Fr, MarlinHidingMode>::max_degree(1000, 1000, 1000).unwrap();
    let universal_srs = MarlinInst::universal_setup(&max_degree, &mut thread_rng()).unwrap();
    let fs_parameters = FS::sample_parameters();

    let circuit = Benchmark::<Fr> {
        a: Some(x),
        b: Some(y),
        num_constraints,
        num_variables,
    };

    let params = MarlinInst::circuit_setup(&universal_srs, &circuit).unwrap();
    let result = benchmarking::measure_function(move |b| {
        b.measure(|| MarlinInst::prove(&fs_parameters, &params.0, &circuit, &mut thread_rng()).unwrap())
    })
    .unwrap();
    print_result("SNARK on prove", result);
}

fn verify() {
    let num_constraints = 100;
    let num_variables = 25;
    let rng = &mut thread_rng();

    let x = Fr::rand(rng);
    let y = Fr::rand(rng);
    let mut z = x;
    z.mul_assign(&y);

    let max_degree = AHPForR1CS::<Fr, MarlinHidingMode>::max_degree(100, 100, 100).unwrap();
    let universal_srs = MarlinInst::universal_setup(&max_degree, rng).unwrap();
    let fs_parameters = FS::sample_parameters();

    let circuit = Benchmark::<Fr> {
        a: Some(x),
        b: Some(y),
        num_constraints,
        num_variables,
    };

    let (pk, vk) = MarlinInst::circuit_setup(&universal_srs, &circuit).unwrap();

    let proof = MarlinInst::prove(&fs_parameters, &pk, &circuit, rng).unwrap();

    let result = benchmarking::measure_function(move |b| {
        b.measure(|| {
            let verification = MarlinInst::verify(&fs_parameters, &vk, [z], &proof).unwrap();
            assert!(verification);
        })
    })
    .unwrap();
    print_result("SNARK on certificate_verify", result);
}

fn certificate_prove(size: usize) {
    let rng = &mut thread_rng();

    let x = Fr::rand(rng);
    let y = Fr::rand(rng);

    let max_degree = AHPForR1CS::<Fr, MarlinHidingMode>::max_degree(100000, 100000, 100000).unwrap();
    let universal_srs = MarlinInst::universal_setup(&max_degree, rng).unwrap();
    let fs_parameters = FS::sample_parameters();
    // let fs_p = &fs_parameters;

    let num_constraints = size;
    let num_variables = size;
    let circuit = Benchmark::<Fr> {
        a: Some(x),
        b: Some(y),
        num_constraints,
        num_variables,
    };
    let (pk, vk) = MarlinInst::circuit_setup(&universal_srs, &circuit).unwrap();

    let result = benchmarking::measure_function(move |b| b.measure(|| MarlinInst::prove_vk(&fs_parameters, &vk, &pk))).unwrap();
    print_result("SNARK on certificate_prove", result);
}

fn certificate_verify(size: usize) {
    let rng = &mut thread_rng();

    let x = Fr::rand(rng);
    let y = Fr::rand(rng);

    let max_degree = AHPForR1CS::<Fr, MarlinHidingMode>::max_degree(100_000, 100_000, 100_000).unwrap();
    let universal_srs = MarlinInst::universal_setup(&max_degree, rng).unwrap();
    let fs_parameters = FS::sample_parameters();
    let fs_p = &fs_parameters;

    let num_constraints = size;
    let num_variables = size;
    let circuit = Benchmark::<Fr> {
        a: Some(x),
        b: Some(y),
        num_constraints,
        num_variables,
    };
    let (pk, vk) = MarlinInst::circuit_setup(&universal_srs, &circuit).unwrap();
    let certificate = MarlinInst::prove_vk(fs_p, &vk, &pk).unwrap();

    let result =
        benchmarking::measure_function(move |b| b.measure(|| MarlinInst::verify_vk(&fs_parameters, &circuit, &vk, &certificate))).unwrap();
    print_result("SNARK on certificate_verify", result);
}

pub fn bench(size: usize) {
    circuit_setup(size);
    universal_setup();
    prove();
    verify();
    certificate_prove(size);
    certificate_verify(size);
}

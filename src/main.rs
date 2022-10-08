#![allow(dead_code)]

mod provebench;
use provebench::*;
use std::{env, process, time};

fn handle_args() -> u32 {
    let mut degree: u32 = 12;
    if env::args().len() == 2 {
        let subcommand = env::args().next_back().unwrap();
        if subcommand == "-h" {
            println!("USAGE: ./aleoprove degree[10..19]");
            process::exit(-1);
        } else {
            degree = subcommand.parse::<u32>().expect("degree must be between 10 and 19");
            if degree < 10 || degree > 19 {
                println!("error: degree must be between 10 and 19");
                process::exit(-1);
            }
        }
    }

    return degree;
}

fn main() {
    let degree = handle_args();
    metrics::print_title_info("Author", "The MinerDao Team <minerdaoinfo@gmail.com>");
    metrics::print_title_info("Description", &format!("Aleo prove benchmark degree={}, elapse=5min", degree));

    benchmarking::warm_up();

    metrics::print_device_info();
    // metrics::print_backgroud_metrics();

    let duration = time::Duration::from_secs(5 * 60);
    coinbase::bench(duration, degree);
    // msm::bench(2_000_000);
    // hash::bench();
    // fft::bench(1 << 22);
    // snark::bench(100_000);
}

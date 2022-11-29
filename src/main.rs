#![allow(dead_code)]

mod provebench;
use provebench::*;
use std::{env, process};

fn handle_args() -> u32 {
    let mut degree: u32 = 13;
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
    metrics::print_title_info("Submit", "Please submit your result here: https://github.com/minerdao/aleo-prove-bench/issues/new/choose");
    metrics::print_device_info();

    coinbase::bench(degree);
    
    // msm::bench(2_000_000);
    // hash::bench();
    // fft::bench(1 << 22);
    // snark::bench(100_000);
}

use benchmarking::MeasureResult;
use console::Term;
use nvml_wrapper::{cuda_driver_version_major, cuda_driver_version_minor, Nvml};
use once_cell::sync::Lazy;
use std::thread;
use std::time::Duration;
use sysinfo::{CpuExt, ProcessExt, System, SystemExt};

static NVML_CUDA: Lazy<Nvml> = Lazy::new(|| Nvml::init().expect("Nvidia context is not initialized"));

fn title_style(s: &str) -> String {
    console::style(s).green().bold().to_string()
}

pub fn print_result(name_fn: &str, result: MeasureResult) {
    let time = result.elapsed().as_millis();
    let count = 1000 / time; //result.times() / result.elapsed().as_secs() as u128;
    println!("{: >25} {name_fn} {time}ms {count}prove/s", title_style("Result"));
}

pub fn print_title_info(title: &str, info: &str) {
    println!("{: >25} {info}", title_style(title));
}

fn print_rewrite_line(line: &String) {
    let term = Term::stdout();
    term.move_cursor_up(1).unwrap();
    term.write_line(line).unwrap();
}

pub fn print_device_info() {
    let cpu = System::new_all();
    let (cname, ccores) = (cpu.global_cpu_info().vendor_id(), cpu.cpus().len());
    let os = cpu.long_os_version().unwrap();
    println!("{: >25} {cname}({ccores}), {os}", title_style("Device CPU"));

    let cuda_version = NVML_CUDA.sys_cuda_driver_version().unwrap();
    if cuda_version < 11020 {
        println!("{: >25} cuda version must > 11.2, gpu won't run", title_style("Error"));
    }
    let (major, minor) = (cuda_driver_version_major(cuda_version), cuda_driver_version_minor(cuda_version));
    let nvidia_version = NVML_CUDA.sys_driver_version().unwrap();
    
    print!("{: >25} [", title_style("Device GPU"));

    for i in 0..NVML_CUDA.device_count().unwrap_or(0) {
        let gpu = NVML_CUDA.device_by_index(i).expect(&format!("Nvidia device {i} is not initialized"));
        let (gname, gcores) = (gpu.name().unwrap(), gpu.num_cores().unwrap());

        print!("{gname}({gcores}), "); 
    }
    println!("], version {major}.{minor}/{nvidia_version}");

}

pub fn print_backgroud_metrics(elapse: usize) {
    print_rewrite_line(&format!("\n{: >25} CPU: 0% GPU: 0%, Elapsed: 0s", title_style("Proving")));

    let mut sys = System::new_all();
    thread::spawn(move || {
    // let (cpu_max, gpu_max) = thread::spawn(move || {
        for i in 0..elapse {
            thread::sleep(Duration::from_secs(1));
            sys.refresh_all();

            let ps = sys.processes_by_name("aleoprove").last().unwrap();
            let cpu = ps.cpu_usage().ceil() as u32;
            let gpus: Vec<u32> = (0..NVML_CUDA.device_count().unwrap_or(0))
            .into_iter()
            .map(|i| {
                let d = NVML_CUDA.device_by_index(i).expect(&format!("Nvidia device {i} is not initialized"));
                d.utilization_rates().unwrap().gpu
            })
            .collect();
            let gpu = gpus[0];

            // cpu_max = std::cmp::max(cpu, cpu_max);
            // gpu_max = std::cmp::max(gpus[0], gpu_max);

            print_rewrite_line(&format!("{: >25} CPU: {cpu}% GPU: {gpu}%, Elapsed: {i}s    ", title_style("Proving")));
        }
        // (cpu_max, gpu_max)
    });
    // .join()
    // .unwrap();
    // print_rewrite_line(&format!("{: >25} CPU: {cpu_max}% GPU: {gpu_max}%, Elapsed: {elapse}s", title_style("Proving")));
}



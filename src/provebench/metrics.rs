use console::{style, Term};
use nvml_wrapper::{Device, Nvml, cuda_driver_version_major, cuda_driver_version_minor};
use once_cell::sync::Lazy;
use sysinfo::{CpuExt, System, SystemExt};
// use sysinfo::{PidExt, ProcessExt, CpuExt, System, SystemExt};
// use std::{thread, process};
use benchmarking::MeasureResult;
use std::thread;
use std::time::Duration;

static NVML_CUDA: Lazy<Nvml> = Lazy::new(|| Nvml::init().expect("Nvidia context is not initialized"));
static GPU: Lazy<Device> = Lazy::new(|| NVML_CUDA.device_by_index(0).expect("Nvidia device is not initialized"));
static TERM: Lazy<Term> = Lazy::new(|| Term::stdout());
static GPU_USAGE_MAX: Lazy<u32> = Lazy::new(|| 0);

struct Timer<F> {
    delay: Duration,
    action: F,
    count: u32,
}
impl<F> Timer<F>
where
    F: Fn(u32) + Send + Sync + 'static,
{
    //FnOnce() + Send + Sync + 'static {
    fn new(delay: Duration, action: F, count: u32) -> Self {
        Timer { delay, action, count }
    }

    fn start(self) {
        thread::spawn(move || {
            thread::sleep(self.delay);
            (self.action)(self.count);
        });
    }
}

pub fn print_metrics(count: u32) {
    let sys = System::new_all();
    let cpu = sys.global_cpu_info().frequency();
    // let cpu = sys.process(PidExt::from_u32(process::id())).unwrap().cpu_usage();
    // let pid = process::id();
    // let pidext = PidExt::from_u32(pid);
    // let ps = sys.process(pidext).unwrap();
    // let cpu = ps.cpu_usage();
    // println!("{pid}, {cpu} {:?}", ps.exe());

    let gpu = GPU.utilization_rates().unwrap().gpu;
    // if gpu > GPU_USAGE_MAX {
    //     GPU_USAGE_MAX = gpu;
    // }

    TERM.move_cursor_up(1).unwrap();
    let line = &format!("{: >25} CPU: {cpu}% GPU: {gpu}%, Elapsed: {count}s", title_style("Proving"));
    TERM.write_line(line).unwrap();

    let t = Timer::new(Duration::from_secs(1), print_metrics, count + 1);
    t.start();
}

pub fn print_backgroud_metrics() {
    println!("");
    let timer = Timer::new(Duration::from_secs(1), print_metrics, 1);
    timer.start();
}

fn title_style(s: &str) -> String {
    style(s).green().bold().to_string()
}

pub fn print_device_info() {
    let cpu = System::new_all();
    let (cname, ccores) = (cpu.global_cpu_info().vendor_id(), cpu.cpus().len());
    let os = cpu.long_os_version().unwrap();

    let gpu = NVML_CUDA.device_by_index(0).expect("Nvidia device is not initialized");
    let (gname, gcores) = (gpu.name().unwrap(), gpu.num_cores().unwrap());
    let cuda_version = NVML_CUDA.sys_cuda_driver_version().unwrap();
    let (major, minor) = (
        cuda_driver_version_major(cuda_version),
        cuda_driver_version_minor(cuda_version),
    );

    let nvidia_version = NVML_CUDA.sys_driver_version().unwrap();

    println!(
        "{: >25} CPU {cname}({ccores}), GPU {gname}({gcores}) version {major}.{minor}/{nvidia_version}, {os})",
        title_style("Device")
    );
}

pub fn print_result(name_fn: &str, result: MeasureResult) {
    // GPU_USAGE_MAX = 0;

    let time = result.elapsed().as_millis();
    let count = 1000 / time; //result.times() / result.elapsed().as_secs() as u128;
    println!("{: >25} {name_fn} {time}ms {count}prove/s", title_style("Result"));
}

pub fn print_title_info(title: &str, info: &str) {
    println!("{: >25} {info}", title_style(title));
}

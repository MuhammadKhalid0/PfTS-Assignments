# PfTS Assignments – FAU

This repository contains my coursework for the **Programming Techniques for Supercomputers (PfTS)** lecture at **Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU)**, supervised by **NHR@FAU**.

All benchmarks are executed on the **Fritz cluster** using Intel compilers and SLURM job scripts to analyze runtime behavior, loop performance, and CPU efficiency.

---

## Structure

```yaml
PfTS-assignments:
  Assignment0:
    - Assignment0.cpp                 # C++ source code
    - run_job_assignment0.sh         # SLURM job script
    - assignment0_report.tex         # LaTeX report
    - assignment0_report.pdf         # Compiled PDF report
    - ln2_output.txt                 # Terminal output file
    - terminal_output_point1.png     # Screenshot for Point 1
    - terminal_output_point2.png     # Screenshot for Point 2
    - terminal_output_point4.png     # Screenshot for Point 4
  Assignment1:
    - (to be added)                  # Placeholder for next assignment
```


---

## Completed

- **Assignment 0**: Numerical integration of ln(2), timing loops, CPU cycle analysis, FLOPs/s evaluation, and performance governor comparison using SLURM.

---

## Tools

- Cluster: Fritz (NHR@FAU)
- Compiler: Intel oneAPI `icpx`
- Job scheduler: SLURM
- Report: LaTeX

---

## License

This repository is for academic use. Do not copy or distribute without permission.

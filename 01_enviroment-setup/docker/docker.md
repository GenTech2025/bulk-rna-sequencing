# Docker Setup — Downstream RNA-seq Analysis

RStudio Server container with R 4.3.1 and all required Bioconductor packages
for differential expression analysis (DESeq2, edgeR, limma, etc.). All output
written inside `/home/rstudio/project/04_results/` is persisted to the host.

---

**Build** (run from project root)

```bash
docker build -t docker_eda -f 01_enviroment-setup/docker/Dockerfile_eda .
```

**Run**

```bash
sudo docker run -d \
      --rm \
      -p 8787:8787 \
      -v /home/roy/Desktop/test-projects/bulk-rna-sequencing:/home/rstudio/project \
      -e PASSWORD=root \
      --name eda-container \
      docker_eda
```

`--rm` removes the container automatically when stopped.
Open RStudio at `http://localhost:8787` — user: `rstudio`, password: `root`.

**Stop** (also removes the container)

```bash
docker stop eda-container
```

---

**Writing output to host from within RStudio**

The host `04_results/` directory is available inside the container at
`/home/rstudio/project/04_results/`. Any files written there are saved
directly to your host machine.

```r
write.csv(results, "/home/rstudio/project/04_results/deseq2_results.csv")
ggsave("/home/rstudio/project/04_results/volcano_plot.png")
```

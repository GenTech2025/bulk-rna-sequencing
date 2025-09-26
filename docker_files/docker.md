
docker build -t docker_eda -f docker_files/Dockerfile_eda . (builds the docker image)

docker run -d \
  -p 8787:8787 \
  -v D:/portfolio_projects_2025/bulk-rna-sequencing:/home/rstudio/project
  -e PASSWORD=root \
  --name test-eda \
  docker_eda


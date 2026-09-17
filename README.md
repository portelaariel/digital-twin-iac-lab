# Digital Twin with Terraform and Docker

Laboratório simples para demonstrar a relação entre **Infrastructure as Code (IaC)**, **Terraform** e **Digital Twin** utilizando Docker.

## Objetivo

O projeto cria dois ambientes independentes:

* **Real Environment**: representa a infraestrutura real.
* **Digital Twin**: réplica utilizada para reproduzir o estado da infraestrutura e executar experimentos sem modificar o ambiente real.

```text
                 Terraform
                    |
          +---------+---------+
          |                   |
          v                   v
        REAL                TWIN

   client-real          client-twin
   172.20.0.10          172.21.0.10
        |                    |
     real-net             twin-net
        |                    |
   server-real          server-twin
   172.20.0.20          172.21.0.20
```

## Tecnologias

* Terraform
* Docker
* Docker Terraform Provider
* Netshoot
* Linux Traffic Control (`tc`)
* NetEm
* iperf3
* Shell Script

## O que foi implementado

Terraform é utilizado para provisionar a estrutura dos ambientes Real e Twin:

* redes Docker independentes;
* clientes;
* servidores;
* endereços IP fixos;
* capabilities de rede;
* servidores de backup opcionais.

O Digital Twin pode reproduzir características observadas no ambiente Real, como:

* latência;
* packet loss.

Essas condições são aplicadas utilizando `tc netem`.

Exemplo:

```bash
docker exec client-real \
tc qdisc replace dev eth0 root netem \
delay 40ms loss 10%
```

## Telemetria e sincronização

O script:

```bash
./measure_real.sh
```

mede características do ambiente Real e gera métricas locais.

Depois:

```bash
./sync_twin.sh
```

aplica essas características ao Digital Twin.

Fluxo simplificado:

```text
REAL
 |
 | telemetry
 v
measure_real.sh
 |
 v
real_metrics.env
 |
 v
sync_twin.sh
 |
 v
DIGITAL TWIN
```

## What-if Analysis

Depois de sincronizado, o Twin pode receber condições diferentes sem modificar o ambiente Real.

Exemplo:

```bash
docker exec client-twin \
tc qdisc replace dev eth0 root netem \
delay 100ms loss 20%
```

Isso permite avaliar cenários hipotéticos apenas no Twin.

## Benchmark

O laboratório utiliza `ping` e `iperf3` para comparar os dois ambientes.

```bash
./benchmark.sh
```

São avaliados:

* latency;
* packet loss;
* TCP throughput;
* UDP throughput;
* jitter;
* UDP datagram loss.

## Failure Simulation

Também foi implementado um teste simples de disponibilidade.

```bash
./evaluate_twin.sh
```

O servidor principal do Twin é desligado e o laboratório verifica se existe um servidor de backup disponível.

Exemplo:

```text
server-twin
     X
   failure

     |
     v

server-twin-backup
```

## IaC Decision

Servidores de backup podem ser habilitados por variáveis Terraform:

```hcl
enable_backup_twin = false
enable_backup_real = false
```

Copie o arquivo de exemplo:

```bash
cp decision.auto.tfvars.example decision.auto.tfvars
```

Uma mudança pode ser testada primeiro no Twin:

```hcl
enable_backup_twin = true
enable_backup_real = false
```

Depois de validada, a mesma alteração pode ser aplicada ao ambiente Real:

```hcl
enable_backup_twin = true
enable_backup_real = true
```

O Terraform materializa a nova infraestrutura com:

```bash
terraform plan
terraform apply
```

## Arquitetura

```text
                    Terraform / IaC
                          |
                          v
                        REAL
                          |
                      telemetry
                          |
                          v
                    DIGITAL TWIN
                          |
                      experiments
                          |
                          v
                       decision
                          |
                          v
                     Terraform
                          |
                          v
                        REAL
```

O laboratório demonstra de forma simplificada um ciclo de gerenciamento de infraestrutura baseado em **IaC + Digital Twin**.

## Executando

Inicialize o Terraform:

```bash
terraform init
```

Verifique a configuração:

```bash
terraform validate
```

Visualize as alterações:

```bash
terraform plan
```

Crie a infraestrutura:

```bash
terraform apply
```

Verifique os containers:

```bash
docker ps
```

Teste o ambiente Real:

```bash
docker exec client-real ping -c 4 172.20.0.20
```

Teste o Digital Twin:

```bash
docker exec client-twin ping -c 4 172.21.0.20
```

## Limpeza

Para remover os recursos criados pelo Terraform:

```bash
terraform destroy
```

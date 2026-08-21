# Roboshop — Infrastructure as Code (Terraform)

Provisions the full AWS infrastructure for the **Roboshop** e-commerce application using Terraform, in a modular, VM-per-service architecture. Reusable modules define *how* to build each piece of infrastructure; a per-component root configuration composes those modules with Roboshop-specific values and provisions the real resources.

This is the VM-based deployment (Terraform provisions EC2 instances, user-data scripts configure each service) — a companion to the containerized [Docker Compose deployment](./README.md).

## Architecture

The infrastructure is a three-tier VPC (public / private / database subnets across two Availability Zones) fronted by load balancers, with each Roboshop service running on its own EC2 instance.

```
Internet
   │
   ▼
Frontend ALB (public, HTTPS/443, ACM cert)
   │
   ▼
Frontend (Nginx, public-facing)
   │
   ▼
Backend ALB (internal, HTTP/80)
   │
   ├─ catalogue   ┐
   ├─ user        │  application services
   ├─ cart        │  (private subnets, ASG + launch template)
   ├─ shipping    │
   └─ payment     ┘
   │
   ▼
Data layer (private/database subnets)
   ├─ MongoDB   (27017)
   ├─ Redis     (6379)
   ├─ MySQL     (3306)
   └─ RabbitMQ  (5672)

Bastion host (public subnet) → SSH access into private instances
```

## How it fits together

The defining pattern of this project is that **each component is an independent Terraform root with its own remote state**, and components share data through **AWS SSM Parameter Store** rather than a single monolithic state file.

- The `vpc` component creates the network and writes the VPC ID and subnet IDs to SSM.
- The `sg` component creates every security group and writes their IDs to SSM.
- Downstream components (`ingress_rules`, `alb`, `acm`, `bastion`, `database`, `backend`) read whatever IDs they need back out of SSM.

This keeps each state file small, gives each component an independent blast radius, and lets components be applied and destroyed independently. It also avoids the circular dependency that arises when security groups need to reference each other — security group *creation* is separated from the *ingress rules* that wire them together.

## Repository layout

```
Terraform/
├── Common/                 # reusable modules (the "how")
│   ├── vpc/                # VPC, subnets, IGW, NAT, route tables, SSM params
│   ├── SG/                 # all security groups (count over a name list)
│   ├── ingress_rules/      # security group rules wiring services together
│   ├── ALB/                # internal backend Application Load Balancer
│   ├── frontend_alb/       # public frontend ALB (HTTPS)
│   ├── ACM/                # TLS certificate + Route53 DNS validation
│   ├── bastion/            # bastion host + IAM instance profile
│   ├── database/           # MongoDB / Redis / MySQL / RabbitMQ instances
│   └── backend/            # app-tier EC2 → AMI → launch template → ASG
│
└── aws/                    # Roboshop root configs (the "what")
    ├── vpc/
    ├── sg/
    ├── ingress_rules/
    ├── acm/
    ├── alb/
    ├── bastion/
    ├── database/
    └── backend/            # each has main.tf (module call), provider.tf, local.tf, variable.tf
```

Every `aws/<component>` root calls its matching `Common/` module, passing `project` and `environment`, and stores its state in S3 under a distinct key.

## Prerequisites

- Terraform and the AWS CLI installed, with credentials configured
- An S3 bucket for remote state (`sravan-devops-project`) and permission to write SSM parameters
- A Route53 public hosted zone for the domain used by ACM (`sravan.click`)
- The base AMI referenced by the instance modules available in the target account/region

## Deploying

Because components share state through SSM, they must be applied **in dependency order** — a component can only read a parameter that an earlier component has already written.

```bash
# 1. Network first — publishes VPC and subnet IDs to SSM
cd aws/vpc && terraform init && terraform apply

# 2. Security groups — publishes SG IDs to SSM
cd ../sg && terraform init && terraform apply

# 3. Ingress rules — reads all SG IDs, wires them together
cd ../ingress_rules && terraform init && terraform apply

# 4. Certificate, load balancers, bastion, data layer, app tier
cd ../acm && terraform init && terraform apply
cd ../alb && terraform init && terraform apply
cd ../bastion && terraform init && terraform apply
cd ../database && terraform init && terraform apply
cd ../backend && terraform init && terraform apply
```

Destroy in the reverse order, so no component is removed while another still depends on its SSM parameters.

## Design notes

**Remote state.** Each component writes to the same S3 bucket under its own key (`Roboshop.tfstate`, `Roboshop_sgs.tfstate`, `Roboshop_ingress_rules.tfstate`, and so on), keeping state files small and independently manageable.

**Tagging.** Modules layer tags with `merge()` — a common tag block (project, environment) is combined with per-resource caller tags and a computed `Name`, giving consistent, predictable naming across every resource.

**App tier.** Backend services use an immutable-infrastructure pattern: launch a seed instance, stop it, bake an AMI, define a launch template from that AMI, and run it under an Auto Scaling Group with rolling instance refresh and target-tracking CPU scaling behind the internal ALB.

**Data tier.** Database instances are provisioned in private/database subnets and configured on first boot via `templatefile()` user-data scripts (install, enable remote connections, set credentials).


## Security note

The bastion host currently attaches the `AdministratorAccess` managed policy for convenience. In a real environment this should be scoped to least privilege (e.g. SSM and read-only access) rather than full admin. SSH to the bastion is restricted to a single public IP via a `/32` rule.
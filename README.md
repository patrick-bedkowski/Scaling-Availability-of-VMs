# Scalable and Highly Available Web Service

## 🔧 Technologies Used

- **KVM + libvirt** – Virtualization platform
- **FastAPI** – Python-based stateless web service
- **HAProxy** – Load balancer
- **Siege** – Load testing tool
- **Bash** – Automation scripts
- **cloud-init** – VM auto-configuration

## 🚀 Features

- **Stateless FastAPI Service**\
  Each GET request simulates CPU load using `cpu-load-generator`.

- **/metrics Endpoint**\
  Returns real-time CPU usage using `psutil`.

- **HAProxy Load Balancing**\
  Round-robin load distribution and health checks.

- **Autoscaling**

  - Scales up when CPU > 60%
  - Scales down when CPU < 10%
  - Operates between 1–4 VMs
  - Uses custom scripts for VM creation/destruction and HAProxy reconfiguration.

## 🧪 Testing Scenarios

1. **Single VM**

   - Stable under light load
   - Decreased availability under heavy load (up to 62.5%)

2. **Two VMs**

   - 100% availability with 30 clients

3. **Autoscaling (up to 3 VMs)**

   - High availability maintained under increasing load
   - Initial scaling delay \~80s

4. **Failure Recovery**

   - Simulated VM crash triggers scale-up
   - Service self-heals with minimal packet loss

## 🗂️ Key Scripts

### `generate_haproxy_cfg.sh`

Generates HAProxy config based on running VMs.

### `autoscaler.sh`

Main scaling logic based on `/metrics` CPU usage.

### `create_vm.sh`

Creates new VMs using `virt-install` and `cloud-init`.

### `destroy_vm.sh`

Destroys VMs and cleans up resources.

### `cloud-init.yaml`

Sets up a new VM with:

- FastAPI + dependencies
- Systemd service for autostart

## 📌 Usage

1. Launch initial VM manually.
2. Start `autoscaler.sh` to enable dynamic scaling.
3. Send load using:
   ```bash
   siege -c 30 -d 1 -t 300S http://localhost:8000/
   ```

## 📊 Results

| Configuration    | Availability |
| ---------------- | ------------ |
| 1 VM (30 users)  | 62.5%        |
| 2 VMs            | 100%         |
| 3 VMs (scaled)   | 91%+         |
| After VM Failure | Recovered    |

## 👥 Authors

Developed by: **Szarejko Łukasz** & **Będkowski Patryk**\

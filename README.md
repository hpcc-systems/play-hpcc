# play.hpccsystems.com

## ~/bin

<details>
<summary><code>apt_update_all.sh</code></summary>
<ul>
    <li>Bring the OS and all installed <code>.deb</code> packages up to date</li>
</ul>
</details>

<details>
<summary><code>azure_make_mounted.sh</code></summary>
<ul>
    <li>Mount an external Azure disk permanently</li>
</ul>
</details>

<details>
<summary><code>hpcc_config</code></summary>
<ul>
    <li>Launch HPCC's configmgr</li>
</ul>
</details>

<details>
<summary><code>hpcc_fetch &lt;version&gt;</code></summary>
<ul>
    <li>Download the Ubuntu 24.04 version of the platform</li>
    <li>Will append '-1' to the version if needed</li>
</ul>
</details>

<details>
<summary><code>hpcc_snapshot &lt;create | restore | wipe&gt;</code></summary>
<ul>
    <li>Manage archived copies of <code>/lib/HPCCSystems</code></li>
</ul>
</details>

<details>
<summary><code>hpcc_start</code></summary>
<ul>
    <li>Start the installed platform</li>
</ul>
</details>

<details>
<summary><code>hpcc_stop</code></summary>
<ul>
    <li>Stop the installed platform</li>
</ul>
</details>

<details>
<summary><code>hpcc_upgrade &lt;package_path&gt;</code></summary>
<ul>
    <li>Upgrades the current platform, installing the given package</li>
</ul>
</details>

<details>
<summary><code>my_ip.sh</code></summary>
<ul>
    <li>What is my IP?</li>
</ul>
</details>

<details>
<summary><code>renew_lets_encrypt_cert.sh</code></summary>
<ul>
    <li>Renews Let's Encrypt certificate</li>
</ul>
</details>

<details>
<summary><code>search</code></summary>
<ul>
    <li>Shortcut for the <code>find</code> command line utility</li>
</ul>
</details>

<details>
<summary><code>wipe_hpcc.sh</code></summary>
<ul>
    <li>Restarts the cluster, wiping all data in the process</li>
</ul>
</details>

---

## /etc

- **cron.d**
    - `certbot`
- **cron.hourly**
    - `hpcc_certificates`
- **cron.daily**
    - `hpcc_logs`
    - `logrotate`

---

## Notes

- Platform configuration disallows embedded (non-ECL) code execution
- Cluster is wiped daily to mitigate problematic uploads

---

# Azure

- **Subscription:** `us-hpccsystems-dev`
- **Resource Group:** `play-vm-rg`
- **VM:** `play-vm-hpcc`
    - IP: `20.163.232.157`
    - OS: Ubuntu 24.04

---

# Periodic Activities
**Every Friday morning [Can choose any day. Preferably early morning to avoid interruptions]**
- **Bring OS and packages up to date:**
    - `apt_update_all.sh`
- **Install latest HPCC Platform:**
    - `hpcc_fetch <version>`
    - `hpcc_update <package_file`

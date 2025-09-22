# play.hpccsystems.com

This repository contains scripts and configuration for managing the HPCC Platform on play.hpccsystems.com, including an automated version management system.

## ~/bin

<details>
<summary><code>hpcc_fetch_and_upgrade</code></summary>
<ul>
    <li><strong>Comprehensive HPCC Platform update automation</strong></li>
    <li>Fetches latest releases from GitHub API and filters out release candidates</li>
    <li>Compares versions to identify newest available release</li>
    <li>Downloads newer versions automatically using <code>hpcc_fetch_enhanced</code></li>
    <li>Manages file retention (keeps minimum of 3 release files)</li>
    <li>Executes <code>hpcc_upgrade_enhanced</code> for system updates</li>
    <li><strong>Features:</strong>
        <ul>
            <li>✅ Automatic version detection from GitHub</li>
            <li>✅ Gold release filtering (excludes rc1, rc2, etc.)</li>
            <li>✅ Semantic version comparison with revision support</li>
            <li>✅ Smart file management with retention policy</li>
            <li>✅ Comprehensive logging with categorized output</li>
            <li>✅ Robust error handling and graceful failures</li>
        </ul>
    </li>
    <li><strong>Configuration:</strong>
        <ul>
            <li>Release Directory: <code>/home/innovate/</code></li>
            <li>File Pattern: <code>hpccsystems-platform-community_*noble_amd64_withsymbols.deb</code></li>
            <li>Repository: <code>hpcc-systems/HPCC-Platform</code></li>
        </ul>
    </li>
    <li><strong>Usage:</strong> <code>./hpcc_fetch_and_upgrade</code></li>
</ul>
</details>

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
<summary><code>hpcc_fetch_enhanced &lt;version&gt;</code></summary>
<ul>
    <li>Enhanced version of hpcc_fetch with robust error handling</li>
    <li>Download the Ubuntu Noble version of the platform</li>
    <li>Comprehensive input validation and file verification</li>
    <li>Automatic retry logic and timeout handling</li>
    <li>File size validation and cleanup on failure</li>
    <li>Skip download if file already exists</li>
    <li>Downloads to parent directory with dynamic path resolution</li>
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
<summary><code>hpcc_upgrade_enhanced &lt;package_path&gt;</code></summary>
<ul>
    <li>Enhanced version of hpcc_upgrade with comprehensive error handling</li>
    <li>Validates package file existence, type (.deb), and size</li>
    <li>Step-by-step error checking for stop/install/start operations</li>
    <li>Graceful recovery if installation fails</li>
    <li>Service verification after upgrade completion</li>
    <li>Detailed progress reporting and error messages</li>
    <li>Uses dynamic path resolution for script dependencies</li>
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

**Automated Updates**
The `hpcc_fetch_and_upgrade` script can be scheduled to run automatically for hands-off HPCC Platform updates.

**Current Manual Updates - Every Friday morning [Can choose any day. Preferably early morning to avoid interruptions]**

**Automated Updates**
The `hpcc_fetch_and_upgrade` script can be scheduled to run automatically for hands-off HPCC Platform updates.

**Current Manual Updates - Every Friday morning [Can choose any day. Preferably early morning to avoid interruptions]**
- **Bring OS and packages up to date:**
    - `apt_update_all.sh`
- **Install latest HPCC Platform:**
    - `hpcc_fetch <version>`
    - `hpcc_upgrade <package_file>`
    - `hpcc_upgrade <package_file>`

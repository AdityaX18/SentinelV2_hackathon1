# SentinelV2 CLI Architecture

## 1. APIs Used & Purpose

| API | Purpose | Why it was used |
| :--- | :--- | :--- |
| **Hugging Face Inference API** | **Tier 1 Analysis (Intent)** | Used to send URLs to the `google/gemma-2-2b-it` LLM. This allows for **semantic analysis** of phishing URLs (e.g., asking "Is this phishing?") rather than just relying on static blocklists. |
| **VirusTotal API** | **Tier 2 Analysis (Reputation)** | Referenced in the code (`VT_API_KEY`), intended for checking file/URL reputation against global antivirus engines. |

## 2. Core File Structure

These are the core files that make the CLI work:

*   **`cli_app/sentinel.py`**: The **User Interface**. This is the main Python script that you run from the terminal. It handles user commands, calls the APIs, and displays the colorful results.
*   **`linux-backend/src/main.rs`**: The **Secure Engine**. This is the Rust code that actually handles the dangerous work of opening and analyzing files. It spins up the Firecracker microVMs.
*   **`host-bridge/bridge.py`**: The **Connector**. While primarily for the Chrome Extension, this script reuses the CLI's logic to allow the browser to "talk" to your local terminal tools.
*   **`setup_env.sh`**: The **Installer**. A script to install Python dependencies and compile the Rust backend.

## 3. Languages & Frameworks

*   **Python**: The "Glue" Language.
    *   **Framework**: **`Click`** (Command Line Interface Creation Kit) is used to create the beautiful command-line interface with commands like `scan-url` and `scan-file`.
    *   **Library**: **`Requests`** is used for making HTTP calls to Hugging Face.
*   **Rust**: The "Power" Language.
    *   **Framework**: **`Clap`** (Command Line Argument Parser) is used to parse arguments in the Rust binary.
    *   **Library**: **`Serde`** is used for high-performance JSON serialization to pass data back to Python.
    *   **Technology**: **`Firecracker`** is the virtualization technology used by the Rust backend to create secure microVMs.

## 4. Main File Explanation: `cli_app/sentinel.py`

This file is the "brain" of the CLI. Here is how it works:

1.  **Setup & Config**:
    *   It starts by importing necessary libraries (`click`, `requests`, `subprocess`) and loading your API keys (`HF_TOKEN`, `VT_API_KEY`) from environment variables.

2.  **The CLI Entry Point (`@click.group`)**:
    *   Defines the main `cli()` function, which serves as the container for all commands.

3.  **`scan_url` Command**:
    *   **Input**: Takes a URL string.
    *   **LLM Check**: Sends a prompt to Hugging Face: *"Analyze this URL for phishing... Reply with MALICIOUS or SAFE."*
    *   **Heuristics**: It also runs local checks, looking for suspicious keywords (like "login", "verify") and checking for HTTP vs HTTPS.
    *   **Scoring**: It combines the LLM's opinion + local heuristics to calculate a **Risk Score (0-100)** and prints a colored report.

4.  **`scan_file` Command**:
    *   **Input**: Takes a file path.
    *   **Delegation**: It does **not** analyze the file itself (which would be unsafe). Instead, it uses `subprocess` to call the compiled **Rust binary** (`sentinel_cli`).
    *   **Output Parsing**: It captures the JSON output from the Rust tool (which ran the Firecracker VM), parses it, and displays the "Isolation" status and "Threat Level" to the user.
